// ArrayTests.swift
// VHDLMachines
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

import LLFSMModel
@testable import ModelImports
import TestUtils
import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for `Array` extensions.
final class ArrayTests: XCTestCase {

    /// An array of `LLFSMModel.Variable`'s to use as test data.
    let variables = [
        Variable(defaultValue: "'1'", name: "x", type: "std_logic"),
        Variable(defaultValue: "'0'", name: "y", type: "std_logic")
    ]

    /// The expected values from the converted `variables`.
    let expected = [
        LocalSignal(
            type: .stdLogic, name: .x, defaultValue: .literal(value: .bit(value: .high)), comment: nil
        ),
        LocalSignal(
            type: .stdLogic, name: .y, defaultValue: .literal(value: .bit(value: .low)), comment: nil
        )
    ]

    /// Test the `init(convert:)` correctly converts all elements.
    func testConvertInit() {
        let signals = [LocalSignal](convert: variables)
        XCTAssertEqual(signals, expected)
    }

    /// Test `init(convert:)` returns nil for inccorect element.
    func testConvertInitReturnsNil() {
        XCTAssertNil([LocalSignal](convert: [variables[0], Variable(name: "1y", type: "std_logic")]))
    }

    /// Test `init(states:,machine:)` creates transition correctly.
    func testTransitionInit() {
        let testMachine = VHDLMachines.Machine.testMachine()
        let transitions = [VHDLMachines.Transition](
            states: testMachine.states, machine: LLFSMModel.Machine.testMachine
        )
        XCTAssertEqual(testMachine.transitions, transitions)
    }

    /// Test `init(states:,machine:)` returns nil when a transition is incorrect.
    func testTransitionInitReturnsNil() {
        let testMachine = VHDLMachines.Machine.testMachine()
        let oldMachine = LLFSMModel.Machine.testMachine
        let oldState = oldMachine.states[0]
        let newState = LLFSMModel.State(
            actions: oldState.actions,
            externalVariables: oldState.externalVariables,
            name: oldState.name,
            transitions: oldState.transitions + [LLFSMModel.Transition(target: "Null", condition: "true")],
            variables: oldState.variables
        )
        let newMachine = LLFSMModel.Machine(
            externalVariables: oldMachine.externalVariables,
            globalVariables: oldMachine.globalVariables,
            initialState: oldMachine.initialState,
            name: oldMachine.name,
            parameters: oldMachine.parameters,
            returnables: oldMachine.returnables,
            states: [newState, oldMachine.states[1], oldMachine.states[2]],
            suspendedState: oldMachine.suspendedState,
            variables: oldMachine.variables
        )
        XCTAssertNil([VHDLMachines.Transition](states: testMachine.states, machine: newMachine))
    }

}
