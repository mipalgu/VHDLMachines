// ArrangementTests.swift
// Machines
//
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
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

import TestUtils
@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Tests the ``Arrangement`` type.
final class ArrangementTests: XCTestCase {

    // swiftlint:disable force_unwrapping

    /// The machines in the arrangement.
    let machines = [
        MachineInstance(name: VariableName(rawValue: "M1")!, type: .pingMachine): MachineMapping(
            machine: PingPongArrangement().pingMachine,
            mappings: [
                VariableMapping(source: .x, destination: .ping),
                VariableMapping(source: .y, destination: .pong),
            ]
        ),
        MachineInstance(name: VariableName(rawValue: "M2")!, type: .pongMachine): MachineMapping(
            machine: PingPongArrangement().pongMachine,
            mappings: [
                VariableMapping(source: .x, destination: .ping),
                VariableMapping(source: .y, destination: .pong),
            ]
        ),
    ]

    /// The clocks in the arrangement.
    let clocks = [
        Clock(name: VariableName.clk, frequency: 100, unit: .MHz)
    ]

    /// The external signals in the arrangement.
    let externalSignals = [
        PortSignal(
            type: .stdLogic,
            name: VariableName.x,
            mode: .input,
            defaultValue: .literal(value: .logic(value: .high)),
            comment: Comment.signalX
        ),
        PortSignal(
            type: .stdLogic,
            name: VariableName.y,
            mode: .output,
            defaultValue: .literal(value: .logic(value: .low)),
            comment: Comment.signalY
        ),
        PortSignal(
            type: .stdLogic,
            name: VariableName.z,
            mode: .output,
            defaultValue: .literal(value: .logic(value: .low))
        ),
    ]

    /// The arrangement signals.
    let signals = [
        LocalSignal(
            type: .stdLogic,
            name: VariableName.a,
            defaultValue: .literal(value: .logic(value: .low)),
            comment: Comment.signalZ
        )
    ]

    /// The parent machines in the arrangement.
    let parents = [VariableName(rawValue: "M1")!]

    /// The path to the arrangement.
    let path = URL(fileURLWithPath: "/path/to/arrangement")

    /// The arrangement to test.
    lazy var arrangement = Arrangement(
        machines: machines,
        externalSignals: externalSignals,
        signals: signals,
        clocks: clocks
    )

    /// Initialises the arrangement to test.
    override func setUp() {
        self.arrangement = Arrangement(
            machines: machines,
            externalSignals: externalSignals,
            signals: signals,
            clocks: clocks
        )
    }

    /// Test init sets properties correctly.
    func testInit() {
        XCTAssertEqual(self.arrangement.machines, self.machines)
        XCTAssertEqual(self.arrangement.externalSignals, self.externalSignals)
        XCTAssertEqual(self.arrangement.signals, self.signals)
        XCTAssertEqual(self.arrangement.clocks, self.clocks)
    }

    /// Test that the public init sets the stored properties for a valid arrangement.
    func testPublicInit() {
        XCTAssertEqual(
            Arrangement(
                mappings: machines,
                externalSignals: externalSignals,
                signals: signals,
                clocks: clocks
            ),
            arrangement
        )
    }

    /// Test that the public init returns nil for same-typed machines with different implementations.
    func testInvalidTypedMachinesInPublicInit() {
        let arrangement = Arrangement(
            mappings: [
                MachineInstance(name: .machineSignal1, type: .pingMachine): MachineMapping(
                    machine: PingPongArrangement().pingMachine,
                    mappings: []
                ),
                MachineInstance(name: .machineSignal2, type: .pingMachine): MachineMapping(
                    machine: PingPongArrangement().pongMachine,
                    mappings: []
                ),
            ],
            externalSignals: externalSignals,
            signals: signals,
            clocks: clocks
        )
        XCTAssertNil(arrangement)
    }

    /// Make sure instance names are also unique.
    func testPublicInitDetectsDuplicateInstances() {
        let arrangement = Arrangement(
            mappings: [
                MachineInstance(name: .machineSignal1, type: .pingMachine): MachineMapping(
                    machine: PingPongArrangement().pingMachine,
                    mappings: []
                ),
                MachineInstance(name: .machineSignal1, type: .pongMachine): MachineMapping(
                    machine: PingPongArrangement().pongMachine,
                    mappings: []
                ),
            ],
            externalSignals: externalSignals,
            signals: signals,
            clocks: clocks
        )
        XCTAssertNil(arrangement)
    }

    /// Test that instance names are unique.
    func testNonUniqueInstanceNamesReturnsNil() {
        let arrangement = Arrangement(
            mappings: [
                MachineInstance(name: .pingMachine, type: .pingMachine): MachineMapping(
                    machine: PingPongArrangement().pingMachine,
                    mappings: []
                )
            ],
            externalSignals: externalSignals,
            signals: signals,
            clocks: clocks
        )
        XCTAssertNil(arrangement)
    }

    // /// Tests getters and setters update properties correctly.
    // func testGettersAndSetters() {
    //     let newMachines = [
    //         MachineInstance(name: VariableName(rawValue: "M3")!, type: .testMachine): MachineMapping(
    //             machine: PingPongArrangement().pingMachine, mappings: []
    //         )
    //     ]
    //     let newExternalSignals = [
    //         PortSignal(
    //             type: .stdLogic,
    //             name: VariableName.z,
    //             mode: .input,
    //             defaultValue: .literal(value: .logic(value: .high)),
    //             comment: Comment.signalZ
    //         ),
    //         PortSignal(
    //             type: .stdLogic,
    //             name: VariableName.z,
    //             mode: .output,
    //             defaultValue: .literal(value: .logic(value: .low)),
    //             comment: Comment.externalZ
    //         )
    //     ]

    //     let newSignals = [
    //         LocalSignal(
    //             type: .stdLogic,
    //             name: VariableName.y,
    //             defaultValue: .literal(value: .logic(value: .high)),
    //             comment: Comment.signalY
    //         )
    //     ]
    //     let newClocks = [
    //         Clock(name: VariableName.clk2, frequency: 100, unit: .MHz)
    //     ]
    //     self.arrangement.machines = newMachines
    //     self.arrangement.externalSignals = newExternalSignals
    //     self.arrangement.signals = newSignals
    //     self.arrangement.clocks = newClocks
    //     XCTAssertEqual(self.arrangement.machines, newMachines)
    //     XCTAssertEqual(self.arrangement.externalSignals, newExternalSignals)
    //     XCTAssertEqual(self.arrangement.signals, newSignals)
    //     XCTAssertEqual(self.arrangement.clocks, newClocks)
    // }

    // swiftlint:enable force_unwrapping

}
