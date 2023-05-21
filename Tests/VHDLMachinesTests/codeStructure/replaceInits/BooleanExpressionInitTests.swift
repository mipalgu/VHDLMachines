// BooleanExpressionTests.swift
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

/// Test class for the `BooleanExpression` replace initialiser.
final class BooleanExpressionInitTests: XCTestCase {

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

    /// Test `and` operation.
    func testAnd() {
        let and = BooleanExpression.and(lhs: x, rhs: y)
        let newAnd = BooleanExpression(expression: and, replacing: .x, with: newX)
        let expected = BooleanExpression.and(lhs: expNewX, rhs: y)
        XCTAssertEqual(newAnd, expected)
    }

    /// Test `nand` operation.
    func testNand() {
        let nand = BooleanExpression.nand(lhs: x, rhs: y)
        let newNand = BooleanExpression(expression: nand, replacing: .x, with: newX)
        let expected = BooleanExpression.nand(lhs: expNewX, rhs: y)
        XCTAssertEqual(newNand, expected)
    }

    /// Test `nor` operation.
    func testNor() {
        let nor = BooleanExpression.nor(lhs: x, rhs: y)
        let newNor = BooleanExpression(expression: nor, replacing: .x, with: newX)
        let expected = BooleanExpression.nor(lhs: expNewX, rhs: y)
        XCTAssertEqual(newNor, expected)
    }

    /// Test `or` operation.
    func testOr() {
        let or = BooleanExpression.or(lhs: x, rhs: y)
        let newOr = BooleanExpression(expression: or, replacing: .x, with: newX)
        let expected = BooleanExpression.or(lhs: expNewX, rhs: y)
        XCTAssertEqual(newOr, expected)
    }

    /// Test `xnor` operation.
    func testXNor() {
        let xnor = BooleanExpression.xnor(lhs: x, rhs: y)
        let newXnor = BooleanExpression(expression: xnor, replacing: .x, with: newX)
        let expected = BooleanExpression.xnor(lhs: expNewX, rhs: y)
        XCTAssertEqual(newXnor, expected)
    }

    /// Test `xor` operation.
    func testXOr() {
        let xor = BooleanExpression.xor(lhs: x, rhs: y)
        let newXor = BooleanExpression(expression: xor, replacing: .x, with: newX)
        let expected = BooleanExpression.xor(lhs: expNewX, rhs: y)
        XCTAssertEqual(newXor, expected)
    }

    /// Test `not` operation.
    func testNot() {
        let not = BooleanExpression.not(value: x)
        let newNot = BooleanExpression(expression: not, replacing: .x, with: newX)
        let expected = BooleanExpression.not(value: expNewX)
        XCTAssertEqual(newNot, expected)
    }

}
