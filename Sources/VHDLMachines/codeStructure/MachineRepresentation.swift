// MachineRepresentation.swift
// Machines
//
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
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
//

import VHDLParsing

/// A struct defining the simplest type of `VHDL` representation.
///
/// This structure is similar to the `VHDL`
/// representation from my honours paper *High-level Executable Models of Reactive Real-Time Systems with
/// Logic-Labelled Finite-State Machines and FPGAs* published at ReConfig2018. This format does not contain
/// any inherent fault tolerance, but does provide mechanisms for after statements, suspension and
/// parameterisation. Snapshot semantics are present for both external variables and parameters.
public struct MachineRepresentation: MachineVHDLRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The body of the architecture.
    public let architectureBody: AsynchronousBlock

    /// The head of the architecture.
    public let architectureHead: ArchitectureHead

    /// The name of the architecture.
    public let architectureName: VariableName

    /// The entity of the architecture.
    public let entity: Entity

    /// The machine this representation is for.
    public let machine: Machine

    /// The includes for this representation.
    @inlinable public var includes: [Include] {
        machine.includes
    }

    // swiftlint:disable function_body_length

    /// Create the machine representation for the given machine.
    ///
    /// - Parameter machine: The machine to convert into a `VHDL` file.
    /// - Parameter name: The name of the machine.
    public init?(machine: Machine, name: VariableName) {
        let representationVariables: [VariableName] = [
            .suspended, .internalState, .currentState, .previousRinglet, .suspendedFrom, .ringletLength,
            .clockPeriod, .ringletPerPs, .ringletPerNs, .ringletPerUs, .ringletPerMs, .ringletPerS,
            .readSnapshot, .writeSnapshot, .checkTransition, .noOnEntry, .nullCommand, .restartCommand,
            .resumeCommand, .suspendCommand, .ringletCounter, .command, .targetState,
        ]
        let parameters =
            machine.parameterSignals.map { VariableName.name(for: $0) } + machine.parameterSignals.map(\.name)
        let returnables =
            machine.returnableSignals.map { VariableName.name(for: $0) }
            + machine.returnableSignals.map(\.name)
        let externals =
            machine.externalSignals.map(\.name) + machine.externalSignals.map { VariableName.name(for: $0) }
        let constants = machine.states.map { VariableName.name(for: $0) } + machine.actions
        let otherSignals = machine.machineSignals.map(\.name) + machine.clocks.map(\.name)
        let machineAndExternals =
            representationVariables + parameters + returnables + externals + constants + otherSignals
        let variables = Set(machineAndExternals)
        guard
            variables.count == machineAndExternals.count,
            machine.states.allSatisfy({ (state: State) -> Bool in
                let disallowedVariables = Set(
                    machine.externalSignals.map(\.name)
                        .filter {
                            !state.externalVariables.contains($0)
                        }
                )
                let isntUsingBadVariables = state.actions.allSatisfy { (_, block: SynchronousBlock) -> Bool in
                    block.allVariables.isDisjoint(with: disallowedVariables)
                }
                return isntUsingBadVariables
                    && state.signals.allSatisfy {
                        !variables.contains($0.name)
                            && !variables.contains(
                                // swiftlint:disable:next force_unwrapping
                                VariableName(rawValue: "STATE_\(state.name.rawValue)_\($0.name.rawValue)")!
                            )
                    }
            }),
            let newMachine = Machine(replacingStateRefsIn: machine),
            let entity = Entity(machine: newMachine, name: name),
            let architectureName = VariableName(rawValue: "Behavioral"),
            let head = ArchitectureHead(machine: newMachine),
            let body = AsynchronousBlock(machine: newMachine)
        else {
            return nil
        }
        self.init(
            architectureBody: body,
            architectureHead: head,
            architectureName: architectureName,
            entity: entity,
            machine: newMachine
        )
    }

    // swiftlint:enable function_body_length

    /// Create a `MachineRepresentation` from its stored properties.
    ///
    /// - Parameters:
    ///   - architectureBody: The body of the architecture.
    ///   - architectureHead: The head of the architecture.
    ///   - architectureName: The name of the architecture.
    ///   - entity: The entity of the representation.
    ///   - machine: The machine this representation is for.
    @inlinable
    init(
        architectureBody: AsynchronousBlock,
        architectureHead: ArchitectureHead,
        architectureName: VariableName,
        entity: Entity,
        machine: Machine
    ) {
        self.architectureBody = architectureBody
        self.architectureHead = architectureHead
        self.architectureName = architectureName
        self.entity = entity
        self.machine = machine
    }

}
