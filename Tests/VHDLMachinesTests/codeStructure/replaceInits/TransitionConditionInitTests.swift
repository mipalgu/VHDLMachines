// TransitionConditionInitTests.swift
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

@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for ``TransitionCondition`` replace initialiser.
final class TransitionConditionInitTests: XCTestCase {

    /// An `x` variable.
    let x = Expression.reference(variable: .variable(reference: .variable(name: .x)))

    /// A `y` variable.
    let y = Expression.reference(variable: .variable(reference: .variable(name: .y)))

    /// An `x` variable.
    let xC = TransitionCondition.variable(name: .x)

    /// A `y` variable.
    let yC = TransitionCondition.variable(name: .y)

    // swiftlint:disable force_unwrapping

    /// The new name for variable `x`.
    let newX = VariableName(rawValue: "STATE_Initial_x")!

    // swiftlint:enable force_unwrapping

    /// `newX` as an expression.
    var expNewX: Expression {
        .reference(variable: .variable(reference: .variable(name: newX)))
    }

    /// `newX` as a ``TransitionCondition``.
    var tcNewX: TransitionCondition {
        .variable(name: newX)
    }

    /// Test the `after` case.
    func testAfter() {
        let original = TransitionCondition.after(statement: AfterStatement(amount: x, period: .ns))
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.after(statement: AfterStatement(amount: expNewX, period: .ns))
        )
    }

    /// Test the `and` case.
    func testAnd() {
        let original = TransitionCondition.and(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.and(lhs: tcNewX, rhs: yC)
        )
    }

    /// Test the `boolean` case.
    func testBoolean() {
        let original = TransitionCondition.boolean(expression: BooleanExpression.not(value: x))
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.boolean(expression: .not(value: expNewX))
        )
    }

    /// Test the `conditional` case.
    func testConditional() {
        let original = TransitionCondition.conditional(condition: .edge(value: .rising(expression: x)))
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.conditional(condition: .edge(value: .rising(expression: expNewX)))
        )
    }

    /// Test the `equals` case.
    func testEquals() {
        let original = TransitionCondition.equals(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.equals(lhs: tcNewX, rhs: yC)
        )
    }

    /// Test the `nand` case.
    func testNand() {
        let original = TransitionCondition.nand(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.nand(lhs: tcNewX, rhs: yC)
        )
    }

    /// Test the `nor` case.
    func testNor() {
        let original = TransitionCondition.nor(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.nor(lhs: tcNewX, rhs: yC)
        )
    }

    /// Test the `not` case.
    func testNot() {
        let original = TransitionCondition.not(value: xC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.not(value: tcNewX)
        )
    }

    /// Test the `notEquals` case.
    func testNotEquals() {
        let original = TransitionCondition.notEquals(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.notEquals(lhs: tcNewX, rhs: yC)
        )
    }

    /// Test the `or` case.
    func testOr() {
        let original = TransitionCondition.or(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.or(lhs: tcNewX, rhs: yC)
        )
    }

    /// Test the `precedence` case.
    func testPrecedence() {
        let original = TransitionCondition.precedence(condition: xC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.precedence(condition: tcNewX)
        )
    }

    /// Test the `variable` case.
    func testVariable() {
        let original = TransitionCondition.variable(name: .x)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.variable(name: newX)
        )
    }

    /// Test the `xnor` case.
    func testXnor() {
        let original = TransitionCondition.xnor(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.xnor(lhs: tcNewX, rhs: yC)
        )
    }

    /// Test the `xor` case.
    func testXor() {
        let original = TransitionCondition.xor(lhs: xC, rhs: yC)
        let result = TransitionCondition(condition: original, replacing: .x, with: newX)
        XCTAssertEqual(
            result, TransitionCondition.xor(lhs: tcNewX, rhs: yC)
        )
    }

}
