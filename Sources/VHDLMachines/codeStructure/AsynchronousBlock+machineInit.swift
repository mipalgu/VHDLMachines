// AsynchronousBlock+machineInit.swift
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

import VHDLParsing

/// Add init for top-level architecture body asynchronous block.
extension AsynchronousBlock {

    /// Create the top-level asynchronous block that will represent the entire architecture body of a machine.
    /// This block represents all of the logic of the machine.
    /// - Parameter machine: The machine to generate the block from.
    init?(machine: Machine) {
        guard
            machine.drivingClock >= 0,
            machine.drivingClock < machine.clocks.count,
            let code = SynchronousBlock(machine: machine)
        else {
            return nil
        }
        let clock = machine.clocks[machine.drivingClock].name
        let process = ProcessBlock(sensitivityList: [clock], code: code)
        guard
            let userBody = machine.architectureBody,
            let comment = Comment(rawValue: "-- User-Specific Code for Architecture Body")
        else {
            self = .process(block: process)
            return
        }
        self = .blocks(blocks: [
            .statement(statement: .comment(value: comment)),
            userBody,
            .process(block: process)
        ])
    }

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - block: The block containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(block: AsynchronousBlock, replacing variable: VariableName, with value: VariableName) {
        switch block {
        case .blocks(let blocks):
            let newBlocks = blocks.compactMap {
                AsynchronousBlock(block: $0, replacing: variable, with: value)
            }
            guard newBlocks.count == blocks.count else {
                return nil
            }
            self = .blocks(blocks: newBlocks)
        case .component(let block):
            guard let newComponent = ComponentInstantiation(
                component: block, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .component(block: newComponent)
        case .process(let block):
            guard let newProcess = ProcessBlock(process: block, replacing: variable, with: value) else {
                return nil
            }
            self = .process(block: newProcess)
        case .statement(let statement):
            guard
                let newStatement = AsynchronousStatement(
                    statement: statement, replacing: variable, with: value
                )
            else {
                return nil
            }
            self = .statement(statement: newStatement)
        case .function(let function):
            guard
                let newFunction = FunctionImplementation(function: function, replacing: variable, with: value)
            else {
                return nil
            }
            self = .function(block: newFunction)
        case .generate(let block):
            guard let newBlock = GenerateBlock(block: block, replacing: variable, with: value) else {
                return nil
            }
            self = .generate(block: newBlock)
        }
    }

}

/// Add replace init.
extension ProcessBlock {

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - process: The process containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(process: ProcessBlock, replacing variable: VariableName, with value: VariableName) {
        guard let newCode = SynchronousBlock(block: process.code, replacing: variable, with: value) else {
            return nil
        }
        let newSensitivityList = process.sensitivityList.map { $0 == variable ? value : $0 }
        self.init(sensitivityList: newSensitivityList, code: newCode)
    }

}

/// Add replace init.
extension ComponentInstantiation {

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - component: The component containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(component: ComponentInstantiation, replacing variable: VariableName, with value: VariableName) {
        let generic: GenericMap?
        if let gen = component.generic {
            guard let newGen = GenericMap(map: gen, replacing: variable, with: value) else {
                return nil
            }
            generic = newGen
        } else {
            generic = nil
        }
        guard let port = PortMap(map: component.port, replacing: variable, with: value) else {
            return nil
        }
        self.init(label: component.label, name: component.name, port: port, generic: generic)
    }

}

/// Add replace init.
extension PortMap {

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - map: The map containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(map: PortMap, replacing variable: VariableName, with value: VariableName) {
        let newVariables = map.variables.compactMap {
            VariableMap(map: $0, replacing: variable, with: value)
        }
        guard newVariables.count == map.variables.count else {
            return nil
        }
        self.init(variables: newVariables)
    }

}

/// Add replace init.
extension VariableMap {

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - map: The map containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(map: VariableMap, replacing variable: VariableName, with value: VariableName) {
        guard let newRhs = VariableAssignment(assignment: map.rhs, replacing: variable, with: value) else {
            return nil
        }
        self.init(lhs: map.lhs, rhs: newRhs)
    }

}

/// Add replace init.
extension VariableAssignment {

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - assignment: The assignment containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(assignment: VariableAssignment, replacing variable: VariableName, with value: VariableName) {
        switch assignment {
        case .reference(let ref):
            guard let newVariable = VariableReference(reference: ref, replacing: variable, with: value) else {
                return nil
            }
            self = .reference(variable: newVariable)
        case .literal, .open:
            self = assignment
        }
    }

}

/// Add replace init.
extension GenericMap {

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - map: The map containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(map: GenericMap, replacing variable: VariableName, with value: VariableName) {
        let newVariables = map.variables.compactMap {
            GenericVariableMap(map: $0, replacing: variable, with: value)
        }
        guard newVariables.count == map.variables.count else {
            return nil
        }
        self.init(variables: newVariables)
    }

}

/// Add replace init.
extension GenericVariableMap {

    /// Replace the variable with the value.
    /// - Parameters:
    ///   - map: The map containing the variable to replace.
    ///   - variable: The variable to replace.
    ///   - value: The value to replace the variable with.
    @inlinable
    init?(map: GenericVariableMap, replacing variable: VariableName, with value: VariableName) {
        guard let newRhs = Expression(expression: map.rhs, replacing: variable, with: value) else {
            return nil
        }
        self.init(lhs: map.lhs, rhs: newRhs)
    }

}
