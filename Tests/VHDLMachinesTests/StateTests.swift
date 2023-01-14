// StateTests.swift
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
import XCTest

/// Tests the ``State`` type.
final class StateTests: XCTestCase {

    /// The state actions.
    var actions: [ActionName: String] {
        [ActionName(text: "onEntry"): "x := x + 1;", ActionName(text: "onExit"): "x := 0;"]
    }

    /// The order in which the actions should be executed.
    var actionOrder: [[ActionName]] {
        [[ActionName(text: "onEntry"), ActionName(text: "onExit")]]
    }

    /// The signals.
    var signals: [LocalSignal] {
        [
            LocalSignal(
                type: .stdLogic,
                name: VariableName(text: "y"),
                defaultValue: .literal(value: .logic(value: .high)),
                comment: Comment(text: "The signal y.")
            )
        ]
    }

    /// The external variables.
    var externalVariables: [String] {
        ["A"]
    }

    /// The state to test.
    lazy var state = State(
        name: VariableName(text: "S0"),
        actions: actions,
        actionOrder: actionOrder,
        signals: signals,
        externalVariables: externalVariables
    )

    /// Initialises the state to test.
    override func setUp() {
        self.state = State(
            name: VariableName(text: "S0"),
            actions: actions,
            actionOrder: actionOrder,
            signals: signals,
            externalVariables: externalVariables
        )
    }

    /// Test init sets the properties correctly.
    func testInit() {
        XCTAssertEqual(self.state.name, VariableName(text: "S0"))
        XCTAssertEqual(self.state.actions, self.actions)
        XCTAssertEqual(self.state.actionOrder, self.actionOrder)
        XCTAssertEqual(self.state.signals, self.signals)
        XCTAssertEqual(self.state.externalVariables, self.externalVariables)
    }

    /// Test getters and setters work correctly.
    func testGettersAndSetters() {
        self.state.name = VariableName(text: "S1")
        XCTAssertEqual(self.state.name, VariableName(text: "S1"))
        self.state.actions = [ActionName(text: "internal"): "x := 0;"]
        XCTAssertEqual(self.state.actions, [ActionName(text: "internal"): "x := 0;"])
        self.state.actionOrder = [[ActionName(text: "internal")]]
        XCTAssertEqual(self.state.actionOrder, [[ActionName(text: "internal")]])
        self.state.signals = [
            LocalSignal(
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                name: VariableName(text: "xs"),
                defaultValue: .literal(value: .vector(value: .hexademical(value: [.five]))),
                comment: Comment(text: "The signal xs.")
            )
        ]
        XCTAssertEqual(
            self.state.signals,
            [
                LocalSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                    name: VariableName(text: "xs"),
                    defaultValue: .literal(value: .vector(value: .hexademical(value: [.five]))),
                    comment: Comment(text: "The signal xs.")
                )
            ]
        )
        self.state.externalVariables = ["B"]
        XCTAssertEqual(self.state.externalVariables, ["B"])
    }

}
