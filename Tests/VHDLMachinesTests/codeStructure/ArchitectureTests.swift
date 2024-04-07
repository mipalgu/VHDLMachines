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

    /// A `ping` component.
    let pingComponent = ComponentInstantiation(
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
    )

    /// An instance of a ping machine.
    var pingInstance: AsynchronousBlock {
        .component(block: pingComponent)
    }

    /// An instance of the pong machine.
    let pongInstance = AsynchronousBlock.component(block: ComponentInstantiation(
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

    /// A test arrangement.
    var arrangement = Arrangement.testArrangement

    /// The machine representations in `arrangement`.
    var machineRepresentations: [VariableName: MachineVHDLRepresentable] {
        Dictionary(uniqueKeysWithValues: arrangement.machines.map {
            // swiftlint:disable:next force_unwrapping
            ($0.name, MachineRepresentation(machine: $1.machine, name: $0.type)!)
        })
    }

    /// Initialise test data before every test.
    override func setUp() {
        arrangement = Arrangement.testArrangement
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
            ArchitectureHead(statements: signalStatements + machineDefinitions)
        )
        let mappings = AsynchronousBlock.blocks(blocks: [pingInstance, pongInstance])
        XCTAssertEqual(architecture.body, mappings)
        XCTAssertEqual(architecture.entity, .arrangement1)
        XCTAssertEqual(architecture.name, .behavioral)
    }

    /// Test that the architecture generates only unique components.
    func testArrangementGeneratesUniqueComponents() {
        var mappings = arrangement.machines
        guard let pingMapping = mappings[MachineInstance(name: .pingMachine, type: .pingMachine)] else {
            XCTFail("No ping machine!")
            return
        }
        mappings[MachineInstance(name: .pongMachine, type: .pongMachine)] = nil
        mappings[MachineInstance(name: .pongMachine, type: .pingMachine)] = pingMapping
        arrangement = Arrangement(
            machines: mappings,
            externalSignals: arrangement.externalSignals,
            signals: arrangement.signals,
            clocks: arrangement.clocks
        )
        guard
            let architecture = Architecture(
                arrangement: arrangement, machines: machineRepresentations, name: .arrangement1
            ),
            let pingMachine = machineRepresentations[.pingMachine]
        else {
            XCTFail("Failed to create architecture!")
            return
        }
        let signalStatements = arrangement.signals.map {
            HeadStatement.definition(value: .signal(value: $0))
        }
        let expectedHead = ArchitectureHead(statements: signalStatements + [
            HeadStatement.definition(value: .component(
                value: ComponentDefinition(name: .pingMachine, port: pingMachine.entity.port)
            ))
        ])
        XCTAssertEqual(architecture.head, expectedHead)
        let ping2Instance = AsynchronousBlock.component(block: ComponentInstantiation(
            label: .pongMachine,
            name: pingComponent.name,
            port: pingComponent.port
        ))
        let expectedBody = AsynchronousBlock.blocks(blocks: [pingInstance, ping2Instance])
        XCTAssertEqual(architecture.body, expectedBody)
        XCTAssertEqual(architecture.entity, .arrangement1)
        XCTAssertEqual(architecture.name, .behavioral)
    }

    /// Test the architecture generates the correct components with the correct labels.
    func testArrangementGeneratesDifferentInstanceNames() {
        guard
            let pingMapping = arrangement.machines[MachineInstance(name: .pingMachine, type: .pingMachine)]
        else {
            XCTFail("Failed to find ping mapping!")
            return
        }
        let mappings: [MachineInstance: MachineMapping] = [
            MachineInstance(name: .testMachine, type: .pingMachine): pingMapping
        ]
        arrangement = Arrangement(
            machines: mappings,
            externalSignals: arrangement.externalSignals,
            signals: arrangement.signals,
            clocks: arrangement.clocks
        )
        guard
            let architecture = Architecture(
                arrangement: arrangement, machines: machineRepresentations, name: .arrangement1
            ),
            let pingMachine = machineRepresentations[.testMachine]
        else {
            XCTFail("Couldn't create architecture!")
            return
        }
        let signalStatements = arrangement.signals.map {
            HeadStatement.definition(value: .signal(value: $0))
        }
        let expectedHead = ArchitectureHead(statements: signalStatements + [
            HeadStatement.definition(value: .component(
                value: ComponentDefinition(name: .pingMachine, port: pingMachine.entity.port)
            ))
        ])
        XCTAssertEqual(architecture.head, expectedHead)
        let component = ComponentInstantiation(
            label: .testMachine, name: .pingMachine, port: pingComponent.port
        )
        let expectedBody = AsynchronousBlock.component(block: component)
        XCTAssertEqual(architecture.body, expectedBody)
        XCTAssertEqual(architecture.entity, .arrangement1)
        XCTAssertEqual(architecture.name, .behavioral)
    }

    /// Test that the arrangement returns `nil` when the machines don't match the arrangement passed.
    func testArrangementInitDetectsDifferentInstances() {
        var machines = machineRepresentations
        machines[.pingMachine] = MachineRepresentation(machine: .testMachine(), name: .testMachine)
        XCTAssertNil(Architecture(arrangement: arrangement, machines: machines, name: .arrangement1))
    }

    /// Test the machines must match the arrangement machines.
    func testArrangementInitChecksMachineCount() {
        var machines = machineRepresentations
        machines[.testMachine] = MachineRepresentation(machine: .testMachine(), name: .testMachine)
        XCTAssertNil(Architecture(arrangement: arrangement, machines: machines, name: .arrangement1))
        machines[.pingMachine] = nil
        machines[.testMachine] = nil
        XCTAssertNil(Architecture(arrangement: arrangement, machines: machines, name: .arrangement1))
        XCTAssertNil(Architecture(arrangement: arrangement, machines: [:], name: .arrangement1))
    }

    // swiftlint:disable function_body_length

    /// Test arrangement init makes signals open when not mapped.
    func testArrangementHandlesSignalsNotMapped() {
        var mappings = arrangement.machines
        mappings[MachineInstance(name: .pingMachine, type: .pingMachine)] = MachineMapping(
            machine: PingPongArrangement().pingMachine, mappings: []
        )
        arrangement = Arrangement(
            machines: mappings,
            externalSignals: arrangement.externalSignals,
            signals: arrangement.signals,
            clocks: arrangement.clocks
        )
        guard
            let architecture = Architecture(
                arrangement: arrangement, machines: machineRepresentations, name: .arrangement1
            ),
            let pingMachine = machineRepresentations[.pingMachine],
            let pongMachine = machineRepresentations[.pongMachine]
        else {
            XCTFail("Failed to create architecture!")
            return
        }
        let signalStatements = arrangement.signals.map {
            HeadStatement.definition(value: .signal(value: $0))
        }
        let expectedHead = ArchitectureHead(statements: signalStatements + [
            HeadStatement.definition(value: .component(
                value: ComponentDefinition(name: .pingMachine, port: pingMachine.entity.port)
            )),
            HeadStatement.definition(value: .component(
                value: ComponentDefinition(name: .pongMachine, port: pongMachine.entity.port)
            ))
        ])
        XCTAssertEqual(architecture.head, expectedHead)
        let ping2Instance = AsynchronousBlock.component(block: ComponentInstantiation(
            label: .pingMachine,
            name: pingComponent.name,
            port: PortMap(variables: [
                VariableMap(
                    lhs: .variable(reference: .variable(name: .clk)),
                    rhs: .open
                ),
                VariableMap(
                    lhs: .variable(reference: .variable(name: .externalPing)),
                    rhs: .open
                ),
                VariableMap(
                    lhs: .variable(reference: .variable(name: .externalPong)),
                    rhs: .open
                )
            ])
        ))
        let expectedBody = AsynchronousBlock.blocks(blocks: [ping2Instance, pongInstance])
        XCTAssertEqual(architecture.body, expectedBody)
        XCTAssertEqual(architecture.entity, .arrangement1)
        XCTAssertEqual(architecture.name, .behavioral)
    }

    // swiftlint:enable function_body_length

    /// Test the arrangement init detects invalid additional mappings.
    func testArrangementInitWithAdditionalMappings() {
        var representations = machineRepresentations
        representations[.pongMachine] = nil
        XCTAssertNil(Architecture(arrangement: arrangement, machines: representations, name: .arrangement1))
        representations[.testMachine] = MachineRepresentation(machine: .testMachine(), name: .testMachine)
        XCTAssertNotNil(representations[.testMachine])
        XCTAssertNil(Architecture(arrangement: arrangement, machines: representations, name: .arrangement1))
    }

}
