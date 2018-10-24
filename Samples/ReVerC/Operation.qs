namespace Quantum.ReVerC
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

  /// Prepares a quantum register in the given basis state
  operation prepare(initial: Result[], register: Qubit[]) : ()
  {
    body
    {
      for (i in 0..Length(initial)-1)
      {
        if (M(register[i]) != initial[i]) { X(register[i]); }
      }
    }
  }

  /// Performs the quantum addition of two basis states
  operation add(ainit: Result[], binit: Result[]) : Int
  {
    body
    {
      mutable res = new Result[2];
      using (qubits = Qubit[6])
      {
        let a = qubits[0..1];
        let b = qubits[2..3];
        let c = qubits[4..5];
        prepare(ainit, a);
        prepare(binit, b);

        adder(a, b, c);

        set res[0] = M(c[0]);
        set res[1] = M(c[1]);

        ResetAll(qubits);

      }

      return ResultAsInt(res);
    }
  }
}
