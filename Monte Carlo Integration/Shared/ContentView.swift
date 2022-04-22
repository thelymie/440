//
//  ContentView.swift
//  Shared
//
//  Created by Alaina Thompson on 2/4/22.
//  Modified by Will Limestall on 11 Feb 2022

import SwiftUI

struct ContentView: View {
    // ---------------------------------------------------
    // Pulling subScriptSuperScript.swift class
    // SubSuperScriptText(inputString: String, bodyFont: Font, subScriptFont: Font, baseLine: CGFloat)
    // ----------------------------------------------------
    // e as in Euler number e
    @State var e = Darwin.M_E
    @State var eMinusX = 0.0
    @State var totalGuesses = 0.0
    @State var totalIntegral = 0.0
    // "guessString" not needed
    //@State var guessString = "400"
    @State var totalIterationString = ""
    @State var MCintResultString = ""
    @State var errorString = ""
    @State var ActualValueString = ""
    @State var log10ErrorString = ""
   
    // State functions for Picker
    // Create a menu of selectable items
    // Type of plot menu slection
    
    let a1 = SubSuperScriptText(inputString: "x^{2} + 20x + 100 = 0", bodyFont: .callout, subScriptFont: .caption, baseLine: 6.0)
    
    var functionSelect = ["f(x) = x","f(x) = x^{2}","f(x) = x^{3}","f(x) = e^{x}", "f(x) = e^{-x}","f(x) = x e^{x}","f(x) = x e^{-x}","f(x) = x^{2} e^{x}", "f(x) = x^{2} e^{-x}"]
    // create state variable
    @State private var selectedFunctionIndex = 0
    
    // Create a menu of selectable items
    // Number of intertations
//    var iterationSelect = ["10^3","10^4","10^5","10^6"]
//    @State private var selectedIterationIndex = 0
    
    // create a vars for a slider of iteerations
    // isEditing is for color of text display
    @State private var SliderIterations = 1001.0
    @State private var isEditing = false

    
    
    // Setup the GUI to monitor the data from the Monte Carlo Integral Calculator
    @ObservedObject var monteCarlo = MonteCarloInt(withData: true)
    
