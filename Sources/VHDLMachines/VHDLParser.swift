//
//  File.swift
//  
//
//  Created by Morgan McColl on 12/6/21.
//

import Foundation
#if os(Linux) || os(Windows)
import SwiftUtils
#endif

/// A parser for VHDL machines. This struct reads the contents of a `FileWrapper` and parses the machine
/// within. The `FileWrapper` must be consistent with the structure generated using ``VHDLGenerator``.
public struct VHDLParser {

    /// A helper decoder.
    @usableFromInline let decoder = JSONDecoder()

    /// Create a new parser.
    @inlinable
    public init() {}

    /// Parse a FileWrapper and return the machine within. This structure of the `FileWrapper` must be
    /// consistent with the structure generated using ``VHDLGenerator``.
    /// - Parameter wrapper: The `FileWrapper` to parse.
    /// - Returns: The machine within the `FileWrapper` or `nil` if the `FileWrapper` is not consistent with
    /// the structure generated using ``VHDLGenerator``.
    @inlinable
    public func parse(wrapper: FileWrapper) -> Machine? {
        guard
            wrapper.isDirectory,
            let machineWrapper = wrapper.fileWrappers?["machine.json"],
            machineWrapper.isRegularFile,
            let data = machineWrapper.regularFileContents,
            let machine = try? decoder.decode(Machine.self, from: data)
        else {
            return nil
        }
        return machine
    }

    public func parseArrangement(wrapper: FileWrapper) -> Arrangement? {
        guard
            wrapper.isDirectory,
            let arrangementWrapper = wrapper.fileWrappers?["arrangement.json"],
            arrangementWrapper.isRegularFile,
            let data = arrangementWrapper.regularFileContents,
            let arrangement = try? decoder.decode(Arrangement.self, from: data)
        else {
            return nil
        }
        return arrangement
    }

}
