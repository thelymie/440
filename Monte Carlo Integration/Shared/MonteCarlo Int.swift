//
//  MonteCarlo Int.swift
//  MonteCarlo Integration
//
//  Created by Alaina Thompson on 2/4/22.
//  Modified by Will Limestall on 11 Feb 2022
import Foundation
import SwiftUI
import Darwin

class MonteCarloInt: NSObject, ObservableObject {
    
    @MainActor @Published var insideData = [(xPoint: Double, yPoint: Double)]()
    @MainActor @Published var outsideData = [(xPoint: Double, yPoint: Double)]()
    @Published var totalGuessesString = ""
    @Published var guessesString = ""
    @Published var MCstring = ""
    @Published var enableButton = true
    @Published var errorString = ""
    @Published var log10ErrorString = ""
    @Published var actualValueString = ""
    //var actualResult = 0.6321205588285577
    var actualResult = 0.0
    var yMax = 0.0
    var e = Darwin.M_E
    var MCresult = 0.0
    var iterations = 1
    var totalIterations = 0
    var totalIntegral = 0.0
    var error = 0.0
    var firstTimeThroughLoop = true
    
    @MainActor init(withData data: Bool){
        
        super.init()
        
        insideData = []
        outsideData = []
        
    }


    /// calculate the value of e^-x from 0 to 1
    /// answer should be close to  0.6321
    /// - Calculates the Value of e^-x using Monte Carlo Integration
    ///
    /// - Parameter sender: Any
    func calculationFunction(functCalcSel: Int) async {
        
        var maxGuesses = 0.0
        //Instantiates Class needed to calculate the area of the bounding box.
        let boundingBoxCalculator = BoundingBox()
        
        maxGuesses = Double(iterations)
        
        //var functionSelect = ["f(x) = x", "f(x) = x^(2)", "f(x) = x^(3)", "f(x) = e^(x)", "f(x) = e^(-x)","f(x) = x e^(x)","f(x) = x e^(-x)","f(x) = x^(2) e^(x)", "f(x) = x^(2)e^(-x)"]
        switch functCalcSel{
        case 0: // int[x, {x, 0, 1}]
            actualResult = pow(2.0,-1.0)
            yMax = 1
        case 1: //Int[x^2, {x, 0, 1}]
            actualResult = pow(3.0,-1.0)
            yMax = 1
        case 2:  //Int[x^3, {x, 0, 1}]
            actualResult = pow(4.0,-1.0)
            yMax = 1
        case 3:  //Int[E^(x), {x, 0, 1}]
            actualResult = -1 + e
            yMax = e
        case 4:  // Int[E^-x, {x, 0, 1}]
            actualResult = (-1+e)/e
            yMax = pow(e, 0.0)
        case 5:  // Int[x e^(x), {x, 0, 1}]
            actualResult = 1.00000000000
            yMax = e
        case 6:  // Int[x e^(-x), {x, 0, 1}]
            actualResult = (-2 + e)/e
            yMax = pow(e, -1.0)
        case 7:  // Int[x^2 e^x]
            actualResult = -2 + e
            yMax = e
        case 8:  //  Int[x^2, e^-x
            actualResult = 2.0 - (5.0/e)
            yMax = pow(e, -1.0)
        default:  // Int[E^-x, {x, 0, 1}]
            actualResult = (-1+e)/e
            yMax = pow(e, 0.0)
        }
        
        let newValue = await calculateMonteCarloIntegral(e: e, maxGuesses: maxGuesses, selectedFunctIndex: functCalcSel, yMax: yMax)
        
        totalIntegral = totalIntegral + newValue
        
        totalIterations = totalIterations + iterations
        
        await updateTotalGuessesString(text: "\(totalIterations)")
        
        // update actual value

        
        //totalGuessesString = "\(totalGuesses)"
        
        ///Calculates the value of π from the area of a unit circle
        
        MCresult = totalIntegral/Double(totalIterations) * boundingBoxCalculator.calculateSurfaceArea(numberOfSides: 2, lengthOfSide1: 1.0, lengthOfSide2: yMax, lengthOfSide3: 0.0)

        
        error = abs((actualResult - MCresult)/actualResult)
        await updateMCString(text: "\(MCresult)")
        await updateErrorString(text: "\(error*100)")
        await updateActualValueString(text: "\(actualResult)")
        await updateLog10ErrorString(text: "\(abs(log10(error)))")
        
    }
    ///
    ///

    // ****************************************
    // calculate f(x) = x
    // ****************************************
   
