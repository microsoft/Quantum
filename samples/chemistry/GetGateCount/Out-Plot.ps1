# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        This script plots the results from running gate count analysis on one
        or more sets of integrals.

    .PARAMETER GateCountData
        Results obtained from Get-GateCount.

    .PARAMETER MetricName
        The name of the field to extract from each of the results passed to
        this script.
#>
param(
    [Parameter(ValueFromPipeline=$true)]
    $GateCountData,

    [string[]]
    $MetricName = @("CNOTCount", "TotalTCount"),

    [string]
    $WindowTitle = "Get-GateCount"
)

begin {
    $AllData = [System.Collections.ArrayList]::new();

$Script = @"
import os
import matplotlib.pyplot as plt
plt.style.use('ggplot')
plt.rcParams.update({'font.size': 28})
fig_size = plt.rcParams["figure.figsize"]
fig_size[0] = 16
fig_size[1] = 12
plt.rcParams["figure.figsize"] = fig_size
plt.rcParams.update({'figure.autolayout': True})


for results in data:
    results['Name'] = os.path.splitext(os.path.basename(results['IntegralDataPath']))[0]

import pandas as pd
import numpy as np

df = pd.DataFrame(data)

# This formula is approximates the number of T-gates required to synthesize each arbitrary rotation gate.
df['TotalTCount'] = df['TCount'] - 4 * np.log2( 0.001 / df['RotationsCount']) * df['RotationsCount']

for metric_name in metric_names:

    (
        df
            .pivot(index='Name', columns='Method', values=metric_name)
            .plot
            .barh()
    )
    plt.title(metric_name)
    plt.gca().set_xscale('log')
    fig = plt.gcf()
    fig.tight_layout()
    fig.canvas.set_window_title(window_title) 

plt.show()
"@;
}

process {
    $AllData.Add($GateCountData) | Out-Null;
}

end {
    Invoke-Python `
        -Source $Script `
        -Variables @{
            "data" = $AllData;
            "metric_names" = $MetricName;
            "window_title" = $WindowTitle;
        }
}
