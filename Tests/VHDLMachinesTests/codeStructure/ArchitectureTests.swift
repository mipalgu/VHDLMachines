// ArchitectureTests.swift
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

import TestUtils
@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for `Architecture` extensions.
final class ArchitectureTests: XCTestCase {

    /// A test arrangement.
    let arrangement = Arrangement.testArrangement

    /// The machine representations in `arrangement`.
    var machineRepresentations: [VariableName: MachineVHDLRepresentable] {
        Dictionary(uniqueKeysWithValues: arrangement.machines.map {
            // swiftlint:disable:next force_unwrapping
            ($0.name, MachineRepresentation(machine: $1.machine, name: $0.type)!)
        })
    }

    /// Test the architecture is created correctly in arrangement init.
    func testArrangementInit() {
        guard
            let architecture = Architecture(
                arrangement: arrangement, machines: machineRepresentations, name: .arrangement1
            ),
            let pingMachine = machineRepresentations[.pingMachine],
            let pongMachine = machineRepresentations[.pongMachine]
        else {
            XCTFail("Architecture could not be created.")
            return
        }
        let signalStatements = arrangement.signals.map { HeadStatement.definition(value: .signal(value: $0)) }
        let machineDefinitions = [
            HeadStatement.definition(value: .component(
                value: ComponentDefinition(name: .pingMachine, port: pingMachine.entity.port)
            )),
            HeadStatement.definition(value: .component(
                value: ComponentDefinition(name: .pongMachine, port: pongMachine.entity.port)
            ))
        ]
        XCTAssertEqual(
            architecture.head,
            ArchitectureHead(statements: signalStatements + machineDefinitions),
            architecture.head.rawValue
        )
        let mappings = AsynchronousBlock.blocks(blocks: [
            .component(block: ComponentInstantiation(
                label: .pingMachine,
                name: .pingMachine,
                port: PortMap(variables: [
                    VariableMap(
                        lhs: .variable(reference: .variable(name: .clk)),
                        rhs: .expression(value: .reference(
                            variable: .variable(reference: .variable(name: .clk))
                        ))
                    ),
                    VariableMap(
                        lhs: .variable(reference: .variable(name: .externalPing)),
                        rhs: .expression(value: .reference(
                            variable: .variable(reference: .variable(name: .ping))
                        ))
                    ),
                    VariableMap(
                        lhs: .variable(reference: .variable(name: .externalPong)),
                        rhs: .expression(value: .reference(
                            variable: .variable(reference: .variable(name: .pong))
                        ))
                    )
                ])
            )),
            .component(block: ComponentInstantiation(
                label: .pongMachine,
                name: .pongMachine,
                port: PortMap(variables: [
                    VariableMap(
                        lhs: .variable(reference: .variable(name: .clk)),
                        rhs: .expression(value: .reference(
                            variable: .variable(reference: .variable(name: .clk))
                        ))
                    ),
                    VariableMap(
                        lhs: .variable(reference: .variable(name: .externalPing)),
                        rhs: .expression(value: .reference(
                            variable: .variable(reference: .variable(name: .ping))
                        ))
                    ),
                    VariableMap(
                        lhs: .variable(reference: .variable(name: .externalPong)),
                        rhs: .expression(value: .reference(
                            variable: .variable(reference: .variable(name: .pong))
                        ))
                    )
                ])
            ))
        ])
        XCTAssertEqual(architecture.body, mappings, architecture.body.rawValue)
    }

}
