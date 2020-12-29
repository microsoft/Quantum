import matplotlib.pyplot as plt

list = []
with open('wavefcn_recursive.txt', 'r', encoding="utf8") as file:
    for line in file:
        ampl = line[59:67]
        if ampl[0] == '0':
            print(ampl)
            list.append(float(ampl))
file.close()
print(list)

plt.plot(list)
#plt.savefig('wavefunction.png')
plt.savefig('wavefunction_recursive.png')
plt.show()