// AfterStatementTests.swift
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

import Testing
@testable import VHDLMachines
import VHDLParsing

/// Test class for ``AfterStatement``.
@Suite
struct AfterStatementTests {

    /// A variable `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: .x)))

    /// The ringletCounter raw value.
    let ringletCounter = VariableName.ringletCounter.rawValue

    /// The statement under test.
    let statement = AfterStatement(
        amount: .literal(value: .integer(value: 10)),
        period: .us
    )

    /// Test ``AfterStatement.Period`` `rawValue`.
    @Test
    func testPeriodRawValue() {
        #expect(AfterStatement.Period.ps.rawValue == .ringletPerPs)
        #expect(AfterStatement.Period.ns.rawValue == .ringletPerNs)
        #expect(AfterStatement.Period.us.rawValue == .ringletPerUs)
        #expect(AfterStatement.Period.ms.rawValue == .ringletPerMs)
        #expect(AfterStatement.Period.s.rawValue == .ringletPerS)
        #expect(AfterStatement.Period.ringlet.rawValue == .ringletCounter)
    }

    /// Test the `afterLength` property on ``AfterStatement.Period`` is the length of the `after_` statement.
    @Test
    func testPeriodAfterLength() {
        #expect(AfterStatement.Period.ps.afterLength == 8)
        #expect(AfterStatement.Period.ns.afterLength == 8)
        #expect(AfterStatement.Period.us.afterLength == 8)
        #expect(AfterStatement.Period.ms.afterLength == 8)
        #expect(AfterStatement.Period.s.afterLength == 5)
        #expect(AfterStatement.Period.ringlet.afterLength == 8)
    }

    /// Test ``AfterStatement.Period`` `init(rawValue:)` correclty creates the right case.
    @Test
    func testPeriodRawValueInit() {
        #expect(AfterStatement.Period(rawValue: .ringletPerPs) == .ps)
        #expect(AfterStatement.Period(rawValue: .ringletPerNs) == .ns)
        #expect(AfterStatement.Period(rawValue: .ringletPerUs) == .us)
        #expect(AfterStatement.Period(rawValue: .ringletPerMs) == .ms)
        #expect(AfterStatement.Period(rawValue: .ringletPerS) == .s)
        #expect(AfterStatement.Period(rawValue: .ringletCounter) == .ringlet)
        #expect(AfterStatement.Period(rawValue: .clk) == nil)
    }

    /// Test ``AfterStatement.Period`` `init(after:)` correclty creates the right case.
    @Test
    func testPeriodAfterInit() {
        #expect(AfterStatement.Period(after: "after_ps") == .ps)
        #expect(AfterStatement.Period(after: "after_ns") == .ns)
        #expect(AfterStatement.Period(after: "after_us") == .us)
        #expect(AfterStatement.Period(after: "after_ms") == .ms)
        #expect(AfterStatement.Period(after: "after") == .s)
        #expect(AfterStatement.Period(after: "after(") == .s)
        #expect(AfterStatement.Period(after: "after_rt") == .ringlet)
        #expect(AfterStatement.Period(after: "AFTER_PS") == .ps)
        #expect(AfterStatement.Period(after: "_after") == nil)
        #expect(AfterStatement.Period(after: "after_") == nil)
        #expect(AfterStatement.Period(after: "after_fs") == nil)
    }

    /// Test the stored properties are set correctly.
    @Test
    func testPropertyInit() {
        #expect(statement.amount == .literal(value: .integer(value: 10)))
        #expect(statement.period == .us)
    }

