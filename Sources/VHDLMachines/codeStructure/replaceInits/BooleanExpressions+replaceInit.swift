// BooleanExpressions+replaceInit.swift
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

import VHDLParsing

/// Add replace initialiser.
extension BooleanExpression {

    // swiftlint:disable function_body_length

    /// Renames variables within a boolean expression with a replacement value.
    /// - Parameters:
    ///   - expression: The expression to replace.
    ///   - variable: The variable to replace in `expression`.
    ///   - value: The new value to replace `variable` with.
    @inlinable
    init?(expression: BooleanExpression, replacing variable: VariableName, with value: VariableName) {
        switch expression {
        case .and(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .and(lhs: newLhs, rhs: newRhs)
        case .nand(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .nand(lhs: newLhs, rhs: newRhs)
        case .nor(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .nor(lhs: newLhs, rhs: newRhs)
        case .not(let expression):
            guard let newValue = Expression(expression: expression, replacing: variable, with: value) else {
                return nil
            }
            self = .not(value: newValue)
        case .or(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .or(lhs: newLhs, rhs: newRhs)
        case .xnor(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .xnor(lhs: newLhs, rhs: newRhs)
        case .xor(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .xor(lhs: newLhs, rhs: newRhs)
        }
    }

    // swiftlint:enable function_body_length

}
