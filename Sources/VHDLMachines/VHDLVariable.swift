//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

struct VHDLVariable {
    
    var type: VariableType
    
    var name: String
    
    var defaultValue: String?
    
    var range: (Int, Int)?
    
}
