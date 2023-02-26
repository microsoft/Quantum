
namespace IPE {
    //IMPORT LIBRARIES
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;



    operation StateInitialisation(TargetReg : Qubit, AncilReg : Qubit, Theta1 : Double, Theta2 : Double) : Unit is Adj + Ctl { //This is state preperation operator A for encoding the 2D vector (page 7)
        H(AncilReg);

        Controlled R([AncilReg], (PauliY, -Theta1, TargetReg));        // Arbitrary controlled rotation based on theta. This is vector v.
                                                            
        X(AncilReg);                                                   // X gate on ancilla to change from |+> to |->.
        Controlled R([AncilReg], (PauliY, -Theta2, TargetReg));        // Arbitrary controlled rotation based on theta. This is vector c.
        X(AncilReg);                                                  
        H(AncilReg);                                                  
    }



     operation GOracle(TargetReg : Qubit, AncilReg : Qubit, Theta1 : Double, Theta2 : Double) : Unit is Adj + Ctl {
        Z(AncilReg);                                                      
        Adjoint StateInitialisation(TargetReg, AncilReg, Theta1, Theta2);
        X(AncilReg);                                                        // Apply X gates individually here as currently ApplyAll is not Adj + Ctl
        X(TargetReg);
        Controlled Z([AncilReg],TargetReg);
        X(AncilReg);
        X(TargetReg);
        StateInitialisation(TargetReg, AncilReg, Theta1, Theta2);         
    }



    operation IterativePhaseEstimation(TargetReg : Qubit, AncilReg : Qubit, Theta1 : Double, Theta2 : Double, Measurements : Int) : Int{
        use ControlReg = Qubit();
        mutable MeasureControlReg = ConstantArray(Measurements, Zero);                                  //Set up array of measurement results of zero
        mutable bitValue = 0;
        StateInitialisation(TargetReg, AncilReg, Theta1, Theta2);                                       //Apply to initialise state, this is defined by the angles theta1 and theta2
        for index in 0 .. Measurements - 1{                                                             
            H(ControlReg);                                                                              
            if index > 0 {                                                                              //Don't apply rotation on first set of oracles
                for index2 in 0 .. index - 1{                                                           //Loop through previous results
                    if MeasureControlReg[Measurements - 1 - index2] == One{                             
                        R(PauliZ, -IntAsDouble(2^(index2))*PI()/(2.0^IntAsDouble(index)), ControlReg);  
                    }
                }
                
            }
            let powerIndex = (1 <<< (Measurements - 1 - index));
            for _ in 1 .. powerIndex{                                                                   //Apply a number of oracles equal to 2^index, where index is the number or measurements left
                    Controlled GOracle([ControlReg],(TargetReg, AncilReg, Theta1, Theta2));
                }
            H(ControlReg);
            set MeasureControlReg w/= (Measurements - 1 - index) <- MResetZ(ControlReg);                //Make a measurement mid circuit 
            if MeasureControlReg[Measurements - 1 - index] == One{
                set bitValue += 2^(index);                                                              //Assign bitValue based on previous measurement
                                                                                                        
            }
        }
        Reset(ControlReg);                                                                              //Reset qubits for end of circuit.
        Reset(TargetReg);                                           
        Reset(AncilReg); 
        return bitValue;
    }

    
    
    operation SimulateInnerProduct() : Int{
        let Theta1 = 0.0;                                                                           //Specify the angles for inner product
        let Theta2 = 0.0;
        let Measurements = 3;                                                                       //Specify the bit resolution in the iterative phase estimation
                                                                                                    //For Jobs on hardware the suggested number of measurements is 3
        use TargetReg = Qubit();                                                                    //TargetReg has states v and c qubits contained on it
        use AncilReg = Qubit();                                                                     //Create ancilla
        let Results = IterativePhaseEstimation(TargetReg, AncilReg, Theta1, Theta2, Measurements);  //This runs iterative phase estimation
        

        let DoubleVal = PI() * IntAsDouble(Results) / IntAsDouble(2 ^ (Measurements-1));
        let InnerProductValue = -Cos(DoubleVal);                                                      //Convert to the final inner product
        Message("The Inner Product is:");
        Message($"{InnerProductValue}");
        Message("The True Inner Product is:");
        Message($"{Cos(Theta1/2.0)*Cos(Theta2/2.0)+Sin(Theta1/2.0)*Sin(Theta2/2.0)}");
        Message("The Bit Value measured is");

                                                                                
        return Results;                                                                             //Return Measured values
    }



    @EntryPoint()
    operation InnerProduct() : Int{
        let Theta1 = 0.0;                                                                           //Specify the angles for inner product
        let Theta2 = 0.0;
        let Measurements = 3;                                                                       //Specify the bit resolution in the iterative phase estimation
                                                                                                    //For Jobs on hardware the suggested number of measurements is 3
        use TargetReg = Qubit();                                                                    //TargetReg has states v and c qubits contained on it
        use AncilReg = Qubit();                                                                     //Create ancilla
        let Results = IterativePhaseEstimation(TargetReg, AncilReg, Theta1, Theta2, Measurements);  //This runs iterative phase estimation
                                                                            
        return Results;                                                                             //Return Measured values
    }
    

}
