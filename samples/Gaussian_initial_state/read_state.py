import matplotlib.pyplot as plt

# read the probability amplitudes of result state into list
list = []
with open('wavefcn_recursive.txt', 'r', encoding="utf8") as file:
    for line in file:
        ampl = line[59:67]
        if ampl[0] == '0':
            print(ampl)
            list.append(float(ampl))
file.close()
print(list)

# plot list
plt.plot(list)
# save the plot to file
# plt.savefig('wavefunction.png')
plt.savefig('wavefunction_recursive.png')
plt.show()