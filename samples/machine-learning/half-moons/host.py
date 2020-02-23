# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import json

import qsharp
qsharp.packages.add("Microsoft.Quantum.MachineLearning::0.10.2002.2202-beta")
qsharp.reload()

from Microsoft.Quantum.Samples import TrainHalfMoonModel, ValidateHalfMoonModel

if __name__ == "__main__":
    with open('data.json') as f:
        data = json.load(f)
    parameter_starting_points = [
        [0.060057, 3.00522,  2.03083,  0.63527,  1.03771, 1.27881, 4.10186,  5.34396],
        [0.586514, 3.371623, 0.860791, 2.92517,  1.14616, 2.99776, 2.26505,  5.62137],
        [1.69704,  1.13912,  2.3595,   4.037552, 1.63698, 1.27549, 0.328671, 0.302282],
        [5.21662,  6.04363,  0.224184, 1.53913,  1.64524, 4.79508, 1.49742,  1.545]
     ]

    (parameters, bias) = TrainHalfMoonModel.simulate(
        trainingVectors=data['TrainingData']['Features'],
        trainingLabels=data['TrainingData']['Labels'],
        initialParameters=parameter_starting_points
    )

    miss_rate = ValidateHalfMoonModel.simulate(
        validationVectors=data['ValidationData']['Features'],
        validationLabels=data['ValidationData']['Labels'],
        parameters=parameters, bias=bias
    )

    print(f"Miss rate: {miss_rate:0.2%}")
