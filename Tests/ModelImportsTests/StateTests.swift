// StateTests.swift
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
import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for `State` extensions.
final class StateTests: XCTestCase {

    /// The available external variables.
    let externals = [PortSignal(type: .stdLogic, name: .x, mode: .input)]

    /// A `LLFSMModel.State` instance used as test data.
    let state = LLFSMModel.State(
        actions: ["OnEntry": "y <= x;"],
        externalVariables: ["x"],
        name: "Initial",
        transitions: [LLFSMModel.Transition(target: "Suspended", condition: "true")],
        variables: [LLFSMModel.Variable(name: "y", type: "std_logic")]
    )

    /// The expected data.
    var expected = VHDLMachines.State(
        name: .initial,
        actions: [
            .onEntry: .statement(statement: .assignment(
                name: .variable(reference: .variable(name: .y)),
                value: .reference(variable: .variable(reference: .variable(name: .x)))
            ))
        ],
        signals: [LocalSignal(type: .stdLogic, name: .y)],
        externalVariables: [.x]
    )

    /// Initialise the test data for each test.
    override func setUp() {
        expected = VHDLMachines.State(
            name: .initial,
            actions: [
                .onEntry: .statement(statement: .assignment(
                    name: .variable(reference: .variable(name: .y)),
                    value: .reference(variable: .variable(reference: .variable(name: .x)))
                ))
            ],
            signals: [LocalSignal(type: .stdLogic, name: .y)],
            externalVariables: [.x]
        )
    }

    /// Test `init(state:)` correctly converts the state.
    func testInit() {
        guard let state = VHDLMachines.State(state: state, externalVariables: externals) else {
            XCTFail("Failed to create state.")
            return
        }
        XCTAssertEqual(state, expected)
    }

    /// Test `init(state:)` returns `nil` for invalid name.
    func testInitInvalidName() {
        let state = LLFSMModel.State(
            actions: state.actions,
            externalVariables: state.externalVariables,
            name: "1Invalid",
            transitions: state.transitions,
            variables: state.variables
        )
        XCTAssertNil(VHDLMachines.State(state: state, externalVariables: externals))
    }

    /// Test `init(state:)` returns `nil` for invalid actions.
    func testInitInvalidActions() {
        let state = LLFSMModel.State(
            actions: ["1Invalid": "y <= x;"],
            externalVariables: state.externalVariables,
            name: state.name,
            transitions: state.transitions,
            variables: state.variables
        )
        XCTAssertNil(VHDLMachines.State(state: state, externalVariables: externals))
    }

    /// Test `init(state:)` returns `nil` for invalid action code.
    func testInitInvalidActionCode() {
        let state = LLFSMModel.State(
            actions: ["OnEntry": "y <= 1Invalid;"],
            externalVariables: state.externalVariables,
            name: state.name,
            transitions: state.transitions,
            variables: state.variables
        )
        XCTAssertNil(VHDLMachines.State(state: state, externalVariables: externals))
    }

    /// Test `init(state:)` returns `nil` for invalid external variable names.
    func testInitInvalidExternalVariableNames() {
        let state = LLFSMModel.State(
            actions: state.actions,
            externalVariables: ["1Invalid"],
            name: state.name,
            transitions: state.transitions,
            variables: state.variables
        )
        XCTAssertNil(VHDLMachines.State(state: state, externalVariables: externals))
    }

    /// Test `init(state:)` returns `nil` for external variables that don't exist.
    func testInitInvalidExternalVariables() {
        let state = LLFSMModel.State(
            actions: state.actions,
            externalVariables: ["y"],
            name: state.name,
            transitions: state.transitions,
            variables: state.variables
        )
        XCTAssertNil(VHDLMachines.State(state: state, externalVariables: externals))
        XCTAssertNil(VHDLMachines.State(state: self.state, externalVariables: []))
    }

    /// Test `init(state:)` returns `nil` for invalid signals.
    func testInitInvalidSignals() {
        let state = LLFSMModel.State(
            actions: state.actions,
            externalVariables: state.externalVariables,
            name: state.name,
            transitions: state.transitions,
            variables: [LLFSMModel.Variable(name: "1Invalid", type: "std_logic")]
        )
        XCTAssertNil(VHDLMachines.State(state: state, externalVariables: externals))
    }

    /// Test `init(state:)` returns correct actions when code is empty.
    func testInitEmptyActions() {
        let state = LLFSMModel.State(
            actions: ["OnEntry": "", "OnExit": "y <= x;"],
            externalVariables: state.externalVariables,
            name: state.name,
            transitions: state.transitions,
            variables: state.variables
        )
        guard let state = VHDLMachines.State(state: state, externalVariables: externals) else {
            XCTFail("Failed to create state.")
            return
        }
        expected.actions = [
            .onExit: .statement(statement: .assignment(
                name: .variable(reference: .variable(name: .y)),
                value: .reference(variable: .variable(reference: .variable(name: .x)))
            ))
        ]
        XCTAssertEqual(state, expected)
    }

}
