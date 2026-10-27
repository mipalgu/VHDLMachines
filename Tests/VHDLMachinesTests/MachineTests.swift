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

import Foundation
import Testing
@testable import VHDLMachines
import VHDLParsing

// swiftlint:disable type_body_length

/// Tests the ``Machine`` type.
@Suite
struct MachineTests {

    // swiftlint:disable force_unwrapping

    /// The machines name.
    let machineName = VariableName(rawValue: "M0")!

    /// The path to the machine.
    let path = URL(fileURLWithPath: "/path/to/M0")

    /// The includes for the machine.
    let includes: [Include] = [
        .include(statement: UseStatement(rawValue: "use IEEE.STD_LOGIC_1164.ALL;")!),
        .include(statement: UseStatement(rawValue: "use IEEE.NUMERIC_STD.ALL;")!),
    ]

    // swiftlint:enable force_unwrapping

    /// The external signals for the machine.
    let externalSignals = [
        PortSignal(
            type: .stdLogic,
            name: VariableName.a,
            mode: .input,
            defaultValue: .literal(value: .logic(value: .low)),
            comment: Comment.comment
        )
    ]

    /// The clocks for the machine.
    let clocks = [
        Clock(name: VariableName.clk, frequency: 50, unit: .MHz)
    ]

    /// The driving clock for the machine.
    let drivingClock = 0

    // swiftlint:disable force_unwrapping

    /// The paths to the dependent machines.
    let dependentMachines: [VariableName: URL] = [
        VariableName(rawValue: "M1")!: URL(fileURLWithPath: "/path/to/M1"),
        VariableName(rawValue: "M2")!: URL(fileURLWithPath: "/path/to/M2"),
    ]

    // swiftlint:enable force_unwrapping

    /// The signals for the machine.
    let machineSignals: [LocalSignal] = [
        LocalSignal(
            type: .stdLogic,
            name: VariableName.s,
            defaultValue: .literal(value: .logic(value: .low)),
            comment: Comment.signalS
        )
    ]

    /// The parameters for the machine.
    let parameterSignals: [Parameter] = [
        Parameter(
            type: .stdLogic,
            name: VariableName.p,
            defaultValue: .literal(value: .logic(value: .low)),
            comment: Comment.parameterP
        )
    ]

    /// The returnable signals for the machine.
    let returnableSignals: [ReturnableVariable] = [
        ReturnableVariable(
            type: .stdLogic,
            name: VariableName.r,
            comment: Comment.returnableR
        )
    ]

    /// The states in the machine.
    let states: [State] = [
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

    /// The transitions in the machine.
    let transitions: [Transition] = [
        Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1),
        Transition(condition: .conditional(condition: .literal(value: true)), source: 1, target: 0),
    ]

    /// The index of the initial state.
    let initialState = 0

    /// The index of the suspended state.
    let suspendedState = 1

    /// The architecture head for the machine.
    let architectureHead: [HeadStatement] = [
        .definition(
            value: .signal(value: LocalSignal(type: .stdLogic, name: .s, defaultValue: nil, comment: nil))
        )
    ]

    /// The architecture body for the machine.
    let architectureBody: AsynchronousBlock = .statement(
        statement: .assignment(
            name: .variable(reference: .variable(name: .s)),
            value: .expression(value: .literal(value: .bit(value: .high)))
        )
    )

    /// The default actions in a state.
    let actions: [VariableName] = [
        .onEntry, .onExit, .internal, .onResume, .onSuspend,
    ]

    /// The machine to test.
    var machine: Machine

    /// Initialises the test.
    init() {
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
    @Test
    func testInit() {
        #expect(machine.includes == includes)
        #expect(machine.externalSignals == externalSignals)
        #expect(machine.clocks == clocks)
        #expect(machine.drivingClock == drivingClock)
        #expect(machine.machineSignals == machineSignals)
        #expect(machine.isParameterised)
        #expect(machine.isSuspensible)
        #expect(machine.parameterSignals == parameterSignals)
        #expect(machine.returnableSignals == returnableSignals)
        #expect(machine.states == states)
        #expect(machine.transitions == transitions)
        #expect(machine.initialState == initialState)
        #expect(machine.suspendedState == suspendedState)
        #expect(machine.architectureHead == architectureHead)
        #expect(machine.architectureBody == architectureBody)
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable force_unwrapping

    /// Test getters and setters work.
    @Test
    mutating func testGettersAndSetters() {
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
        #expect(machine.includes == newIncludes)
        #expect(machine.externalSignals == newExternalSignals)
        #expect(machine.clocks == newClocks)
        #expect(machine.drivingClock == newDrivingClock)
        #expect(machine.machineSignals == newMachineSignals)
        #expect(machine.parameterSignals == newParameterSignals)
        #expect(machine.returnableSignals == newReturnableSignals)
        #expect(machine.states == newStates)
        #expect(machine.transitions == newTransitions)
        #expect(machine.initialState == newInitialState)
        #expect(machine.suspendedState == newSuspendedState)
        #expect(machine.architectureHead == newArchitectureHead)
        #expect(machine.architectureBody == newArchitectureBody)
    }

    /// Test initial machine is setup correctly.
    @Test
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
        #expect(machine == expected)
    }

    /// Test `isParameterised` setter.
    @Test
    mutating func testIsParameterisedSetter() {
        #expect(machine.isParameterised)
        #expect(machine.suspendedState == 1)
        machine.isParameterised = false
        #expect(!machine.isParameterised)
        #expect(machine.suspendedState == 1)
        machine.suspendedState = nil
        #expect(machine.suspendedState == nil)
        #expect(!machine.isParameterised)
        machine.isParameterised = true
        #expect(!machine.isParameterised)
        #expect(machine.suspendedState == nil)
        machine.suspendedState = 1
        #expect(machine.suspendedState == 1)
        #expect(!machine.isParameterised)
        machine.isParameterised = true
        #expect(machine.isParameterised)
        #expect(machine.suspendedState == 1)
    }

    // swiftlint:enable force_unwrapping
    // swiftlint:enable function_body_length

}

// swiftlint:enable type_body_length