    /// Test `rawValue` generates the correct `VHDL` code.
    @Test
    func testRawValue() {
        #expect(
            statement.rawValue
                // swiftlint:disable:next line_length
                == "(\(VariableName.ringletCounter) >= integer(ceil(real(10) * \(VariableName.ringletPerUs))))"
        )
        #expect(
            AfterStatement(amount: x, period: .ringlet).rawValue
                == "(\(VariableName.ringletCounter) >= integer(ceil(real(\(x.rawValue)))))"
        )
    }

    /// Test `init(rawValue:)` correctly creates the object.
    @Test
    func testRawValueInit() {
        #expect(
            AfterStatement(
                rawValue: "(\(VariableName.ringletCounter) >= integer(ceil(real(10) * "
                    + "\(VariableName.ringletPerUs))))"
            ) == statement
        )
        #expect(
            AfterStatement(
                rawValue: "(\(VariableName.ringletCounter) >= integer(ceil(real(10))))"
            ) == AfterStatement(amount: .literal(value: .integer(value: 10)), period: .ringlet)
        )
        #expect(
            AfterStatement(
                rawValue: "(\(VariableName.ringletCounter) >= integer(ceil(real(10) / "
                    + "\(VariableName.ringletPerUs))))"
            ) == nil
        )
        #expect(
            AfterStatement(
                rawValue: "(\(VariableName.ringletCounter) >= integer(ceil(integer(10))))"
            ) == nil
        )
    }

    /// Test the after statements are parsed correctly.
    @Test
    func testAfterInit() {
        #expect(
            AfterStatement(after: "after_ps(10)")
                == AfterStatement(amount: .literal(value: .integer(value: 10)), period: .ps)
        )
        #expect(
            AfterStatement(after: "after_ns(10)")
                == AfterStatement(amount: .literal(value: .integer(value: 10)), period: .ns)
        )
        #expect(AfterStatement(after: "after_us(10)") == statement)
        #expect(
            AfterStatement(after: "after_ms(10)")
                == AfterStatement(amount: .literal(value: .integer(value: 10)), period: .ms)
        )
        #expect(
            AfterStatement(after: "after(10)")
                == AfterStatement(amount: .literal(value: .integer(value: 10)), period: .s)
        )
        #expect(
            AfterStatement(after: "after((10))")
                == AfterStatement(
                    amount: .precedence(value: .literal(value: .integer(value: 10))),
                    period: .s
                )
        )
        #expect(
            AfterStatement(after: "after_rt(10)")
                == AfterStatement(amount: .literal(value: .integer(value: 10)), period: .ringlet)
        )
        #expect(AfterStatement(after: "after(10))") == nil)
        #expect(AfterStatement(after: "after((10)") == nil)
        #expect(AfterStatement(after: "after(1\(String(repeating: "0", count: 256)))") == nil)
        #expect(AfterStatement(after: "after_fs(10)") == nil)
        #expect(AfterStatement(after: "afterps(10)") == nil)
    }

    // swiftlint:disable function_body_length

    /// Test the expression is correct.
    @Test
    func testExpression() {
        #expect(
            statement.expression
                == .precedence(
                    value: .conditional(
                        condition: .comparison(
                            value: .greaterThanOrEqual(
                                lhs: .reference(
                                    variable: .variable(reference: .variable(name: .ringletCounter))
                                ),
                                rhs: .cast(
                                    operation: .integer(
                                        expression: .functionCall(
                                            call: .mathReal(
                                                function: .ceil(
                                                    expression: .binary(
                                                        operation: .multiplication(
                                                            lhs: .cast(
                                                                operation: .real(
                                                                    expression: .literal(
                                                                        value: .integer(value: 10)
                                                                    )
                                                                )
                                                            ),
                                                            rhs: .reference(
                                                                variable: .variable(
                                                                    reference: .variable(name: .ringletPerUs)
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
        )
        let ringletStatement = AfterStatement(amount: .literal(value: .integer(value: 5)), period: .ringlet)
        #expect(
            ringletStatement.expression
                == .precedence(
                    value: .conditional(
                        condition: .comparison(
                            value: .greaterThanOrEqual(
                                lhs: .reference(
                                    variable: .variable(reference: .variable(name: .ringletCounter))
                                ),
                                rhs: .cast(
                                    operation: .integer(
                                        expression: .functionCall(
                                            call: .mathReal(
                                                function: .ceil(
                                                    expression: .cast(
                                                        operation: .real(
                                                            expression: .literal(value: .integer(value: 5))
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
        )
    }

    // swiftlint:enable function_body_length

}
