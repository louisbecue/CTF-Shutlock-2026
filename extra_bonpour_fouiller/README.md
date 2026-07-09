# Extrabon pour fouiller

## Énoncé

Lors d'un contrôle de routine, un de nos administrateurs système a repéré un trafic inhabituel sur un de nos serveurs. Une capture mémoire a été réalisée pour vous permettre de mener l'enquête.

## Résolution 

La premiere etape a consiste a relever les processus presents dans la machine memoire :

```bash
python3 /home/louis/Git/volatility3/vol.py -f memory.lime linux.sockstat.Sockstat > socket.txt
python3 /home/louis/Git/volatility3/vol.py -f memory.lime linux.pstree.PsTree > ps.txt
python3 /home/louis/Git/volatility3/vol.py -f memory.lime linux.bash.Bash > bash.txt
```

Dans `bash.txt`, on voit le lancement suivant :

```text
843    bash    2026-04-14 10:13:13.000000 UTC    ./loader backdoor.bpf.o
```

Le processus interessant est donc `loader`, avec le PID `873`.

### Extraction de la memoire

Une fois le PID identifie, on dump la memoire du processus :

```bash
python3 /home/louis/Git/volatility3/vol.py -f memory.lime linux.proc.Maps --pid 873 --dump
```

Le dump de la heap permet ensuite d'extraire des chaines exploitables :

```bash
strings pid.873.vma.0x562d4f89b000-0x562d4f8bc000.dmp
```

Parmi les resultats, on trouve :

```c
volatile unsigned char enc[C2_LEN] = { 0x16, 0x13, 0x12, 0x06, 0x11, 0x5a,
evt->c2_decoded[i] = enc[i] ^ key[i % XOR_KEY_LEN];
```

Le code montre que la chaine de C2 est chiffree avec un XOR entre `enc` et une clé repetee.

### Recherche de la clé

Pour localiser le bloc en memoire, on a cherche la signature XOR :

```bash
grep -aboP '\x16\x13\x12\x06\x11\x5a' memory.lime
```

En regardant le premier offset, on voit la clé en clair juste avant les octets chiffres :

```bash
tail -c +3163723850 memory.lime | od -tx1 -N 128

0000000 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0000020 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 62
0000040 61 67 75 65 74 74 65 36 37 16 13 12 06 11 5a 07
0000060 0d 43 43 0e 0e 08 1e 4b 12 06 47 50 4c 00 5b 04
0000100 00 00 05 00 08 00 09 00 00 00 24 00 00 00 2a 00
0000120 00 00 38 00 00 00 6e 03 00 00 77 03 00 00 81 03
0000140 00 00 8b 03 00 00 30 04 00 00 41 04 00 00 03 04
0000160 30 01 51 00 01 05 04 00 08 01 51 04 08 a0 09 01
0000200
```

Le bloc contient :

```text
62 61 67 75 65 74 74 65 36 37
```

Soit la clé `baguette67`.

#### Synthese

| Element | Valeur                                               |
| ---     | ---                                                  |
| clé     | `baguette67`                                         |
| Bloc    | `16 13 12 06 11 5a 07 0d 43 43 0e 0e 08 1e 4b 12 06` |

### Dechiffrement

Avec la clé, le domaine de C2 se dechiffre simplement par XOR.

```python
enc = bytes([0x16, 0x13, 0x12, 0x06, 0x11, 0x5a, 0x07, 0x0d, 0x43,0x43, 0x0e, 0x0e, 0x08, 0x1e, 0x4b, 0x12, 0x06,])
cle = b"baguette67"

print(bytes(c ^ cle[i % len(cle)] for i, c in enumerate(enc)).decode())
```

```text
trust.shutlook.fr
```