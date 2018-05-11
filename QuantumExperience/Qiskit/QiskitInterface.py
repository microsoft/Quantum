# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

from IBMQuantumExperience import IBMQuantumExperience
import json
import time
import sys
print("Usage: python3 QiskitInterface.py <Key> <Backend>")
print(sys.argv)

api = IBMQuantumExperience(sys.argv[1])
print("Qiskit API Interface")
with open('data.txt', 'r') as myfile:
  qasm = myfile.read()
print("QASM FILE READ")
print(qasm)
print("SENDING TO IBM Quantum Experience")
print(" IBMQ AT IBM Quantum Experience:")
qasms = [{ 'qasm': qasm}]
job = api.run_job(qasms, backend=sys.argv[2], shots=1, max_credits=3)
if 'id' in job:
    jobid = job['id']
    print(" JobID:", jobid);
    status = job['status']
    timeQueue = job['infoQueue']['estimatedTimeInQueue']
    print(" Expected time (minutes) in Queue left:", timeQueue/60)
    if timeQueue < 60:
       while status == 'RUNNING':
          time.sleep(10)
          job = api.get_job(jobid)
          position = job['infoQueue']['position']
          print(" Position in Queue", position)
          timeQueue = job['infoQueue']['estimatedTimeInQueue']
          print(" Expected time (minutes) in Queue left:", timeQueue/60)
          status = job['status']
       id = job['qasms'][0]['executionId']
       result = api.get_result_from_execution(id)
       print(result)
    else:
       print(" SIMULATOR AT IBM:")
       ex = api.run_experiment(qasm, backend='ibmqx_qasm_simulator', shots=1, name='QSharpRun SIM', timeout=15)
       #ex = api.run_experiment(qasm, backend='ibmqx4', shots=1, name='QSharpRun', timeout=60)
       print("DONE")
       print(ex)
else:
   print(" SIMULATOR AT IBM:")
   ex = api.run_experiment(qasm, backend='ibmqx_qasm_simulator', shots=1, name='QSharpRun SIM', timeout=15)
   #ex = api.run_experiment(qasm, backend='ibmqx4', shots=1, name='QSharpRun', timeout=60)
   print("DONE")
   print(ex)