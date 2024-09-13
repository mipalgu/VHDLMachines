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

    /// Generate a filesystem model for a ``Machine``.
    /// - Parameter machine: The machine to generate a model from.
    /// - Parameter name: The name of the machine.
    /// - Returns: The `FileWrapper` of the machine folder with the model inside.
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

    /// Generate the filesystem model of an ``Arrangement``.
    /// - Parameters:
    ///   - arrangement: The arrangement to generate.
    ///   - name: The name of the arrangement.
    /// - Returns: A `FileWrapper` of the arrangement folder with the model inside.
    @inlinable
    public func generate(arrangement: Arrangement, name: VariableName) -> FileWrapper? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(arrangement) else {
            return nil
        }
        let arrangementWrapper = FileWrapper(regularFileWithContents: data)
        arrangementWrapper.preferredFilename = "arrangement.json"
        let folderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        folderWrapper.preferredFilename = "\(name.rawValue).arrangement"
        _ = folderWrapper.addFileWrapper(arrangementWrapper)
        return folderWrapper
    }

}