    //Setup the GUI View
    var body: some View {
        // ------------------------
              
        // ------------------------
        
        // HStack for displaying on GUI
        HStack{
            // Use a VStack nested in the HStack
            // Left side of HStack are User Entries and Display of numerical values.
            VStack{
                // Drop Down menu for Function select
                VStack {
                    Text("Select Function").font(.largeTitle).bold().padding()
                    
                    //----------
                    //Test superscript and subscript
                    SubSuperScriptText(inputString: "Illinois Tech Physics (PHYS 440) Demostration^{TM}", bodyFont: .callout, subScriptFont: .caption, baseLine: 6.0)
                    //-----------
                    
                    // Picker is used to select a function it is placed into the slected function index.
                    // Comment out Section
                    // ------------------
//                    Picker(selection: $selectedFunctionIndex, label: Text("")) {
//                            ForEach(0 ..< functionSelect.count) {
//                               Text(self.functionSelect[$0])
//                            }//                    }//.padding()
                    // ----------------
                    // Use Super & Sub Scripts in Picker Selection
                    Picker(selection: $selectedFunctionIndex, label: Text("")) {
                            ForEach(0 ..< functionSelect.count) {
                                SubSuperScriptText(inputString: self.functionSelect[$0], bodyFont: .callout, subScriptFont: .caption, baseLine: 6.0)
                            }
                    }
                    //------------------
                    //comment out section
//                    Text("Selected Function:  \(functionSelect[selectedFunctionIndex])").font(.headline).bold()
                    //---------------
                    //Use Super & Sub Scripts in Text output
                    SubSuperScriptText(inputString: "Selected Function:  \(functionSelect[selectedFunctionIndex])", bodyFont: .callout, subScriptFont: .caption, baseLine: 6.0)
                }.padding()
   
                // HStack for a slider and display of total iterations
                HStack {
                    // Slider menu for number of iterations
                    VStack {
                        Slider(
                            value: $SliderIterations,
                            in: 1001...1000001,
                            onEditingChanged: { editing in
                                isEditing = editing
                            }
                        )
                        HStack{Text("Selected Iterations: ")
                            Text("\(Int(SliderIterations))")
                            .foregroundColor(isEditing ? .blue : .white)
                        }
                    }


                    // Display total number of iterations
                    LazyVStack(alignment: .center) {
                        Text("Total Iterations")
                            .font(.headline).bold()
                        TextField("The Total Number of Iterations Used in Monte Carlo", text: $totalIterationString)
                    }
                
                
                }.padding()
                // Display results from the Monte Carlo Integration
                HStack{
                    LazyVStack(alignment: .center) {
                        Text("Known Value of Integral")
                            .font(.headline).bold()
                        TextField("Known Value", text: $ActualValueString)
                    }
                    LazyVStack(alignment: .center) {
                        Text("Numerical Result of Monte Carlo Integration")
                            .font(.headline).bold()
                        TextField("Value of Numerical Integration", text: $MCintResultString)
                    }
                }.padding()
                
                // Display the calculated Percent Error
                HStack {
                    VStack(alignment: .center) {
                        Text("Percent Error (%)")
                            .font(.headline).bold()
                        TextField("Calculated Percent Error between actual value and Monte Carlo Results", text: $errorString)
                            //.padding()
                    }
                    
                    VStack(alignment: .center) {
                        Text("Log10 of Error")
                            .font(.headline).bold()
                        TextField("Log (base 10) of Error between actual value and Monte Carlo Results", text: $log10ErrorString)
                            //.padding()
                    }
                    
                }.padding()
                // Button that is clickable
                Button("Execute Monte Carlo Calculation", action: {Task.init{await self.calculateMonteCarloButton()}})
                    .padding()
                    .disabled(monteCarlo.enableButton == false)
                // Clear
                Button("Clear", action: {self.clear()})
                    .padding(.bottom, 5.0)
                    .disabled(monteCarlo.enableButton == false)
                
                if (!monteCarlo.enableButton){
                    
                    ProgressView()
                }
                
                
            }
            .padding()
            
            //DrawingField
            
            
            drawingView(redLayer:$monteCarlo.insideData, blueLayer: $monteCarlo.outsideData)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
            // Stop the window shrinking to zero.
            Spacer()
            
        }
    }
    
    func calculateMonteCarloButton() async {
        
//        // create temp for the selceted number of iterations
//        // var iterationSelect = ["10^3","10^4","10^5","10^6"]
//        let tempIterationIndex = selectedIterationIndex
//        // switch to let user define number of iterations
//        switch tempIterationIndex {
//        case 0:
//            monteCarlo.iterations = 1001
//        case 1:
//            monteCarlo.iterations = 10001
//        case 2:
//            monteCarlo.iterations = 100001
//        case 3:
//            monteCarlo.iterations = 1000001
//        default:
//            monteCarlo.iterations = 101
//        }
        // create temp value of the State var of SliderIterations
        let tempIterations = SliderIterations
        monteCarlo.iterations = Int(tempIterations)
        
        monteCarlo.setButtonEnable(state: false)
        
        //retrieve value of e from monte carlo
        monteCarlo.e = e
        // Total interations passed on
        monteCarlo.totalIterations = Int(totalIterationString) ?? Int(0.0)
        
        
        let tempFunctionIndex = selectedFunctionIndex
        
        await monteCarlo.calculationFunction(functCalcSel: tempFunctionIndex)
        
        // collect items from Monte Calro Integration Class
        // items are strings sent to the GUI for display
        totalIterationString = monteCarlo.totalGuessesString

        MCintResultString =  monteCarlo.MCstring
        
        ActualValueString = monteCarlo.actualValueString

        errorString = monteCarlo.errorString

        log10ErrorString = monteCarlo.log10ErrorString
        
        monteCarlo.setButtonEnable(state: true)
       
     // end caclculate button for monte carlo
        
    }
    // function used to clear out values on GUI
    func clear(){
        //guessString = "1001"
        ActualValueString = ""
        totalIterationString = ""
        MCintResultString =  ""
        monteCarlo.totalIterations = 0
        monteCarlo.totalIntegral = 0.0
        monteCarlo.insideData = []
        monteCarlo.outsideData = []
        monteCarlo.firstTimeThroughLoop = true
        //Included clearing out error
        errorString = ""
        log10ErrorString = ""
    // end clear function
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 


