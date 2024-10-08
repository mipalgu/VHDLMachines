// MachineTests.swift
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

@testable import VHDLMachines
import VHDLParsing
import XCTest

// swiftlint:disable type_body_length

/// Tests the ``Machine`` type.
final class MachineTests: XCTestCase {

    // swiftlint:disable force_unwrapping

    /// The machines name.
    var machineName: VariableName {
        VariableName(rawValue: "M0")!
    }

    /// The path to the machine.
    var path: URL {
        URL(fileURLWithPath: "/path/to/M0")
    }

    /// The includes for the machine.
    var includes: [Include] {
        [
            .include(statement: UseStatement(rawValue: "use IEEE.STD_LOGIC_1164.ALL;")!),
            .include(statement: UseStatement(rawValue: "use IEEE.NUMERIC_STD.ALL;")!),
        ]
    }

    // swiftlint:enable force_unwrapping

    /// The external signals for the machine.
    var externalSignals: [PortSignal] {
        [
            PortSignal(
                type: .stdLogic,
                name: VariableName.a,
                mode: .input,
                defaultValue: .literal(value: .logic(value: .low)),
                comment: Comment.comment
            )
        ]
    }

    /// The clocks for the machine.
    var clocks: [Clock] {
        [
            Clock(name: VariableName.clk, frequency: 50, unit: .MHz)
        ]
    }

    /// The driving clock for the machine.
    var drivingClock: Int {
        0
    }

    // swiftlint:disable force_unwrapping

    /// The paths to the dependent machines.
    var dependentMachines: [VariableName: URL] {
        [
            VariableName(rawValue: "M1")!: URL(fileURLWithPath: "/path/to/M1"),
            VariableName(rawValue: "M2")!: URL(fileURLWithPath: "/path/to/M2"),
        ]
    }

    // swiftlint:enable force_unwrapping

    /// The signals for the machine.
    var machineSignals: [LocalSignal] {
        [
            LocalSignal(
                type: .stdLogic,
                name: VariableName.s,
                defaultValue: .literal(value: .logic(value: .low)),
                comment: Comment.signalS
            )
        ]
    }

    /// The parameters for the machine.
    var parameterSignals: [Parameter] {
        [
            Parameter(
                type: .stdLogic,
                name: VariableName.p,
                defaultValue: .literal(value: .logic(value: .low)),
                comment: Comment.parameterP
            )
        ]
    }

    /// The returnable signals for the machine.
    var returnableSignals: [ReturnableVariable] {
        [
            ReturnableVariable(
                type: .stdLogic,
                name: VariableName.r,
                comment: Comment.returnableR
            )
        ]
    }

    /// The states in the machine.
    var states: [State] {
        [
            State(
                name: VariableName.s0,
                actions: [:],
                signals: [],
                externalVariables: []
            ),
            State(
                name: VariableName.s1,
                actions: [:],
                signals: [],
                externalVariables: []
            ),
        ]
    }

