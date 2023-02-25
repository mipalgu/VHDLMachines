//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO
import VHDLParsing

/// A struct that compiles a VHDL machine into a VHDL source file (vhd). The source file is located
/// within the machine folder at <machine_name>.vhd.
public struct VHDLCompiler {

    /// A file helper.
    @usableFromInline let helper = FileHelpers()

    /// Create a VHDL compiler.
    @inlinable
    public init() {}

    /// Compile a machine into a VHDL source file within the machine folder specified by the machines path.
    /// - Parameter machine: The machine to compile.
    /// - Returns: Whether the compilation was successful.
    @inlinable
    public func compile(_ machine: Machine) -> Bool {
        guard let format = generateVHDLFile(machine) else {
            return false
        }
        let fileName = "\(machine.name).vhd"
        guard let data = format.data(using: .utf8) else {
            return false
        }
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = fileName
        guard
            let file2 = VHDLFile(kripkeFor: machine),
            let data2 = file2.rawValue.data(using: .utf8),
            let package = file2.packages.first
        else {
            return false
        }
        let fileWrapper2 = FileWrapper(regularFileWithContents: data2)
        let filename2 = package.name.rawValue + ".vhd"
        fileWrapper2.preferredFilename = filename2
        let folderWrapper = FileWrapper(
            directoryWithFileWrappers: [fileName: fileWrapper, filename2: fileWrapper2]
        )
        if helper.directoryExists(machine.path.path) {
            guard helper.deleteItem(atPath: machine.path) else {
                return false
            }
        }
        return (try? folderWrapper.write(to: machine.path, options: .atomic, originalContentsURL: nil)) != nil
    }

    /// Generate the VHDL source code for a machine.
    /// - Parameter machine: The machine to compile.
    /// - Returns: The VHDL source code.
    @usableFromInline
    func generateVHDLFile(_ machine: Machine) -> String? {
        guard let representation = MachineRepresentation(machine: machine) else {
            return nil
        }
        return VHDLFile(representation: representation).rawValue
    }

}
