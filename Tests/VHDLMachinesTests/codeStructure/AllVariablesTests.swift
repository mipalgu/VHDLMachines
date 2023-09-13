// AllVariablesTests.swift
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

/// Test class for `allVariables` property on multiple types.
final class AllVariablesTests: XCTestCase {

    /// An expression `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: .x)))

    /// An expression `y`.
    let y = Expression.reference(variable: .variable(reference: .variable(name: .y)))

    /// Test all variables.
    func testAllVariables() {
        XCTAssertEqual(MemberAccess(record: .x, member: .variable(name: .y)).allVariables, [.x, .y])
        XCTAssertEqual(DirectReference.variable(name: .x).allVariables, [.x])
        XCTAssertEqual(
            DirectReference.member(access: MemberAccess(
                record: .x, member: .variable(name: .y)
            )).allVariables,
            [.x, .y]
        )
        XCTAssertEqual(VectorSize.downto(upper: x, lower: y).allVariables, [.x, .y])
        XCTAssertEqual(VariableReference.variable(reference: .variable(name: .x)).allVariables, [.x])
        XCTAssertEqual(VariableReference.indexed(name: .x, index: .index(value: y)).allVariables, [.x, .y])
        XCTAssertEqual(EdgeCondition.falling(expression: x).allVariables, [.x])
        XCTAssertEqual(EdgeCondition.rising(expression: x).allVariables, [.x])
    }

    /// Test comparison operations.
    func testComparisonAllVariables() {
        XCTAssertEqual(ComparisonOperation.equality(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(ComparisonOperation.greaterThan(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(ComparisonOperation.greaterThanOrEqual(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(ComparisonOperation.lessThan(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(ComparisonOperation.lessThanOrEqual(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(ComparisonOperation.notEquals(lhs: x, rhs: y).allVariables, [.x, .y])
    }

    /// test conditional operation.
    func testConditional() {
        XCTAssertEqual(
            ConditionalExpression.comparison(value: .equality(lhs: x, rhs: y)).allVariables, [.x, .y]
        )
        XCTAssertEqual(ConditionalExpression.edge(value: .rising(expression: x)).allVariables, [.x])
        XCTAssertTrue(ConditionalExpression.literal(value: true).allVariables.isEmpty)
    }

    /// Test cast operations.
    func testCast() {
        XCTAssertEqual(CastOperation.bit(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.signed(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.unsigned(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.bitVector(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.boolean(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.integer(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.real(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.natural(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.positive(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.stdLogic(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.stdLogicVector(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.stdULogic(expression: x).allVariables, [.x])
        XCTAssertEqual(CastOperation.stdULogicVector(expression: x).allVariables, [.x])
    }

    /// Test binary operations.
    func testBinary() {
        XCTAssertEqual(BinaryOperation.addition(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BinaryOperation.subtraction(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BinaryOperation.multiplication(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BinaryOperation.division(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BinaryOperation.concatenate(lhs: x, rhs: y).allVariables, [.x, .y])
    }

    /// Test boolean operations.
    func testBoolean() {
        XCTAssertEqual(BooleanExpression.and(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BooleanExpression.nand(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BooleanExpression.nor(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BooleanExpression.or(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BooleanExpression.xnor(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BooleanExpression.xor(lhs: x, rhs: y).allVariables, [.x, .y])
        XCTAssertEqual(BooleanExpression.not(value: x).allVariables, [.x])
    }

    /// Test index.
    func testVectorIndex() {
        XCTAssertEqual(VectorIndex.index(value: x).allVariables, [.x])
        XCTAssertEqual(VectorIndex.range(value: .downto(upper: x, lower: y)).allVariables, [.x, .y])
        XCTAssertTrue(VectorIndex.others.allVariables.isEmpty)
    }

    /// Test function calls.
    func testFunctions() {
        XCTAssertEqual(
            // swiftlint:disable:next force_unwrapping
            FunctionCall.custom(function: CustomFunctionCall(function: "y", arguments: [x])!).allVariables,
            [.y, .x]
        )
        XCTAssertEqual(FunctionCall.mathReal(function: .ceil(expression: x)).allVariables, [.x])
        XCTAssertEqual(FunctionCall.mathReal(function: .floor(expression: x)).allVariables, [.x])
        XCTAssertEqual(FunctionCall.mathReal(function: .round(expression: x)).allVariables, [.x])
        XCTAssertEqual(FunctionCall.mathReal(function: .sign(expression: x)).allVariables, [.x])
        XCTAssertEqual(FunctionCall.mathReal(function: .sqrt(expression: x)).allVariables, [.x])
        XCTAssertEqual(FunctionCall.mathReal(function: .fmax(arg0: x, arg1: y)).allVariables, [.x, .y])
        XCTAssertEqual(FunctionCall.mathReal(function: .fmin(arg0: x, arg1: y)).allVariables, [.x, .y])
    }

}
