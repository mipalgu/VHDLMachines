// TransitionTests.swift
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

/// Test class for `VHDLMachines.Transition` extensions.
final class TransitionTests: XCTestCase {

    /// A test machine.
    let testMachine = VHDLMachines.Machine.testMachine()

    /// Some machine states.
    var states: [VHDLMachines.State] {
        testMachine.states
    }

    /// The name of state 0.
    var state0: VariableName {
        states[0].name
    }

    /// The name of state 1.
    var state1: VariableName {
        states[1].name
    }

    /// A transition from state 0 to state 1.
    lazy var transition = LLFSMModel.Transition(target: state1.rawValue, condition: "true")

    /// Initialise the test data before each test.
    override func setUp() {
        transition = LLFSMModel.Transition(target: state1.rawValue, condition: "true")
    }

    /// Test that `init(transition:,source:states:)` creates the transition correctly.
    func testInit() {
        guard let transition = VHDLMachines.Transition(
            transition: transition, source: state0.rawValue, states: states
        ) else {
            XCTFail("Failed to create transition.")
            return
        }
        XCTAssertEqual(transition.condition, .conditional(condition: .literal(value: true)))
        XCTAssertEqual(transition.source, 0)
        XCTAssertEqual(transition.target, 1)
    }

    /// Test that `init(transition:,source:states:)` returns `nil` when the source state is not found.
    func testInitWithInvalidSource() {
        XCTAssertNil(VHDLMachines.Transition(transition: transition, source: "invalid", states: states))
    }

    /// Test that `init(transition:,source:states:)` returns `nil` when the target state is not found.
    func testInitWithInvalidTarget() {
        let rawTransition = LLFSMModel.Transition(target: "invalid", condition: "true")
        XCTAssertNil(
            VHDLMachines.Transition(transition: rawTransition, source: state0.rawValue, states: states)
        )
    }

    /// Test that `init(transition:,source:states:)` returns `nil` when the condition is invalid.
    func testInitWithInvalidCondition() {
        let rawTransition = LLFSMModel.Transition(target: state1.rawValue, condition: "invalid and2 invalid2")
        XCTAssertNil(
            VHDLMachines.Transition(transition: rawTransition, source: state0.rawValue, states: states)
        )
    }

    /// Test that `init(transition:,source:states:)` returns `nil` when the target name is incorrect.
    func testInitWithIncorrectTargetName() {
        let rawTransition = LLFSMModel.Transition(target: "1State", condition: "true")
        XCTAssertNil(
            VHDLMachines.Transition(transition: rawTransition, source: state0.rawValue, states: states)
        )
    }

    /// Test that `init(transition:,source:states:)` returns `nil` when the source name is incorrect.
    func testInitWithIncorrectSourceName() {
        XCTAssertNil(
            VHDLMachines.Transition(transition: transition, source: "0State", states: states)
        )
    }

}
