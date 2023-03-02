
namespace IPE {
    //IMPORT LIBRARIES
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;



    operation StateInitialisation(TargetReg : Qubit, AncilReg : Qubit, theta_1 : Double, theta_2 : Double) : Unit is Adj + Ctl { //This is state preperation operator A for encoding the 2D vector (page 7)
        H(AncilReg);

        Controlled R([AncilReg], (PauliY, theta_1, TargetReg));        // Arbitrary controlled rotation based on theta. This is vector v.
                                                            
        X(AncilReg);                                                   // X gate on ancilla to change from |+> to |->.
        Controlled R([AncilReg], (PauliY, theta_2, TargetReg));        // Arbitrary controlled rotation based on theta. This is vector c.
        X(AncilReg);                                                  
        H(AncilReg);                                                  
    }



    operation GOracle(TargetReg : Qubit, AncilReg : Qubit, theta_1 : Double, theta_2 : Double) : Unit is Adj + Ctl {
        Z(AncilReg);
        within {
            Adjoint StateInitialisation(TargetReg, AncilReg, theta_1, theta_2);
            X(AncilReg);                                                        // Apply X gates individually here as currently ApplyAll is not Adj + Ctl
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
        StateInitialisation(TargetReg, AncilReg, theta_1, theta_2);                                       //Apply to initialise state, this is defined by the angles theta_1 and theta_2
        for index in 0 .. Measurements - 1{                                                             
            H(ControlReg);                                                                              
            if index > 0 {                                                                              //Don't apply rotation on first set of oracles
                for index2 in 0 .. index - 1{                                                           //Loop through previous results
                    if MeasureControlReg[Measurements - 1 - index2] == One{
                        let angle = -IntAsDouble(2^(index2))*PI()/(2.0^IntAsDouble(index));                   
                        R(PauliZ, angle, ControlReg);                                                  //Rotate control qubit dependent on previous measurements and number of measurements 
                    }
                }
                
            }
            let powerIndex = (1 <<< (Measurements - 1 - index));
            for _ in 1 .. powerIndex{                                                                   //Apply a number of oracles equal to 2^index, where index is the number or measurements left
                    Controlled GOracle([ControlReg],(TargetReg, AncilReg, theta_1, theta_2));
                }
            H(ControlReg);
            set MeasureControlReg w/= (Measurements - 1 - index) <- MResetZ(ControlReg);                //Make a measurement mid circuit 
            if MeasureControlReg[Measurements - 1 - index] == One{
                set bitValue += 2^(index);                                                              //Assign bitValue based on previous measurement
                                                                                                        
            }
        }
        return bitValue;
    }



    function CalculateInnerProduct(Results : Int, theta_1 : Double, theta_2 : Double, Measurements : Int): Unit{
        let DoubleVal = PI() * IntAsDouble(Results) / IntAsDouble(2 ^ (Measurements-1));
        let InnerProductValue = -Cos(DoubleVal);                                                      //Convert to the final inner product
        Message("The Bit Value measured is:");
        Message($"{Results}");
        Message("The Inner Product is:");
        Message($"{InnerProductValue}");
        Message("The True Inner Product is:");
        Message($"{Cos(theta_1/2.0)*Cos(theta_2/2.0)+Sin(theta_1/2.0)*Sin(theta_2/2.0)}");
    }




    operation SimulateInnerProduct() : Unit{                                                        //Operation for calculating the inner product on local simulators
        let (Results, theta_1, theta_2, Measurements) = InnerProduct();                             //This operation will output additional classical calculations
        CalculateInnerProduct(Results, theta_1, theta_2, Measurements);                             
    }


    @EntryPoint()
    operation HardwareInnerProduct() : Int{                                                         //Operation for calculating the inner product on hardware or emulators
        let (Results,_,_,_) = InnerProduct();
        return Results;                                                                             
    }



    operation InnerProduct() : (Int, Double, Double, Int){
        let theta_1 = 0.0;                                                                           //Specify the angles for inner product
        let theta_2 = 0.0;
        let Measurements = 3;
        use TargetReg = Qubit();                                                                    //Create target register
        use AncilReg = Qubit();                                                                     //Create ancilla register
        let Results = IterativePhaseEstimation(TargetReg, AncilReg, theta_1, theta_2, Measurements);//This runs iterative phase estimation
        Reset(TargetReg);                                           
        Reset(AncilReg);
        return (Results, theta_1, theta_2, Measurements);
    }  
}
