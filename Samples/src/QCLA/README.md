# QCLA

This folder contains our implementation of the QCLA as well as programs to test and benchmark its performance. 
To run the QCLA tests run: <br />
``
dotnet test  
``
<br />
To run an adder benchmark using the resource estimator run:
<br />
``
dotnet run i 
``
<br />
Where i corresponds to the adder to run:
<br />
| i     | Adder             |  <br />
| ----- |:-----------------:|  <br />
| 0     | QCLA              |  <br />
| 1     | ModularAddProduct |   <br />
| 2     | RCA               |   <br />\