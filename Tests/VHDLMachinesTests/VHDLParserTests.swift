// VHDLParserTests.swift
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

#if os(Linux) || os(Windows)
import SwiftUtils
#endif
import TestUtils
@testable import VHDLMachines
import XCTest

/// Tests the ``VHDLParser``.
final class VHDLParserTests: XCTestCase {

    /// The parser under test.
    let parser = VHDLParser()

    /// A factory to generate test machines.
    let factory = PingPongArrangement()

    /// A generator to generate test machine FileWrappers.
    let generator = VHDLGenerator()

    /// Test parse function works correctly.
    func testParse() throws {
        guard
            let machineWrapper = generator.generate(machine: factory.pingMachine, with: .pingMachine),
            let machine = parser.parse(wrapper: machineWrapper)
        else {
            XCTFail("Failed to parse machine.")
            return
        }
        XCTAssertEqual(machine, factory.pingMachine)
    }

    /// Test parse function returns nil for invalid data.
    func testEmptyWrapper() {
        guard let data = Data(base64Encoded: "") else {
            XCTFail("Failed to decode empty data.")
            return
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        XCTAssertNil(parser.parse(wrapper: wrapper))
    }

    /// Test that an arrangement is parsed correctly.
    func testParseArrangement() throws {
        let arrangement = Arrangement.testArrangement
        guard
            let wrapper = generator.generate(arrangement: arrangement, name: .arrangement1),
            let parsedArrangement = parser.parseArrangement(wrapper: wrapper)
        else {
            XCTFail("Couldn't generate wrapper!")
            return
        }
        let emptydata = Data("".utf8)
        XCTAssertEqual(arrangement, parsedArrangement)
        XCTAssertNil(
            parser.parseArrangement(wrapper: FileWrapper(regularFileWithContents: emptydata))
        )
        XCTAssertNil(parser.parseArrangement(wrapper: FileWrapper(directoryWithFileWrappers: [:])))
        XCTAssertNil(
            parser.parseArrangement(
                wrapper: FileWrapper(
                    directoryWithFileWrappers: [
                        "arrangement.json": FileWrapper(regularFileWithContents: emptydata)
                    ]
                )
            )
        )
    }

}
