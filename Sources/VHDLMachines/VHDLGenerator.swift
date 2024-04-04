//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/5/21.
//

import Foundation
#if os(Linux) || os(Windows)
import SwiftUtils
#endif
import VHDLParsing

/// A generator that can generate a `FileWrapper` from a ``Machine``.
public struct VHDLGenerator {

    /// Create a new generator.
    @inlinable
    public init() {}

    /// Generate a `FileWrapper` from a ``Machine``.
    /// - Parameter machine: The machine to generate a `FileWrapper` from.
    /// - Parameter name: The name of the machine.
    /// - Returns: The `FileWrapper` that represents the machine or nil if the machine could not be encoded.
    @inlinable
    public func generate(machine: Machine, with name: VariableName) -> FileWrapper? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(machine) else {
            return nil
        }
        let machineWrapper = FileWrapper(regularFileWithContents: data)
        machineWrapper.preferredFilename = "machine.json"
        let folderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        folderWrapper.preferredFilename = "\(name.rawValue).machine"
        _ = folderWrapper.addFileWrapper(machineWrapper)
        return folderWrapper
    }

}
