// Architecture+ArrangementInit.swift
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

extension Architecture {

    init?(
        arrangement: Arrangement, machines: [VariableName: any MachineVHDLRepresentable], name: VariableName
    ) {
        var foundEntities: Set<VariableName> = []
        let entities = machines.map { $1.entity }
            .filter {
                guard !foundEntities.contains($0.name) else {
                    return false
                }
                foundEntities.insert($0.name)
                return true
            }
            .sorted { $0.name < $1.name }
        let definitions: [HeadStatement] = entities.map {
            HeadStatement.definition(value: .component(value: ComponentDefinition(
                name: $0.name, port: $0.port
            )))
        }
        let variables = arrangement.signals.map {
            HeadStatement.definition(value: .signal(value: $0))
        }
        let mappings = Dictionary(uniqueKeysWithValues: arrangement.machines.map { ($0.name, $1) })
        let sortedMachines = machines.sorted {
            let lhsName = $0.value.entity.name
            let rhsName = $1.value.entity.name
            guard lhsName == rhsName else {
                return lhsName < rhsName
            }
            return $0.key < $1.key
        }
        let blocks: [AsynchronousBlock] = sortedMachines.compactMap { instance, rep -> AsynchronousBlock? in
            let entity = rep.entity
            guard let mapping: MachineMapping = mappings[instance] else {
                return nil
            }
            let machine = rep.machine
            let externalMaps = machine.externalSignals.map {
                VariableMap(name: $0.name, mapping: mapping, isExternal: true)
            }
            let clockMaps = machine.clocks.map {
                VariableMap(name: $0.name, mapping: mapping, isExternal: false)
                }
            let portMap = PortMap(variables: clockMaps + externalMaps)
            return AsynchronousBlock.component(block: ComponentInstantiation(
                label: instance,
                name: entity.name,
                port: portMap
            ))
        }
        guard blocks.count == machines.count, !blocks.isEmpty else {
            return nil
        }
        self.init(
            body: blocks.count == 1 ? blocks[0] : .blocks(blocks: blocks),
            entity: name,
            head: ArchitectureHead(statements: variables + definitions),
            name: .behavioral
        )
    }

}

extension VariableMap {

    init(name: VariableName, mapping: MachineMapping, isExternal: Bool) {
        // swiftlint:disable:next force_unwrapping
        let portName = isExternal ? VariableName(rawValue: "EXTERNAL_\(name.rawValue)")! : name
        guard
            let variableMapping = mapping.mappings.first(where: { $0.destination == name })
        else {
            self.init(
                lhs: .variable(reference: .variable(name: portName)),
                rhs: .open
            )
            return
        }
        self.init(
            lhs: .variable(reference: .variable(name: portName)),
            rhs: .expression(value: .reference(variable: .variable(
                reference: .variable(name: variableMapping.source)
            )))
        )
    }

}
