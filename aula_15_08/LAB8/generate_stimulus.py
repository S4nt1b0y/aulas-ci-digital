import random
REFERENCE = [12000, -8000, 16000, 4000, -14000, 10000, -6000, 14000] # h[0] = mais recente
N = len(REFERENCE)
NSAMPLES = 128
INSERT_AT = [24, 64, 96]
NOISE = 1800
rng = random.Random(7)

def sat16(x):
    return max(-32768, min(32767, x))

# Ruído de fundo
samples = [rng.randint(-NOISE, NOISE) for _ in range(NSAMPLES)]

# Sequência temporal que maximiza sum x[n-k]*h[k]
pattern_time = list(reversed(REFERENCE))
for pos in INSERT_AT:
    for k, v in enumerate(pattern_time):
        samples[pos+k] = sat16(v + rng.randint(-250, 250))

# ROM: 16 bits, complemento de dois, formato para $readmemh
with open("reference.mem", "w") as f:
    for v in REFERENCE:
        f.write(f"{v & 0xffff:04x}\n")

# Amostras: inteiro signed, uma por linha
with open("samples.txt", "w") as f:
    for v in samples:
        f.write(f"{v}\n")

print("N =", N)
print("Ocorrências começam em:", INSERT_AT)
print("Picos esperados ao fim das janelas:", [p + N - 1 for p in INSERT_AT])