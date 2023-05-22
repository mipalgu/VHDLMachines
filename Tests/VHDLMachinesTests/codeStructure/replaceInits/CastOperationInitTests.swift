// CastOperationInitTests.swift
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

/// Test class for `CastOperation` replace initialiser.
final class CastOperationInitTests: XCTestCase {

    /// An `x` variable.
    let x = Expression.reference(variable: .variable(name: .x))

    // swiftlint:disable force_unwrapping

    /// The new name for variable `x`.
    let newX = VariableName(rawValue: "STATE_Initial_x")!

    // swiftlint:enable force_unwrapping

    /// `newX` as an expression.
    var expNewX: Expression {
        .reference(variable: .variable(name: newX))
    }

    /// Test `bit` cast.
    func testBit() {
        let original = CastOperation.bit(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .bit(expression: expNewX))
    }

    /// Test `bitVector` cast.
    func testBitVector() {
        let original = CastOperation.bitVector(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .bitVector(expression: expNewX))
    }

    /// Test `boolean` cast.
    func testBoolean() {
        let original = CastOperation.boolean(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .boolean(expression: expNewX))
    }

    /// Test `integer` cast.
    func testInteger() {
        let original = CastOperation.integer(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .integer(expression: expNewX))
    }

    /// Test `natural` cast.
    func testNatural() {
        let original = CastOperation.natural(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .natural(expression: expNewX))
    }

    /// Test `positive` cast.
    func testPositive() {
        let original = CastOperation.positive(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .positive(expression: expNewX))
    }

    /// Test `real` cast.
    func testReal() {
        let original = CastOperation.real(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .real(expression: expNewX))
    }

    /// Test `signed` cast.
    func testSigned() {
        let original = CastOperation.signed(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .signed(expression: expNewX))
    }

    /// Test `stdLogic` cast.
    func testStdLogic() {
        let original = CastOperation.stdLogic(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .stdLogic(expression: expNewX))
    }

    /// Test `stdLogicVector` cast.
    func testStdLogicVector() {
        let original = CastOperation.stdLogicVector(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .stdLogicVector(expression: expNewX))
    }

    /// Test `stdULogic` cast.
    func testStdULogic() {
        let original = CastOperation.stdULogic(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .stdULogic(expression: expNewX))
    }

    /// Test `stdULogicVector` cast.
    func testStdULogicVector() {
        let original = CastOperation.stdULogicVector(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .stdULogicVector(expression: expNewX))
    }

    /// Test `unsigned` cast.
    func testUnsigned() {
        let original = CastOperation.unsigned(expression: x)
        let result = CastOperation(operation: original, replacing: .x, with: newX)
        XCTAssertEqual(result, .unsigned(expression: expNewX))
    }

}
