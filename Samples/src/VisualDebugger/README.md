# Q# Visual Debugger #

This sample lets you interactively step through the execution of a Q# program.
It shows the tree of operation calls and a visualization of the quantum state
after each operation. You can also go back to previous states by clicking the
"Previous" button or by clicking on a previous operation in the list.

Note that since this sample relies on the quantum simulator for information
about the program execution, it can only step through quantum operations, not
classical functions.

## Running the Sample ##

First install the Node.js package dependencies and build the TypeScript
component:

```
npm install
npm run release
```

Then start the visual debugger:

```
dotnet run
```

This will launch a web server running the visual debugger. Open
http://localhost:5000 in a web browser to use it.

## Editing the Q# Program ##

To change the Q# program that is executed by the debugger, edit the `Program.qs`
file. The debugger will start the program by running the `QsMain` operation.
