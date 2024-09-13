//
//  File.swift
//
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import SwiftUtils
import VHDLParsing

/// A struct that compiles a VHDL machine into a VHDL source file (vhd).
///
/// The source file is located within the machine folder at <machine_name>.vhd.
public struct VHDLCompiler {

    /// Create a VHDL compiler.
    @inlinable
    public init() {}

    /// Compile an arrangement into a VHDL source file within an arrangement folder.
    ///
    /// - Parameters:
    ///   - arrangement: The arrangement to convert into VHDL.
    ///   - name: The name of the arrangement.
    ///   - createRepresentation: A function that creates the VHDL representation used.
    /// - Returns: A `FileWrapper` consisting of the VHDL source files within an unnamed parent folder.
    /// - SeeAlso: ``ArrangementVHDLRepresentable``.
    public func compile<T>(
        arrangement: Arrangement,
        name: VariableName,
        createRepresentation: @escaping (Arrangement, VariableName) -> T? = {
            ArrangementRepresentation(arrangement: $0, name: $1)
        }
    ) -> FileWrapper? where T: ArrangementVHDLRepresentable {
        guard
            let representation = createRepresentation(arrangement, name),
            let data = representation.file.rawValue.data(using: .utf8)
        else {
            return nil
        }
        let fileName = "\(name.rawValue).vhd"
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = fileName
        return FileWrapper(directoryWithFileWrappers: [fileName: fileWrapper])
    }

    /// Compile a machine into a VHDL source file within the machine folder.
    ///
    /// - Parameter machine: The machine to compile.
    /// - Parameter name: The name of the machine.
    /// - Parameter createRepresentation: A function that creates the VHDL representation used.
    /// - Returns: A `FileWrapper` consisting of the VHDL source files within an unnamed parent folder.
    /// - SeeAlso: ``MachineVHDLRepresentable``.
    @inlinable
    public func compile<T>(
        machine: Machine,
        name: VariableName,
        createRepresentation: @escaping (Machine, VariableName) -> T? = {
            MachineRepresentation(machine: $0, name: $1)
        }
    ) -> FileWrapper? where T: MachineVHDLRepresentable {
        guard
            let format = createRepresentation(machine, name),
            let data = VHDLFile(representation: format).rawValue.data(using: .utf8)
        else {
            return nil
        }
        let fileName = "\(name.rawValue).vhd"
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = fileName
        return FileWrapper(directoryWithFileWrappers: [fileName: fileWrapper])
    }

}
