// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

"use strict";
exports.id = 'renderer';

const ipc = require('node-ipc')

exports.connectToSimulationServer = function(callback) {
    ipc.config.id = "h2SimulationClient";
    ipc.config.networkPort = 8010;

    ipc.connectToNet(
        "h2SimulationServer",
        () => {
            ipc.of.h2SimulationServer.on(
                'connect',
                () => {
                    ipc.log('## Connected to simulation server. ##', ipc.config.delay);
                    ipc.of.h2SimulationServer.emit(
                        'event',
                        'readyToPlot'
                    )
                }
            );

            ipc.of.h2SimulationServer.on(
                'disconnect',
                () => {
                    ipc.log('## Disconnected from simulation server. ##')
                }
            )

            ipc.of.h2SimulationServer.on(
                'plotPoint',
                (data) => {
                    ipc.log('## Got data: ', data, ' ##')
                    callback(data);
                }
            )
        }
    )
}

