// VHDLGeneratorTests.swift
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

import SwiftUtils
import TestUtils
@testable import VHDLMachines
import XCTest

/// A test case for the ``VHDLGenerator``.
final class VHDLGeneratorTests: XCTestCase {

    /// The ``VHDLGenerator`` to test.
    let generator = VHDLGenerator()

    /// A factory that generates a PingPongArrangement.
    let factory = PingPongArrangement()

    /// A JSON decoder.
    let decoder = JSONDecoder()

    /// IO helper.
    let manager = FileManager.default

    /// Remove ping machine after every test.
    override func tearDown() {
        if manager.fileExists(atPath: factory.pingMachinePath.path) {
            _ = try? manager.removeItem(at: factory.pingMachinePath)
        }
    }

    /// Test Generate creates correct file structure.
    func testGenerate() {
        guard let wrapper = generator.generate(machine: factory.pingMachine, with: .pingMachine) else {
            XCTFail("Failed to create wrapper!")
            return
        }
        XCTAssertTrue(wrapper.isDirectory)
        XCTAssertEqual(wrapper.preferredFilename, "PingMachine.machine")
        guard let files = wrapper.fileWrappers, let (name, machineFile) = files.first else {
            XCTFail("No nested files!")
            return
        }
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(name, "machine.json")
        XCTAssertFalse(machineFile.isDirectory)
        XCTAssertEqual(machineFile.preferredFilename, "machine.json")
        guard let data = machineFile.regularFileContents else {
            XCTFail("File is empty")
            return
        }
        guard let machine = try? decoder.decode(Machine.self, from: data) else {
            XCTFail("Failed to decode machine!")
            return
        }
        XCTAssertEqual(machine, factory.pingMachine)
    }

    /// Test write creates correct file structure.
    func testWrite() throws {
        let machine = factory.pingMachine
        guard let wrapper = generator.generate(machine: machine, with: .pingMachine) else {
            XCTFail("Failed to create wrapper!")
            return
        }
        XCTAssertTrue(wrapper.isDirectory)
        XCTAssertEqual(wrapper.preferredFilename, "PingMachine.machine")
        let path = factory.machinePath.appendingPathComponent("PingMachine.machine", isDirectory: true)
        if manager.fileExists(atPath: path.path) {
            try manager.removeItem(at: path)
        }
        try wrapper.write(to: path, originalContentsURL: nil)
        defer {
            if manager.fileExists(atPath: path.path) {
                _ = try? manager.removeItem(at: path)
            }
        }
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: path.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        let data = try Data(contentsOf: factory.pingPath)
        let newMachine = try decoder.decode(Machine.self, from: data)
        XCTAssertEqual(factory.pingMachine, newMachine)
    }

    /// Test that an arrangement is generated correctly.
    func testGenerateArrangement() throws {
        let arrangement = Arrangement.testArrangement
        guard let wrapper = generator.generate(arrangement: arrangement, name: .arrangement1) else {
            XCTFail("Failed to create wrapper!")
            return
        }
        XCTAssertTrue(wrapper.isDirectory)
        XCTAssertEqual(wrapper.fileWrappers?.count, 1)
        XCTAssertEqual(wrapper.preferredFilename, "Arrangement1.arrangement")
        XCTAssertNil(wrapper.filename)
        guard
            let file = wrapper.fileWrappers?.first?.value,
            file.isRegularFile,
            let fileData = file.regularFileContents
        else {
            XCTFail("File is empty")
            return
        }
        XCTAssertEqual(file.preferredFilename, "arrangement.json")
        XCTAssertNil(file.filename)
        let newArrangement = try decoder.decode(Arrangement.self, from: fileData)
        XCTAssertEqual(arrangement, newArrangement)
    }

}
