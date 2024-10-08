// ArrangementRepresentation.swift
// VHDLMachines
//
// Created by Morgan McColl.
// Copyright © 2024 Morgan McColl. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
//
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
//
//    This product includes software developed by Morgan McColl.
//
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.

import VHDLParsing

/// This representation simply instantiates the machines within it's scope.
///
/// No extra logic is added.
public struct ArrangementRepresentation: ArrangementVHDLRepresentable {

    /// The name of the representation.
    public let name: VariableName

    /// The arrangement this representation is based on.
    public let arrangement: Arrangement

    /// The representations of the machines within the `arrangement`.
    public let machines: [any MachineVHDLRepresentable]

    /// The entity of this representation.
    public let entity: Entity

    /// The architecture of this representation.
    public let architecture: Architecture

    /// The includes in this representation.
    public let includes: [Include]

    /// Create an `ArrangementRepresentation`.
    ///
    /// This initialiser will create a representation for `arrangement` that allows multiple machine
    /// formats to be used. The `createMachine` method instantiates each machine and may be modified
    /// to allow for custom machine representations.
    /// - Parameters:
    ///   - arrangement: The arrangement to create this representation from.
    ///   - name: The name of the representation. This will be the name of the entity and architecture.
    ///   - createMachine: A function to create a machine representation from. The default
    /// implementation is `MachineRepresentation`.
    /// - SeeAlso: ``MachineVHDLRepresentable``
    @inlinable
    public init?(
        arrangement: Arrangement,
        name: VariableName,
        createMachine: @escaping (Machine, VariableName) -> (any MachineVHDLRepresentable)? = {
            MachineRepresentation(machine: $0, name: $1)
        }
    ) {
        let arrangementExternalVariables = arrangement.externalSignals.map(\.name)
        let arrangementGlobals = arrangement.signals.map(\.name)
        let clocks = arrangement.clocks.map(\.name)
        let allArrangementVariables = arrangementExternalVariables + arrangementGlobals + clocks
        let arrangementVariables = Set(allArrangementVariables)
        guard
            arrangementVariables.count == allArrangementVariables.count,
            arrangement.machines.allSatisfy({
                $0.value.mappings.allSatisfy({ arrangementVariables.contains($0.source) })
            })
        else {
            return nil
        }
        let machinesTuples: [(VariableName, any MachineVHDLRepresentable)] = arrangement.machines
            .compactMap { instance, mapping in
                createMachine(mapping.machine, instance.type).flatMap { machine in (instance.name, machine) }
            }
        guard machinesTuples.count == arrangement.machines.count else {
            return nil
        }
        let machines = Dictionary(uniqueKeysWithValues: machinesTuples)
        guard
            let entity = Entity(arrangement: arrangement, name: name),
            let architecture = Architecture(
                arrangement: arrangement,
                machines: machines,
                name: name
            )
        else {
            return nil
        }
        self.init(
            name: name,
            arrangement: arrangement,
            machines: Array(machines.sorted { $0.key < $1.key }.map(\.value)),
            entity: entity,
            architecture: architecture,
            includes: Machine.initial.includes
        )
    }

    /// Create an `ArrangementRepresentation`.
    ///
    /// - Parameters:
    ///   - name: The name of the representation.
    ///   - arrangement: The arrangement this representation is based on.
    ///   - machines: The representations of the machines within the `arrangement`.
    ///   - entity: The entity of this representation.
    ///   - architecture: The architecture of this representation.
    ///   - includes: The includes in this representation.
    @inlinable
    init(
        name: VariableName,
        arrangement: Arrangement,
        machines: [any MachineVHDLRepresentable],
        entity: Entity,
        architecture: Architecture,
        includes: [Include]
    ) {
        self.name = name
        self.arrangement = arrangement
        self.machines = machines
        self.entity = entity
        self.architecture = architecture
        self.includes = includes
    }

}
