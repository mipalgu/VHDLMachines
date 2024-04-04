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

    /// A file helper.
    @usableFromInline let manager = FileManager.default

    /// Create a VHDL compiler.
    @inlinable
    public init() {}

    /// Compile a machine into a VHDL source file within the machine folder specified by the machines path.
    /// - Parameter machine: The machine to compile.
    /// - Parameter url: The location to the machine folder. This url must end with a `.machine` extension.
    /// - Returns: Whether the compilation was successful.
    @inlinable
    public func compile(_ machine: Machine, location url: URL) -> Bool {
        let name = url.lastPathComponent
        guard
            name.hasSuffix(".machine"),
            let nameVar = VariableName(rawValue: String(name.dropLast(8))),
            let format = generateVHDLFile(machine: machine, name: nameVar)
        else {
            return false
        }
        let fileName = "\(nameVar.rawValue).vhd"
        guard let data = format.data(using: .utf8) else {
            return false
        }
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = fileName
        let folderWrapper = FileWrapper(directoryWithFileWrappers: [fileName: fileWrapper])
        var isDirectory: ObjCBool = false
        if manager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
            guard (try? manager.removeItem(at: url)) != nil else {
                return false
            }
        }
        return (try? folderWrapper.write(to: url, options: .atomic, originalContentsURL: nil)) != nil
    }

    /// Generate the VHDL source code for a machine.
    /// - Parameter machine: The machine to compile.
    /// - Returns: The VHDL source code.
    @inlinable
    func generateVHDLFile(machine: Machine, name: VariableName) -> String? {
        guard let representation = MachineRepresentation(machine: machine, name: name) else {
            return nil
        }
        return VHDLFile(representation: representation).rawValue
    }

}
