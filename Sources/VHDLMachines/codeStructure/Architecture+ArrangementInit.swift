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

    init?<T>(arrangement: Arrangement, machines: [T], name: VariableName) where T: MachineVHDLRepresentable {
        let definitions: [HeadStatement] = machines.compactMap {
            let entity = $0.entity
            return HeadStatement.definition(value: .component(value: ComponentDefinition(
                name: entity.name, port: entity.port
            )))
        }
        guard
            !definitions.isEmpty,
            definitions.count == machines.count,
            let behavioral = VariableName(rawValue: "Behavioral")
        else {
            return nil
        }
        let variables = arrangement.signals.map {
            HeadStatement.definition(value: .signal(value: $0))
        }
        let mappings = arrangement.machines
        let blocks: [AsynchronousBlock] = machines.compactMap { representation -> AsynchronousBlock? in
            let entity = representation.entity
            guard
                let label = VariableName(rawValue: "\(entity.name.rawValue)_inst"),
                let mapping: MachineMapping = mappings[entity.name]
            else {
                return nil
            }
            let maps = mapping.mappings.map {
                VariableMap(
                    lhs: .variable(reference: .variable(name: $0.source)),
                    rhs: .expression(value: .reference(variable: .variable(
                        reference: .variable(name: $0.destination)
                    )))
                )
            }
            let portMap = PortMap(variables: maps)
            return AsynchronousBlock.component(block: ComponentInstantiation(
                label: label,
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
            name: behavioral
        )
    }

}
