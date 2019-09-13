# Q# State Visualizer #

This sample lets you interactively step through the execution of a Q# program.
It shows the tree of operation calls and a visualization of the quantum state
after each operation. You can also go back to previous states by clicking the
"Previous" button or by clicking on a previous operation in the list.

Note that since this sample relies on the quantum simulator for information
about the program execution, it can only step through quantum operations, not
classical functions.

## Running the Sample ##

Install [Node.js](https://nodejs.org/en/) and the
[.NET Core SDK](https://dotnet.microsoft.com/download) if you do not already
have them installed.

Then install the dependencies and build the TypeScript component:

```
npm install
npm run release
```

Finally, start the dotnet host application:

```
dotnet run
```

This will launch a web server running the state visualizer. Open
http://localhost:5000 in a web browser to use it.

## Editing the Q# Program ##

To change the Q# program that is executed by the state visualizer, edit the
`Program.qs` file. The visualizer will start the program by running the `QsMain`
operation.

Restart the visualizer by running the `dotnet run` command again to see the new
program.
