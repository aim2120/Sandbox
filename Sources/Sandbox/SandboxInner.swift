//
//  File.swift
//  
//
//  Created by Annalise Mariottini on 12/28/23.
//

#if !os(WASI) && !os(Windows)
import Foundation

class Inner {
    func run() {
        print("Hello world")
    }
}

#endif
