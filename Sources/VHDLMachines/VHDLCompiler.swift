//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import SwiftUtils
import VHDLParsing

/// A struct that compiles a VHDL machine into a VHDL source file (vhd). The source file is located
/// within the machine folder at <machine_name>.vhd.
public struct VHDLCompiler {

    /// Create a VHDL compiler.
    @inlinable
    public init() {}

    public func compile(_ arrangement: Arrangement, location url: URL) -> FileWrapper? {
        let name = url.lastPathComponent
        guard
            name.hasSuffix(".arrangement"),
            let nameVar = VariableName(rawValue: String(name.dropLast(11))),
            let representation = ArrangementRepresentation(arrangement: arrangement, name: nameVar),
            let data = representation.file.rawValue.data(using: .utf8)
        else {
            return nil
        }
        let fileName = "\(nameVar.rawValue).vhd"
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = fileName
        return FileWrapper(directoryWithFileWrappers: [fileName: fileWrapper])
    }

    /// Compile a machine into a VHDL source file within the machine folder specified by the machines path.
    /// - Parameter machine: The machine to compile.
    /// - Parameter url: The location to the machine folder. This url must end with a `.machine` extension.
    /// - Returns: Whether the compilation was successful.
    @inlinable
    public func compile(_ machine: Machine, location url: URL) -> FileWrapper? {
        let name = url.lastPathComponent
        guard
            name.hasSuffix(".machine"),
            let nameVar = VariableName(rawValue: String(name.dropLast(8))),
            let format = generateVHDLFile(machine: machine, name: nameVar),
            let data = format.data(using: .utf8)
        else {
            return nil
        }
        let fileName = "\(nameVar.rawValue).vhd"
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = fileName
        return FileWrapper(directoryWithFileWrappers: [fileName: fileWrapper])
    }

    /// Generate the VHDL source code for a machine.
    /// - Parameter machine: The machine to compile.
    /// - Parameter name: The name of the machine.
    /// - Returns: The VHDL source code.
    @inlinable
    func generateVHDLFile<T>(
        machine: Machine, name: VariableName, createRepresentation: @escaping (Machine, VariableName) -> T?
    ) -> String? where T: MachineVHDLRepresentable {
        createRepresentation(machine, name).flatMap { VHDLFile(representation: $0).rawValue }
    }

    /// Generate the VHDL source code for a machine.
    /// - Parameter machine: The machine to compile.
    /// - Parameter name: The name of the machine.
    /// - Returns: The VHDL source code.
    @inlinable
    func generateVHDLFile(machine: Machine, name: VariableName) -> String? {
        generateVHDLFile(machine: machine, name: name) {
            MachineRepresentation(machine: $0, name: $1)
        }
    }

}
