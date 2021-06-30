# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import json

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cmx
plt.style.use('ggplot')

import qsharp

from Microsoft.Quantum.Samples import (
    TrainHalfMoonModel, ValidateHalfMoonModel, ClassifyHalfMoonModel
)

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

    # Classify the validation so that we can plot it.
    actual_labels = data['ValidationData']['Labels']
    classified_labels = ClassifyHalfMoonModel.simulate(
        samples=data['ValidationData']['Features'],
        parameters=parameters, bias=bias,
        tolerance=0.005, nMeasurements=10_000
    )


    # To plot samples, it's helpful to have colors for each.
    # We'll plot four cases:
    # - actually 0, classified as 0
    # - actually 0, classified as 1
    # - actually 1, classified as 1
    # - actually 1, classified as 0
    cases = [
        (0, 0),
        (0, 1),
        (1, 1),
        (1, 0)
    ]
    # We can use these cases to define markers and colormaps for plotting.
    markers = [
        '.' if actual == classified else 'x'
        for (actual, classified) in cases
    ]
    colormap = cmx.ScalarMappable(colors.Normalize(vmin=0, vmax=len(cases) - 1))
    colors = [colormap.to_rgba(idx_case) for (idx_case, case) in enumerate(cases)]

    # It's also really helpful to have the samples as a NumPy array so that we
    # can find masks for each of the four cases.
    samples = np.array(data['ValidationData']['Features'])

    # Finally, we loop over the cases above and plot the samples that match
    # each.
    for (idx_case, ((actual, classified), marker, color)) in enumerate(zip(cases, markers, colors)):
        mask = np.logical_and(
            np.equal(actual_labels, actual),
            np.equal(classified_labels, classified)
        )
        if not np.any(mask):
            continue
        plt.scatter(
            samples[mask, 0],
            samples[mask, 1],
            c=[color],
            label=f"Was {actual}, classified {classified}",
            marker=marker
        )
    plt.legend()
    plt.show()
