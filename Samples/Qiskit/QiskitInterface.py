# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
from IBMQuantumExperience import IBMQuantumExperience
import json
import time
import sys
print("Usage: python3 QiskitInterface.py <Key> <Backend> <Shots>")
apikey = sys.argv[1]
backend = sys.argv[2]
shots = sys.argv[3]

api = IBMQuantumExperience(apikey)
print("Qiskit API Interface")
with open('input.txt', 'r') as myfile:
  qasm = myfile.read()
print("QASM FILE READ")
print(qasm)
print("SENDING TO IBM Quantum Experience")
print(" IBMQ AT IBM Quantum Experience:")
qasms = [{ 'qasm': qasm}]
job = api.run_job(qasms, backend=backend, shots=shots, max_credits=3)
print(job)

if 'id' in job:
    jobid = job['id']
    print(" JobID:", jobid);
    status = job['status']
    position = job['infoQueue']['position']
    if 'estimatedTimeInQueue' in job['infoQueue']:
        timeQueue = job['infoQueue']['estimatedTimeInQueue']
    else:
        timeQueue = position * 60 #Guestimate on minute per job
    print(" Expected time (minutes) in Queue left:", timeQueue/60)
    if timeQueue < 120 * 100: #In demo's 120 seconds is the max we can wait.
       while status == 'RUNNING':
          time.sleep(30)
          job = api.get_job(jobid)
          status = job['status']
          if 'infoQueue' in job and 'position' in job['infoQueue']:
             position = job['infoQueue']['position']
             print(" Position in Queue", position)
             if 'estimatedTimeInQueue' in job['infoQueue']:
                timeQueue = job['infoQueue']['estimatedTimeInQueue']
             else:
                timeQueue = position * 60 #Guestimate on minute per job
             print(" Expected time (minutes) in Queue left:", timeQueue/60)
       id = job['qasms'][0]['executionId']
       result = api.get_result_from_execution(id)
       print(result)
       with open('output.txt', 'w') as resultFile:
          resultFile.write(str(result['result']))
    else:
       print(" Result will be later than timeout. Going to failover.")
       print(" SIMULATOR AT IBM:")
       ex = api.run_experiment(qasm, backend='ibmqx_qasm_simulator', shots=shots, name='QSharpRun SIM', timeout=15)
       print("DONE")
       print(ex)
       with open('output.txt', 'w') as resultFile:
          resultFile.write(str(ex['measure']))
else:
   print(" SIMULATOR AT IBM:")
   ex = api.run_experiment(qasm, backend='ibmqx_qasm_simulator', shots=shots, name='QSharpRun SIM', timeout=15)
   print("DONE")
   print(ex)
   with open('output.txt', 'w') as resultFile:
      resultFile.write(str(ex['result']))