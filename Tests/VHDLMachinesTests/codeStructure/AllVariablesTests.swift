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

import Testing
@testable import VHDLMachines
import VHDLParsing

/// Test class for `allVariables` property on multiple types.
@Suite
struct AllVariablesTests {

    /// An expression `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: .x)))

    /// An expression `y`.
    let y = Expression.reference(variable: .variable(reference: .variable(name: .y)))

    /// Test all variables.
    @Test
    func testAllVariables() {
        #expect(MemberAccess(record: .x, member: .variable(name: .y)).allVariables == [.x, .y])
        #expect(DirectReference.variable(name: .x).allVariables == [.x])
        #expect(
            DirectReference.member(
                access: MemberAccess(
                    record: .x,
                    member: .variable(name: .y)
                )
            )
            .allVariables == [.x, .y]
        )
        #expect(VectorSize.downto(upper: x, lower: y).allVariables == [.x, .y])
        #expect(VariableReference.variable(reference: .variable(name: .x)).allVariables == [.x])
        #expect(VariableReference.indexed(name: x, index: .index(value: y)).allVariables == [.x, .y])
        #expect(EdgeCondition.falling(expression: x).allVariables == [.x])
        #expect(EdgeCondition.rising(expression: x).allVariables == [.x])
    }

    /// Test comparison operations.
    @Test
    func testComparisonAllVariables() {
        #expect(ComparisonOperation.equality(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(ComparisonOperation.greaterThan(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(ComparisonOperation.greaterThanOrEqual(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(ComparisonOperation.lessThan(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(ComparisonOperation.lessThanOrEqual(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(ComparisonOperation.notEquals(lhs: x, rhs: y).allVariables == [.x, .y])
    }

    /// test conditional operation.
    @Test
    func testConditional() {
        #expect(
            ConditionalExpression.comparison(value: .equality(lhs: x, rhs: y)).allVariables == [.x, .y]
        )
        #expect(ConditionalExpression.edge(value: .rising(expression: x)).allVariables == [.x])
        #expect(ConditionalExpression.literal(value: true).allVariables.isEmpty)
    }

    /// Test cast operations.
    @Test
    func testCast() {
        #expect(CastOperation.bit(expression: x).allVariables == [.x])
        #expect(CastOperation.signed(expression: x).allVariables == [.x])
        #expect(CastOperation.unsigned(expression: x).allVariables == [.x])
        #expect(CastOperation.bitVector(expression: x).allVariables == [.x])
        #expect(CastOperation.boolean(expression: x).allVariables == [.x])
        #expect(CastOperation.integer(expression: x).allVariables == [.x])
        #expect(CastOperation.real(expression: x).allVariables == [.x])
        #expect(CastOperation.natural(expression: x).allVariables == [.x])
        #expect(CastOperation.positive(expression: x).allVariables == [.x])
        #expect(CastOperation.stdLogic(expression: x).allVariables == [.x])
        #expect(CastOperation.stdLogicVector(expression: x).allVariables == [.x])
        #expect(CastOperation.stdULogic(expression: x).allVariables == [.x])
        #expect(CastOperation.stdULogicVector(expression: x).allVariables == [.x])
    }

    /// Test binary operations.
    @Test
    func testBinary() {
        #expect(BinaryOperation.addition(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BinaryOperation.subtraction(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BinaryOperation.multiplication(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BinaryOperation.division(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BinaryOperation.concatenate(lhs: x, rhs: y).allVariables == [.x, .y])
    }

    /// Test boolean operations.
    @Test
    func testBoolean() {
        #expect(BooleanExpression.and(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BooleanExpression.nand(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BooleanExpression.nor(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BooleanExpression.or(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BooleanExpression.xnor(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BooleanExpression.xor(lhs: x, rhs: y).allVariables == [.x, .y])
        #expect(BooleanExpression.not(value: x).allVariables == [.x])
    }

    /// Test index.
    @Test
    func testVectorIndex() {
        #expect(VectorIndex.index(value: x).allVariables == [.x])
        #expect(VectorIndex.range(value: .downto(upper: x, lower: y)).allVariables == [.x, .y])
        #expect(VectorIndex.others.allVariables.isEmpty)
    }

    /// Test function calls.
    @Test
    func testFunctions() {
        #expect(
            FunctionCall.custom(
                function: CustomFunctionCall(
                    name: .y,
                    parameters: [Argument(argument: x)]
                )
            )
            .allVariables == [.y, .x]
        )
        #expect(FunctionCall.mathReal(function: .ceil(expression: x)).allVariables == [.x])
        #expect(FunctionCall.mathReal(function: .floor(expression: x)).allVariables == [.x])
        #expect(FunctionCall.mathReal(function: .round(expression: x)).allVariables == [.x])
        #expect(FunctionCall.mathReal(function: .sign(expression: x)).allVariables == [.x])
        #expect(FunctionCall.mathReal(function: .sqrt(expression: x)).allVariables == [.x])
        #expect(FunctionCall.mathReal(function: .fmax(arg0: x, arg1: y)).allVariables == [.x, .y])
        #expect(FunctionCall.mathReal(function: .fmin(arg0: x, arg1: y)).allVariables == [.x, .y])
    }

}
