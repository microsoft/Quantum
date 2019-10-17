import qsharp
from Microsoft.Quantum.Samples.BitFlipCode import (
	CheckBitFlipCodeCorrectsBitFlipErrors,
	CheckBitFlipCodeStateParity,
	CheckCanonBitFlipCodeCorrectsBitFlipErrors
)

CheckBitFlipCodeStateParity.simulate()
print("Parity check passed successfully!")

CheckBitFlipCodeCorrectsBitFlipErrors.simulate()
print("Corrected all three bit-flip errors successfully!")

CheckCanonBitFlipCodeCorrectsBitFlipErrors.simulate()
print("Corrected all three bit-flip errors successfully!")
