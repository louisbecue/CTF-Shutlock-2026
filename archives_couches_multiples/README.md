# Archives a couches multiples (1/3)

## Énoncé

Nous avons intercepté une archive MLA. Cette archive contient le code PIN du téléphone d'une cible. Il nous faut à tout prix ce code PIN pour accéder au téléphone de la cible. Malheureusement, l'archive est corrompue. Quelques octets sont manquants. S'il vous plaît, analysez l'archive et retrouvez le code PIN. Nous savons que le fichier dans l'archive ne contient que le code PIN et rien d'autre.

## Analyse

En lisant la premiere entrée, on obtient le hash SHA-256 du code pin :

```text
eb7539924cf4b8b67488575210db3526ec7c2daaf546705ac37e5039c71c36f3
```

Comme le fichier ne contient que 4 chiffres, il suffit de tester tous les codes de `0000` a `9999` et de comparer leur SHA-256 avec ce hash.

## Exploitation

```python
import hashlib

target = "eb7539924cf4b8b67488575210db3526ec7c2daaf546705ac37e5039c71c36f3"

for i in range(10000):
	candidate = f"{i:04d}".encode()
	if hashlib.sha256(candidate).hexdigest() == target:
		print(candidate.decode())
		break
```

Le code PIN trouvé est 4583.

## Ressources

- Documentation de l'ANSSI : [https://anssi-fr.github.io/MLA](https://anssi-fr.github.io/MLA/)