    /// The transitions in the machine.
    var transitions: [Transition] {
        [
            Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1),
            Transition(condition: .conditional(condition: .literal(value: true)), source: 1, target: 0),
        ]
    }

    /// The index of the initial state.
    var initialState: Int {
        0
    }

    /// The index of the suspended state.
    var suspendedState: Int {
        1
    }

    /// The architecture head for the machine.
    var architectureHead: [HeadStatement] {
        [
            .definition(
                value: .signal(value: LocalSignal(type: .stdLogic, name: .s, defaultValue: nil, comment: nil))
            )
        ]
    }

    /// The architecture body for the machine.
    var architectureBody: AsynchronousBlock {
        .statement(
            statement: .assignment(
                name: .variable(reference: .variable(name: .s)),
                value: .expression(value: .literal(value: .bit(value: .high)))
            )
        )
    }

    /// The default actions in a state.
    var actions: [VariableName] {
        [.onEntry, .onExit, .internal, .onResume, .onSuspend]
    }

    /// The machine to test.
    lazy var machine = Machine(
        actions: actions,
        includes: includes,
        externalSignals: externalSignals,
        clocks: clocks,
        drivingClock: drivingClock,
        machineSignals: machineSignals,
        isParameterised: true,
        parameterSignals: parameterSignals,
        returnableSignals: returnableSignals,
        states: states,
        transitions: transitions,
        initialState: initialState,
        suspendedState: suspendedState,
        architectureHead: architectureHead,
        architectureBody: architectureBody
    )

    /// Initialises the test.
    override func setUp() {
        self.machine = Machine(
            actions: actions,
            includes: includes,
            externalSignals: externalSignals,
            clocks: clocks,
            drivingClock: drivingClock,
            machineSignals: machineSignals,
            isParameterised: true,
            parameterSignals: parameterSignals,
            returnableSignals: returnableSignals,
            states: states,
            transitions: transitions,
            initialState: initialState,
            suspendedState: suspendedState,
            architectureHead: architectureHead,
            architectureBody: architectureBody
        )
    }

    /// Test init sets the correct values.
    func testInit() {
        XCTAssertEqual(machine.includes, includes)
        XCTAssertEqual(machine.externalSignals, externalSignals)
        XCTAssertEqual(machine.clocks, clocks)
        XCTAssertEqual(machine.drivingClock, drivingClock)
        XCTAssertEqual(machine.machineSignals, machineSignals)
        XCTAssertTrue(machine.isParameterised)
        XCTAssertTrue(machine.isSuspensible)
        XCTAssertEqual(machine.parameterSignals, parameterSignals)
        XCTAssertEqual(machine.returnableSignals, returnableSignals)
        XCTAssertEqual(machine.states, states)
        XCTAssertEqual(machine.transitions, transitions)
        XCTAssertEqual(machine.initialState, initialState)
        XCTAssertEqual(machine.suspendedState, suspendedState)
        XCTAssertEqual(machine.architectureHead, architectureHead)
        XCTAssertEqual(machine.architectureBody, architectureBody)
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable force_unwrapping

    /// Test getters and setters work.
    func testGettersAndSetters() {
        let newIncludes = [
            Include.include(statement: UseStatement(rawValue: "use IEEE.STD_LOGIC_1164.ALL;")!)
        ]
        let newExternalSignals = [
            PortSignal(
                type: .stdLogic,
                name: VariableName(rawValue: "B")!,
                mode: .input,
                defaultValue: .literal(value: .logic(value: .low)),
                comment: Comment.comment
            )
        ]
        let newClocks = [
            Clock(name: VariableName.clk, frequency: 50, unit: .MHz),
            Clock(name: VariableName.clk2, frequency: 100, unit: .MHz),
        ]
        let newDrivingClock = 1
        let newMachineSignals = [
            LocalSignal(
                type: .stdLogic,
                name: VariableName(rawValue: "s2")!,
                defaultValue: .literal(value: .logic(value: .low)),
                comment: Comment(rawValue: "-- Signal s2")!
            )
        ]
        let newParameterSignals = [
            Parameter(
                type: .stdLogic,
                name: VariableName(rawValue: "p2")!,
                defaultValue: .literal(value: .logic(value: .low)),
                comment: Comment(rawValue: "-- Parameter p2")!
            )
        ]
        let newReturnableSignals = [
            ReturnableVariable(
                type: .stdLogic,
                name: VariableName(rawValue: "r2")!,
                comment: Comment(rawValue: "-- Returnable r2")!
            )
        ]
        let newStates = [
            State(
                name: VariableName.s0,
                actions: [:],
                signals: [],
                externalVariables: []
            )
        ]
        let newTransitions = [
            Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1)
        ]
        let newInitialState = 1
        let newSuspendedState = 0
        let newArchitectureHead = [
            HeadStatement.definition(
                value: .signal(
                    value: LocalSignal(type: .stdLogic, name: .g, defaultValue: nil, comment: nil)
                )
            )
        ]
        let newArchitectureBody = AsynchronousBlock.statement(
            statement: .assignment(
                name: .variable(reference: .variable(name: .g)),
                value: .expression(value: .literal(value: .bit(value: .low)))
            )
        )
        machine.includes = newIncludes
        machine.externalSignals = newExternalSignals
        machine.clocks = newClocks
        machine.drivingClock = newDrivingClock
        machine.machineSignals = newMachineSignals
        machine.parameterSignals = newParameterSignals
        machine.returnableSignals = newReturnableSignals
        machine.states = newStates
        machine.transitions = newTransitions
        machine.initialState = newInitialState
        machine.suspendedState = newSuspendedState
        machine.architectureHead = newArchitectureHead
        machine.architectureBody = newArchitectureBody
        XCTAssertEqual(machine.includes, newIncludes)
        XCTAssertEqual(machine.externalSignals, newExternalSignals)
        XCTAssertEqual(machine.clocks, newClocks)
        XCTAssertEqual(machine.drivingClock, newDrivingClock)
        XCTAssertEqual(machine.machineSignals, newMachineSignals)
        XCTAssertEqual(machine.parameterSignals, newParameterSignals)
        XCTAssertEqual(machine.returnableSignals, newReturnableSignals)
        XCTAssertEqual(machine.states, newStates)
        XCTAssertEqual(machine.transitions, newTransitions)
        XCTAssertEqual(machine.initialState, newInitialState)
        XCTAssertEqual(machine.suspendedState, newSuspendedState)
        XCTAssertEqual(machine.architectureHead, newArchitectureHead)
        XCTAssertEqual(machine.architectureBody, newArchitectureBody)
    }

    /// Test initial machine is setup correctly.
    func testInitialSuspensible() {
        let machine = Machine.initialSuspensible
        let expected = Machine(
            actions: actions,
            includes: [
                .library(value: VariableName(rawValue: "IEEE")!),
                .include(statement: UseStatement(rawValue: "use IEEE.std_logic_1164.All;")!),
                .include(statement: UseStatement(rawValue: "use IEEE.math_real.All;")!),
            ],
            externalSignals: [],
            clocks: [Clock(name: VariableName.clk, frequency: 50, unit: .MHz)],
            drivingClock: 0,
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [
                State(
                    name: VariableName.initial,
                    actions: [:],
                    signals: [],
                    externalVariables: []
                ),
                State(
                    name: VariableName.suspendedState,
                    actions: [:],
                    signals: [],
                    externalVariables: []
                ),
            ],
            transitions: [],
            initialState: 0,
            suspendedState: 1
        )
        XCTAssertEqual(machine, expected)
    }

    /// Test `isParameterised` setter.
    func testIsParameterisedSetter() {
        XCTAssertTrue(machine.isParameterised)
        XCTAssertEqual(machine.suspendedState, 1)
        machine.isParameterised = false
        XCTAssertFalse(machine.isParameterised)
        XCTAssertEqual(machine.suspendedState, 1)
        machine.suspendedState = nil
        XCTAssertNil(machine.suspendedState)
        XCTAssertFalse(machine.isParameterised)
        machine.isParameterised = true
        XCTAssertFalse(machine.isParameterised)
        XCTAssertNil(machine.suspendedState)
        machine.suspendedState = 1
        XCTAssertEqual(machine.suspendedState, 1)
        XCTAssertFalse(machine.isParameterised)
        machine.isParameterised = true
        XCTAssertTrue(machine.isParameterised)
        XCTAssertEqual(machine.suspendedState, 1)
    }

    // swiftlint:enable force_unwrapping
    // swiftlint:enable function_body_length

}

// swiftlint:enable type_body_length
