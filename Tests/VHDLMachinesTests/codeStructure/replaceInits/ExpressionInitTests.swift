// ExpressionInitTests.swift
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

/// Test class for `Expression` replace initialiser.
final class ExpressionInitTests: XCTestCase {

    /// An `x` variable.
    let x = Expression.reference(variable: .variable(name: .x))

    /// A `y` variable.
    let y = Expression.reference(variable: .variable(name: .y))

    // swiftlint:disable force_unwrapping

    /// The new name for variable `x`.
    let newX = VariableName(rawValue: "STATE_Initial_x")!

    // swiftlint:enable force_unwrapping

    /// `newX` as an expression.
    var expNewX: Expression {
        .reference(variable: .variable(name: newX))
    }

    /// Test `binary` case.
    func testBinary() {
        let original = Expression.binary(operation: .addition(lhs: x, rhs: y))
        let result = Expression(expression: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .binary(operation: .addition(lhs: expNewX, rhs: y)))
    }

    /// Test `cast` case.
    func testCast() {
        let original = Expression.cast(operation: .bit(expression: x))
        let result = Expression(expression: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .cast(operation: .bit(expression: expNewX)))
    }

    /// Test `conditional` case.
    func testConditional() {
        let original = Expression.conditional(condition: .comparison(value: .equality(lhs: x, rhs: y)))
        let result = Expression(expression: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .conditional(condition: .comparison(value: .equality(lhs: expNewX, rhs: y))))
    }

    /// Test `functionCall` case.
    func testFunctionCall() {
        let original = Expression.functionCall(call: .mathReal(function: .ceil(expression: x)))
        let result = Expression(expression: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .functionCall(call: .mathReal(function: .ceil(expression: expNewX))))
    }

    /// Test `literal` does nothing.
    func testLiteral() {
        let original = Expression.literal(value: .integer(value: 1))
        let result = Expression(expression: original, replacing: .x, with: newX)
        XCTAssertEqual(result, original)
    }

    /// Test `logical` case.
    func testLogical() {
        let original = Expression.logical(operation: .and(lhs: x, rhs: y))
        let result = Expression(expression: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .logical(operation: .and(lhs: expNewX, rhs: y)))
    }

    /// Test `precedence` case.
    func testPrecedence() {
        let original = Expression.precedence(value: x)
        let result = Expression(expression: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .precedence(value: expNewX))
    }

    /// Test `reference case`.
    func testReference() {
        let result = Expression(expression: x, replacing: .x, with: newX)
        XCTAssertEqual(result, expNewX)
    }

}
