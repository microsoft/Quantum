# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import qsharp

from Microsoft.Quantum.Samples import TrainWineModel, ValidateWineModel

if __name__ == "__main__":
    (parameters, bias) = TrainWineModel.simulate()

    miss_rate = ValidateWineModel.simulate(
        parameters=parameters, bias=bias
    )

    print(f"Miss rate: {miss_rate:0.2%}")
