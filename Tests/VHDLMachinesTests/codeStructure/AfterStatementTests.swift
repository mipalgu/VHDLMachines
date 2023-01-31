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

@testable import VHDLMachines
import XCTest

/// Test class for ``AfterStatement``.
final class AfterStatementTests: XCTestCase {

    /// Test ``AfterStatement.Period`` `rawValue`.
    func testPeriodRawValue() {
        XCTAssertEqual(AfterStatement.Period.ps.rawValue, .ringletPerPs)
        XCTAssertEqual(AfterStatement.Period.ns.rawValue, .ringletPerNs)
        XCTAssertEqual(AfterStatement.Period.us.rawValue, .ringletPerUs)
        XCTAssertEqual(AfterStatement.Period.ms.rawValue, .ringletPerMs)
        XCTAssertEqual(AfterStatement.Period.s.rawValue, .ringletPerS)
        XCTAssertEqual(AfterStatement.Period.ringlet.rawValue, .ringletCounter)
    }

    /// Test the `afterLength` property on ``AfterStatement.Period`` is the length of the `after_` statement.
    func testPeriodAfterLength() {
        XCTAssertEqual(AfterStatement.Period.ps.afterLength, 8)
        XCTAssertEqual(AfterStatement.Period.ns.afterLength, 8)
        XCTAssertEqual(AfterStatement.Period.us.afterLength, 8)
        XCTAssertEqual(AfterStatement.Period.ms.afterLength, 8)
        XCTAssertEqual(AfterStatement.Period.s.afterLength, 5)
        XCTAssertEqual(AfterStatement.Period.ringlet.afterLength, 8)
    }

    /// Test ``AfterStatement.Period`` `init(rawValue:)` correclty creates the right case.
    func testPeriodRawValueInit() {
        XCTAssertEqual(AfterStatement.Period(rawValue: .ringletPerPs), .ps)
        XCTAssertEqual(AfterStatement.Period(rawValue: .ringletPerNs), .ns)
        XCTAssertEqual(AfterStatement.Period(rawValue: .ringletPerUs), .us)
        XCTAssertEqual(AfterStatement.Period(rawValue: .ringletPerMs), .ms)
        XCTAssertEqual(AfterStatement.Period(rawValue: .ringletPerS), .s)
        XCTAssertEqual(AfterStatement.Period(rawValue: .ringletCounter), .ringlet)
        XCTAssertNil(AfterStatement.Period(rawValue: .clk))
    }

    /// Test ``AfterStatement.Period`` `init(after:)` correclty creates the right case.
    func testPeriodAfterInit() {
        XCTAssertEqual(AfterStatement.Period(after: "after_ps"), .ps)
        XCTAssertEqual(AfterStatement.Period(after: "after_ns"), .ns)
        XCTAssertEqual(AfterStatement.Period(after: "after_us"), .us)
        XCTAssertEqual(AfterStatement.Period(after: "after_ms"), .ms)
        XCTAssertEqual(AfterStatement.Period(after: "after"), .s)
        XCTAssertEqual(AfterStatement.Period(after: "after("), .s)
        XCTAssertEqual(AfterStatement.Period(after: "after_rt"), .ringlet)
        XCTAssertEqual(AfterStatement.Period(after: "AFTER_PS"), .ps)
        XCTAssertNil(AfterStatement.Period(after: "_after"))
        XCTAssertNil(AfterStatement.Period(after: "after_"))
        XCTAssertNil(AfterStatement.Period(after: "after_fs"))
    }

}
