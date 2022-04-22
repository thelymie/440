//
//  BoundingBox.swift
//  MonteCarlo Integration
//
//  Created by Alaina Thompson on 2/4/22.
//  Modified by Will Limestall on 11 Feb 2022

import Foundation
import SwiftUI

class BoundingBox: NSObject {
    
    
    /// calculateVolume
    ///
    /// - Parameters:
    ///   - lengthOfSide1: length of the first side
    ///   - lengthOfSide2: length of the second side
    ///   - lengthOfSide3: length of the third side
    /// - Returns: returns the volume of a box
    func calculateVolume(lengthOfSide1: Double, lengthOfSide2: Double, lengthOfSide3: Double) -> Double {
        
        return (lengthOfSide1*lengthOfSide2*lengthOfSide3)
        
    }
    
    /// calculateSurfaceArea
    ///
    /// - Parameters:
    ///   - numberOfSides: number of sides of the box
    ///   - lengthOfSide1: length of the first side
    ///   - lengthOfSide2: length of the second side
    ///   - lengthOfSide3: length of the third side
    /// - Returns: returns the surface area of the box
    func calculateSurfaceArea(numberOfSides: Int, lengthOfSide1: Double, lengthOfSide2: Double, lengthOfSide3: Double) -> Double {
        
        var surfaceArea = 0.0
        
        
        if numberOfSides == 2 {
            
            surfaceArea = lengthOfSide1*lengthOfSide2
            
        } else if numberOfSides == 6 {
            
            surfaceArea = 2*lengthOfSide1*lengthOfSide2 + 2*lengthOfSide2*lengthOfSide3 + 2*lengthOfSide1*lengthOfSide3
            
            
        } else {
            
            surfaceArea = 0.0
            
        }
        
        return (surfaceArea)
    }

}