    func calculateMonteCarloIntegral(e: Double, maxGuesses: Double, selectedFunctIndex: Int, yMax: Double) async -> Double {
        
        var numberOfGuesses = 0.0
        var pointsInFunction = 0.0
        var integral = 0.0
        var point = (xPoint: 0.0, yPoint: 0.0)
        var calculatedPoint = 0.0
        var newInsidePoints : [(xPoint: Double, yPoint: Double)] = []
        var newOutsidePoints : [(xPoint: Double, yPoint: Double)] = []
        
        
        while numberOfGuesses < maxGuesses {
            
            /* Calculate 2 random values within the box */
            /* Determine the distance from that point to the origin */
            /* If the distance is less than the unit radius count the point being within the Unit Circle */
            point.xPoint = Double.random(in: 0.0...1.0)
         
            // maximum y point value is yMax
            point.yPoint = Double.random(in: 0.0...yMax)
            
            // switch for selecting the calculated value
            //var functionSelect = ["f(x) = x","f(x) = x^(2)","f(x) = x^(3)","f(x) = e^(x)", "f(x) = e^(-x)","f(x) = x e^(x)","f(x) = x e^(-x)","f(x) = x^(2) e^(x)", "f(x) = x^(2)e^(-x)"]
            switch selectedFunctIndex{
            case 0:  // calculate f(x)=x
                calculatedPoint = point.xPoint
            case 1:  // calculate f(x) = x^2
                calculatedPoint = pow(point.xPoint,2.0)
            case 2:  // calculate f(x) = x^3
                calculatedPoint = pow(point.xPoint,3.0)
            case 3:  // calculate f(x) = e^x
                calculatedPoint = pow(e, point.xPoint)
            case 4:  // Calculate f(x)=e^(-x)
                calculatedPoint = pow(e, -point.xPoint)
            case 5:  // Calculate f(x) = x e^(x)
                calculatedPoint = point.xPoint*pow(e, point.xPoint)
            case 6:  // Calclulate f(x) = x e^(-x)
                calculatedPoint = point.xPoint*pow(e, -point.xPoint)
            case 7:  // Calcluate f(x) = x^2 e^x
                calculatedPoint = pow(point.xPoint, 2.0)*pow(e, point.xPoint)
            case 8:  // Calculate f(x) = x^2 e^(-x)
                calculatedPoint = pow(point.xPoint, 2.0)*pow(e, -point.xPoint)
            default:  // Calculate e^(-x)
                calculatedPoint = pow(e, -point.xPoint)
            
            }
            // Calculate e^(-x)
            //calculatedPoint = pow(e, -point.xPoint)
            
            
          
            if((calculatedPoint - point.yPoint) >= 0.0){
                pointsInFunction += 1.0
                
                
                newInsidePoints.append(point)
               
            }
            else { //if outside the circle do not add to the number of points in the radius
                
                
                newOutsidePoints.append(point)

                
            }
            
            numberOfGuesses += 1.0
            
            
            
            
            }

        
        integral = Double(pointsInFunction)
        
        //Append the points to the arrays needed for the displays
        //Don't attempt to draw more than 250,000 points to keep the display updating speed reasonable.
        // tried to move it up to 50 million points
        
        
        if ((totalIterations < 50000001) || (firstTimeThroughLoop)){
        
//            insideData.append(contentsOf: newInsidePoints)
//            outsideData.append(contentsOf: newOutsidePoints)
            
            var plotInsidePoints = newInsidePoints
            var plotOutsidePoints = newOutsidePoints
            
            if (newInsidePoints.count > 750001) {
                
                plotInsidePoints.removeSubrange(750001..<newInsidePoints.count)
            }
            
            if (newOutsidePoints.count > 750001){
                plotOutsidePoints.removeSubrange(750001..<newOutsidePoints.count)
                
            }
            
            await updateData(insidePoints: plotInsidePoints, outsidePoints: plotOutsidePoints)
            firstTimeThroughLoop = false
        }
        
        return integral
        }
    
    
    /// updateData
    /// The function runs on the main thread so it can update the GUI
    /// - Parameters:
    ///   - insidePoints: points inside the circle of the given radius
    ///   - outsidePoints: points outside the circle of the given radius
    @MainActor func updateData(insidePoints: [(xPoint: Double, yPoint: Double)] , outsidePoints: [(xPoint: Double, yPoint: Double)]){
        
        insideData.append(contentsOf: insidePoints)
        outsideData.append(contentsOf: outsidePoints)
    }
    
    /// updateTotalGuessesString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the number of total guesses
    @MainActor func updateTotalGuessesString(text:String){
        
        self.totalGuessesString = text
        
    }
    

  
    @MainActor func updateMCString(text:String){
        
        self.MCstring = text
        
    }
    
    @MainActor func updateErrorString(text:String){
        
        self.errorString = text
        
    }
    
    @MainActor func updateLog10ErrorString(text:String){
        
        self.log10ErrorString = text
        
    }
    
    
    
    @MainActor func updateActualValueString(text:String){
        
        self.actualValueString = text
        
    }
    
    
    /// setButton Enable
    /// Toggles the state of the Enable Button on the Main Thread
    /// - Parameter state: Boolean describing whether the button should be enabled.
    @MainActor func setButtonEnable(state: Bool){
        
        
        if state {
            
            Task.init {
                await MainActor.run {
                    
                    
                    self.enableButton = true
                }
            }
            
            
                
        }
        else{
            
            Task.init {
                await MainActor.run {
                    
                    
                    self.enableButton = false
                }
            }
                
        }
        
    }

}
