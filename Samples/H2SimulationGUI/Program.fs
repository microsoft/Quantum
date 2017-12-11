// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.H2Simulation

open System
open System.Windows
open System.Windows.Controls

open Microsoft.Quantum.Simulation.Simulators
open Microsoft.Quantum.Simulation.Core

open Microsoft.FSharp.Core
open Microsoft.FSharp.Collections

open FSharp.Charting
open FSharp.Control
open FSharp.Charting.ChartTypes

module H2PlottingDemo =

    [<STAThread>]
    [<EntryPoint>]
    let main argv =
        // We begin by making an instance of the simulator that we will use to run our Q# code.
        use qsim = new QuantumSimulator()

        // Next, we give F# names to each operation defined in Q#.
        // In doing so, we ask the simulator to give us each operation
        // so that it has an opportunity to override operation definitions.
        let H2EstimateEnergyRPE = qsim.Get<H2EstimateEnergyRPE, H2EstimateEnergyRPE>()
        let H2BondLengths = qsim.Get<H2BondLengths, H2BondLengths>()

        // To call a Q# operation that takes unit `()` as its input, we need to grab
        // the QVoid.Instance value.
        let bondLengths =
            H2BondLengths.Body.Invoke QVoid.Instance

        // In Q#, we defined the operation that performs the actual estimation;
        // we can call it here, giving a structure tuple that corresponds to the
        // C# ValueTuple that it takes as its input. Since the Q# operation
        // has type (idxBondLength : Int, nBitsPrecision : Int, trotterStepSize : Double) => (Double),
        // we pass the index along with that we want six bits of precision and
        // step size of 1.
        //
        // The result of calling H2EstimateEnergyRPE is a Double, so we can minimize over
        // that to deal with the possibility that we accidently entered into the excited
        // state instead of the ground state of interest.

        let estAtBondLength idx =
            [0..2]
            |> Seq.map (fun idxRep ->
                    H2EstimateEnergyRPE.Body.Invoke (struct (idx, int64 6, float 1))
                )
            |> Seq.min

        // So that the above computation can proceed without blocking the GUI thread,
        // we use FSharp.Control.AsyncSeq to create a workflow in which energies
        // are calculated for each energy in turn as an asynchronous sequence.
        let estimateEnergies =
            asyncSeq {
                for idxBond in [0..53] do
                yield bondLengths.[idxBond], (int64 >> estAtBondLength) idxBond
            }

        // We're now equipped to define the GUI itself.

        // First we create a blank window, and attach our plotting routines
        // to its Loaded event. If we try to define the plot before then,
        // we may inadvertantly finish a computation before the plot is
        // ready, causing the GUI to crash.
        let window = Window()
        window.Loaded.Add <| fun eventArgs ->

            // We make the chart by piping the asynchronous sequence which
            // estimates the energy at each bond length through the FSharp.Charting
            // package's LiveChart object.
            //
            // The LiveChart object will in turn observe when each computation completes,
            // and will update the chart accordingly.
            let estEnergyChart =
                estimateEnergies
                |> AsyncSeq.toObservable
                |> fun data ->
                    LiveChart
                        .LineIncremental(data, Name="Estimated")
                        .WithMarkers(Size=12, Style=MarkerStyle.Circle)

            // For comparison, we also include the exact values obtained
            // by diagonalizing the H₂ Hamiltonian at each bond length.
            // Please see README.md for a description of how these
            // values were calculated.
            let theoryChart =
                [
                    0.14421; -0.323939; -0.612975; -0.80051; -0.92526;
                    -1.00901; -1.06539; -1.10233; -1.12559; -1.13894;
                    -1.14496; -1.1456; -1.14268; -1.13663; -1.12856;
                    -1.1193; -1.10892; -1.09802; -1.08684; -1.07537;
                    -1.06424; -1.05344; -1.043; -1.03293; -1.02358;
                    -1.01482; -1.00665; -0.999025; -0.992226; -0.985805;
                    -0.980147; -0.975156; -0.970807; -0.966831; -0.963298;
                    -0.960356; -0.957615; -0.95529; -0.953451; -0.951604;
                    -0.950183; -0.949016; -0.947872; -0.946982; -0.946219;
                    -0.945464; -0.944887; -0.944566; -0.94415; -0.943861;
                    -0.943664; -0.943238; -0.943172; -0.942973
                ]
                |> Seq.zip bondLengths
                |> fun data ->
                    Chart
                        .Line(data, Name="Theory")


            // Having defined both charts individually, we can now combine them into
            // a GUI control suitable for adding to our new window.
            let chart =
                new ChartControl
                    (
                        Chart.Combine([estEnergyChart; theoryChart])
                        |> fun chart ->
                            chart
                                .WithXAxis(Title = "BOND LENGTH", TitleFontName="Segoe UI Semibold", TitleFontSize = 24.0)
                                .WithYAxis(Title = "ENERGY", TitleFontName="Segoe UI Semibold", TitleFontSize = 24.0)
                                .WithLegend(FontSize = 24.0, FontName = "Segoe UI")
                                .WithTitle("H₂", FontName="Segoe UI", FontSize = 24.0) 
                    )

            // Since FSharp.Charting uses Windows.Forms instead of the Windows Presentation
            // Framework (WPF), we need to wrap the control in a host that maps between
            // the two GUI frameworks.
            let integrationHost = new Forms.Integration.WindowsFormsHost(Child = chart)

            window.Content <- integrationHost

        // With everything all set up, we can now invoke the new window as our application,
        // which will start the chart plotting. Have fun!
        Application().Run(window)
            |> ignore
        0
