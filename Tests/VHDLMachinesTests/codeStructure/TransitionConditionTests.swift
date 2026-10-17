// TransitionConditionTests.swift
// Machines
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

import TestUtils
@testable import VHDLMachines
import VHDLParsing
import Testing

// swiftlint:disable type_body_length

/// Test class for ``TransitionCondition``.
@Suite
struct TransitionConditionTests {

    /// A variable `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: .x)))

    /// A variable `y`.
    let y = Expression.reference(variable: .variable(reference: .variable(name: .y)))

    /// A variable `z`.
    let z = Expression.reference(variable: .variable(reference: .variable(name: .z)))

    // swiftlint:disable function_body_length

    /// Test that raw values are correct.
    @Test
    func testRawValue() {
        let after = AfterStatement(amount: x, period: .ns)
        #expect(TransitionCondition.after(statement: after).rawValue == after.rawValue)
        #expect(TransitionCondition.conditional(condition: .literal(value: true)).rawValue == "true")
        #expect(
            TransitionCondition.boolean(
                expression: .and(
                    lhs: .literal(value: .boolean(value: true)),
                    rhs: x
                )
            )
            .rawValue == "true and x"
        )
        #expect(TransitionCondition.variable(name: .x).rawValue == "x")
        #expect(TransitionCondition.precedence(condition: .variable(name: .x)).rawValue == "(x)")
        #expect(
            TransitionCondition.and(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue == "x and y"
        )
        #expect(
            TransitionCondition.or(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue == "x or y"
        )
        #expect(
            TransitionCondition.nand(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue
                == "x nand y"
        )
        #expect(
            TransitionCondition.nor(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue == "x nor y"
        )
        #expect(
            TransitionCondition.xor(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue == "x xor y"
        )
        #expect(
            TransitionCondition.xnor(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue
                == "x xnor y"
        )
        #expect(TransitionCondition.not(value: .variable(name: .x)).rawValue == "not x")
        #expect(
            TransitionCondition.equals(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue == "x = y"
        )
        #expect(
            TransitionCondition.notEquals(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue
                == "x /= y"
        )
    }

    // swiftlint:enable function_body_length

    /// Test the raw value init for boolean expressions.
    @Test
    func testBooleanInit() {
        #expect(TransitionCondition(rawValue: "x and y") == .boolean(expression: .and(lhs: x, rhs: y)))
        #expect(
            TransitionCondition(rawValue: "(x and y)")
                == .precedence(condition: .boolean(expression: .and(lhs: x, rhs: y)))
        )
        #expect(TransitionCondition(rawValue: "x or y") == .boolean(expression: .or(lhs: x, rhs: y)))
        #expect(TransitionCondition(rawValue: "x nand y") == .boolean(expression: .nand(lhs: x, rhs: y)))
        #expect(TransitionCondition(rawValue: "x nor y") == .boolean(expression: .nor(lhs: x, rhs: y)))
        #expect(TransitionCondition(rawValue: "x xor y") == .boolean(expression: .xor(lhs: x, rhs: y)))
        #expect(TransitionCondition(rawValue: "x xnor y") == .boolean(expression: .xnor(lhs: x, rhs: y)))
        #expect(TransitionCondition(rawValue: "not x") == .boolean(expression: .not(value: x)))
        #expect(
            TransitionCondition(rawValue: "x and (y or z)")
                == .boolean(
                    expression: .and(
                        lhs: x,
                        rhs: .precedence(value: .logical(operation: .or(lhs: y, rhs: z)))
                    )
                )
        )
        #expect(
            TransitionCondition(rawValue: "(x > y) or z")
                == .boolean(
                    expression: .or(
                        lhs: .precedence(
                            value: .conditional(
                                condition: .comparison(value: .greaterThan(lhs: x, rhs: y))
                            )
                        ),
                        rhs: z
                    )
                )
        )
    }

    /// Test the raw value init for conditional expressions.
    @Test
    func testConditionalInit() {
        #expect(TransitionCondition(rawValue: "true") == .conditional(condition: .literal(value: true)))
        #expect(TransitionCondition(rawValue: "false") == .conditional(condition: .literal(value: false)))
        #expect(
            TransitionCondition(rawValue: "x > y")
                == .conditional(condition: .comparison(value: .greaterThan(lhs: x, rhs: y)))
        )
        #expect(
            TransitionCondition(rawValue: "(x > y)")
                == .precedence(
                    condition: .conditional(condition: .comparison(value: .greaterThan(lhs: x, rhs: y)))
                )
        )
        #expect(
            TransitionCondition(rawValue: "x >= y")
                == .conditional(condition: .comparison(value: .greaterThanOrEqual(lhs: x, rhs: y)))
        )
        #expect(
            TransitionCondition(rawValue: "x < y")
                == .conditional(condition: .comparison(value: .lessThan(lhs: x, rhs: y)))
        )
        #expect(
            TransitionCondition(rawValue: "x <= y")
                == .conditional(condition: .comparison(value: .lessThanOrEqual(lhs: x, rhs: y)))
        )
        #expect(
            TransitionCondition(rawValue: "x = y")
                == .conditional(condition: .comparison(value: .equality(lhs: x, rhs: y)))
        )
        #expect(
            TransitionCondition(rawValue: "x /= y")
                == .conditional(condition: .comparison(value: .notEquals(lhs: x, rhs: y)))
        )
    }

    /// Test the raw value init for variable statements.
    @Test
    func testVariableInit() {
        #expect(TransitionCondition(rawValue: "x") == .variable(name: .x))
        #expect(TransitionCondition(rawValue: String(repeating: "x", count: 1024)) == nil)
        #expect(TransitionCondition(rawValue: "x y") == nil)
    }

    /// Test the raw value init for after statements.
    @Test
    func testAfterInit() {
        #expect(
            TransitionCondition(rawValue: "after_ns(x)")
                == .after(statement: AfterStatement(amount: x, period: .ns))
        )
        #expect(
            TransitionCondition(rawValue: "(after_ns(x))")
                == .precedence(condition: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
        #expect(
            TransitionCondition(rawValue: "(y and z) or after_ns(x)")
                == .or(
                    lhs: .precedence(condition: .boolean(expression: .and(lhs: y, rhs: z))),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y and (z or after_ns(x))")
                == .and(
                    lhs: .variable(name: .y),
                    rhs: .precedence(
                        condition: .or(
                            lhs: .variable(name: .z),
                            rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                        )
                    )
                )
        )
        #expect(
            TransitionCondition(rawValue: "(x or y) and (z or after_ns(10))")
                == .and(
                    lhs: .precedence(condition: .boolean(expression: .or(lhs: x, rhs: y))),
                    rhs: .precedence(
                        condition: .or(
                            lhs: .variable(name: .z),
                            rhs: .after(
                                statement: AfterStatement(
                                    amount: .literal(value: .integer(value: 10)),
                                    period: .ns
                                )
                            )
                        )
                    )
                )
        )
    }

    // swiftlint:disable function_body_length

    /// Test the raw value init for after stataments containing conditional operations.
    @Test
    func testAfterConditionalInit() {
        #expect(
            TransitionCondition(rawValue: "(x = y) and (z or after_ns(10))")
                == .and(
                    lhs: .precedence(
                        condition: .conditional(
                            condition: .comparison(value: .equality(lhs: x, rhs: y))
                        )
                    ),
                    rhs: .precedence(
                        condition: .or(
                            lhs: .variable(name: .z),
                            rhs: .after(
                                statement: AfterStatement(
                                    amount: .literal(value: .integer(value: 10)),
                                    period: .ns
                                )
                            )
                        )
                    )
                )
        )
        #expect(
            TransitionCondition(rawValue: "(x = y) and ((z or after_ns(10)) or after_ms(1))")
                == .and(
                    lhs: .precedence(
                        condition: .conditional(
                            condition: .comparison(value: .equality(lhs: x, rhs: y))
                        )
                    ),
                    rhs: .precedence(
                        condition: .or(
                            lhs: .precedence(
                                condition: .or(
                                    lhs: .variable(name: .z),
                                    rhs: .after(
                                        statement: AfterStatement(
                                            amount: .literal(value: .integer(value: 10)),
                                            period: .ns
                                        )
                                    )
                                )
                            ),
                            rhs: .after(
                                statement: AfterStatement(
                                    amount: .literal(value: .integer(value: 1)),
                                    period: .ms
                                )
                            )
                        )
                    )
                )
        )
    }

    // swiftlint:enable function_body_length

    /// Test nil cases for the raw value init.
    @Test
    func testFailingRawValueInit() {
        #expect(TransitionCondition(rawValue: "after_ms(x) or") == nil)
        #expect(TransitionCondition(rawValue: "(x and)") == nil)
        #expect(TransitionCondition(rawValue: "(after_ms(x)") == nil)
        #expect(TransitionCondition(rawValue: "(after_ms(x)) ors true") == nil)
        #expect(TransitionCondition(rawValue: "(after_ms(x)) or x y z") == nil)
        #expect(TransitionCondition(rawValue: "after_ms(x) ors x") == nil)
    }

    /// Test after boolean expressions.
    @Test
    func testAfterBooleanInit() {
        #expect(
            TransitionCondition(rawValue: "y or after_ns(x)")
                == .or(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y and after_ns(x)")
                == .and(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y nand after_ns(x)")
                == .nand(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y nor after_ns(x)")
                == .nor(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y xor after_ns(x)")
                == .xor(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y xnor after_ns(x)")
                == .xnor(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y = after_ns(x)")
                == .equals(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "y /= after_ns(x)")
                == .notEquals(
                    lhs: .variable(name: .y),
                    rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                )
        )
        #expect(
            TransitionCondition(rawValue: "(y /= after_ns(x)) or z")
                == .or(
                    lhs: .precedence(
                        condition: .notEquals(
                            lhs: .variable(name: .y),
                            rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                        )
                    ),
                    rhs: .variable(name: .z)
                )
        )
    }

    // swiftlint:disable function_body_length

    /// Test `hasAfter` computed property.
    @Test
    func testHasAfter() {
        let after = TransitionCondition.after(statement: AfterStatement(amount: x, period: .ns))
        #expect(!TransitionCondition.conditional(condition: .literal(value: true)).hasAfter)
        #expect(!TransitionCondition.variable(name: .x).hasAfter)
        #expect(
            !TransitionCondition.boolean(
                expression: .or(
                    lhs: .literal(value: .boolean(value: true)),
                    rhs: .literal(value: .boolean(value: false))
                )
            )
            .hasAfter
        )
        #expect(after.hasAfter)
        #expect(!TransitionCondition.or(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.or(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.or(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.or(lhs: after, rhs: after).hasAfter)
        #expect(!TransitionCondition.and(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.and(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.and(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.and(lhs: after, rhs: after).hasAfter)
        #expect(!TransitionCondition.nand(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.nand(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.nand(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.nand(lhs: after, rhs: after).hasAfter)
        #expect(!TransitionCondition.nor(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.nor(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.nor(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.nor(lhs: after, rhs: after).hasAfter)
        #expect(!TransitionCondition.xor(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.xor(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.xor(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.xor(lhs: after, rhs: after).hasAfter)
        #expect(!TransitionCondition.xnor(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.xnor(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.xnor(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.xnor(lhs: after, rhs: after).hasAfter)
        #expect(!TransitionCondition.not(value: .variable(name: .x)).hasAfter)
        #expect(TransitionCondition.not(value: after).hasAfter)
        #expect(!TransitionCondition.precedence(condition: .variable(name: .x)).hasAfter)
        #expect(TransitionCondition.precedence(condition: after).hasAfter)
        #expect(!TransitionCondition.equals(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.equals(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.equals(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.equals(lhs: after, rhs: after).hasAfter)
        #expect(!TransitionCondition.notEquals(lhs: .variable(name: .x), rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.notEquals(lhs: .variable(name: .x), rhs: after).hasAfter)
        #expect(TransitionCondition.notEquals(lhs: after, rhs: .variable(name: .y)).hasAfter)
        #expect(TransitionCondition.notEquals(lhs: after, rhs: after).hasAfter)
    }

    // swiftlint:enable function_body_length

}

// swiftlint:enable type_body_length
