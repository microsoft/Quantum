
namespace IPE {
    //IMPORT LIBRARIES
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;



    operation StateInitialisation(TargetReg : Qubit, AncilReg : Qubit, theta_1 : Double, theta_2 : Double) : Unit is Adj + Ctl { //This is state preperation operator A for encoding the 2D vector (page 7)
        H(AncilReg);
        // Arbitrary controlled rotation based on theta. This is vector v.
        Controlled R([AncilReg], (PauliY, theta_1, TargetReg));        
        // X gate on ancilla to change from |+> to |->.                                    
        X(AncilReg);
        // Arbitrary controlled rotation based on theta. This is vector c.                                                   
        Controlled R([AncilReg], (PauliY, theta_2, TargetReg));        
        X(AncilReg);                                                  
        H(AncilReg);                                                  
    }



    operation GOracle(TargetReg : Qubit, AncilReg : Qubit, theta_1 : Double, theta_2 : Double) : Unit is Adj + Ctl {
        Z(AncilReg);
        within {
            Adjoint StateInitialisation(TargetReg, AncilReg, theta_1, theta_2);
            X(AncilReg);                                                        
            X(TargetReg);
        }   
        apply {
            Controlled Z([AncilReg],TargetReg);
        }
    }



    operation IterativePhaseEstimation(TargetReg : Qubit, AncilReg : Qubit, theta_1 : Double, theta_2 : Double, Measurements : Int) : Int{
        use ControlReg = Qubit();
        mutable MeasureControlReg = [Zero, size = Measurements];
        mutable bitValue = 0;
        //Apply to initialise state, this is defined by the angles theta_1 and theta_2
        StateInitialisation(TargetReg, AncilReg, theta_1, theta_2);                                     
        for index in 0 .. Measurements - 1{                                                             
            H(ControlReg);
            //Don't apply rotation on first set of oracles                                                                              
            if index > 0 {                      
                //Loop through previous results                                                        
                for index2 in 0 .. index - 1{                                                           
                    if MeasureControlReg[Measurements - 1 - index2] == One{
                        //Rotate control qubit dependent on previous measurements and number of measurements 
                        let angle = -IntAsDouble(2^(index2))*PI()/(2.0^IntAsDouble(index));           
                        R(PauliZ, angle, ControlReg);                                                  
                    }
                }
                
            }
            let powerIndex = (1 <<< (Measurements - 1 - index));
            //Apply a number of oracles equal to 2^index, where index is the number or measurements left
            for _ in 1 .. powerIndex{
                    Controlled GOracle([ControlReg],(TargetReg, AncilReg, theta_1, theta_2));
                }
            H(ControlReg);
            //Make a measurement mid circuit
            set MeasureControlReg w/= (Measurements - 1 - index) <- MResetZ(ControlReg);                 
            if MeasureControlReg[Measurements - 1 - index] == One{
                //Assign bitValue based on previous measurement
                set bitValue += 2^(index);                                                              
                                                                                                        
            }
        }
        return bitValue;
    }



    function CalculateInnerProduct(Results : Int, theta_1 : Double, theta_2 : Double, Measurements : Int): Unit{
        //Convert to the final inner product
        let DoubleVal = PI() * IntAsDouble(Results) / IntAsDouble(2 ^ (Measurements-1));
        let InnerProductValue = -Cos(DoubleVal);                                                      
        Message("The Bit Value measured is:");
        Message($"{Results}");
        Message("The Inner Product is:");
        Message($"{InnerProductValue}");
        Message("The True Inner Product is:");
        Message($"{Cos(theta_1/2.0)*Cos(theta_2/2.0)+Sin(theta_1/2.0)*Sin(theta_2/2.0)}");
    }



    //Operation for calculating the inner product on local simulators
    //This operation will output additional classical calculations
    operation SimulateInnerProduct() : Unit{                                                        
        let (Results, theta_1, theta_2, Measurements) = InnerProduct();                             
        CalculateInnerProduct(Results, theta_1, theta_2, Measurements);                             
    }


    @EntryPoint()
    //Operation for calculating the inner product on hardware or emulators
    operation HardwareInnerProduct() : Int{                                                         
        let (Results,_,_,_) = InnerProduct();
        return Results;                                                                             
    }



    operation InnerProduct() : (Int, Double, Double, Int){
        //Specify the angles for inner product
        let theta_1 = 0.0;                                                                           
        let theta_2 = 0.0;
        let Measurements = 3;
        //Create target register
        use TargetReg = Qubit();
        //Create ancilla register
        use AncilReg = Qubit();
        //Run iterative phase estimation
        let Results = IterativePhaseEstimation(TargetReg, AncilReg, theta_1, theta_2, Measurements);
        Reset(TargetReg);                                           
        Reset(AncilReg);
        return (Results, theta_1, theta_2, Measurements);
    }  
}
