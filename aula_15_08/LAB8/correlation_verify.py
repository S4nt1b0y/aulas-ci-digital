import numpy as np
import matplotlib.pyplot as plt

# Entrada
samples = np.loadtxt("samples.txt")

# Saída do DUT
corr_data = np.loadtxt("correlation.txt")

corr_idx = corr_data[:,0]
corr_val = corr_data[:,1]

# Posições esperadas do pico
expected_peaks = [31, 71, 103]

plt.figure(figsize=(12,8))

# ------------------------------------------------------------------
# Entrada
# ------------------------------------------------------------------
plt.subplot(2,1,1)
plt.plot(samples)
plt.title("Amostras de Entrada")
plt.ylabel("Amplitude")
plt.grid(True)

for p in expected_peaks:
    plt.axvline(p, linestyle="--")

# ------------------------------------------------------------------
# Correlação
# ------------------------------------------------------------------
plt.subplot(2,1,2)
plt.plot(corr_idx, corr_val)
plt.title("Saída do Correlator")
plt.xlabel("Índice")
plt.ylabel("Correlação")
plt.grid(True)

for p in expected_peaks:
    plt.axvline(p, linestyle="--")

plt.tight_layout()
plt.show()