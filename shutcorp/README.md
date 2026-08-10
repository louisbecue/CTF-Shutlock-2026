# ShutCorp

## Énoncé

Vous êtes un jeune prestataire mandaté pour intervenir dans l'entreprise ShutCorp. Vous êtes en première ligne pour découvrir les causes de l'attaque subit récemment. Vous obtiendrez de nouvelles informations au fur et à mesure de votre enquête.

L'équipe du Security Operation Center vous a transmis la capture réseau correspondant à la période de l'attaque. Dans un premier temps, vous devez découvrir l'adresse IP de la machine compromise ainsi que celle de l'attaquant. Enfin, pour pouvoir approfondir l'enquête le protocole utilisé par l'attaquant sera nécessaire.

## Résolution 

Nous disposons d'un fichier netcap-ShutCorp.pcap de 73 MO

Grâce au [script.py](script.py) on sait qu'on a comme différentes IP :
```
1.1.1.1
10.0.2.1
10.0.2.21
10.0.4.1
10.0.4.101
10.0.4.102
10.0.4.103
10.0.4.104
10.0.4.200
10.0.4.201
10.0.4.21
10.0.4.219
10.0.4.23
10.0.4.30
151.101.130.132
151.101.2.132
45.90.162.253
```

D'abord en analysant les différentes IP présentes sur le réseau 10.0.4.0/24 qui semble être le réseau privé de l'entreprise.

Les machines 10.0.4.103, 10.0.4.104 ont très peu d'échanges et ne sont pas suspects.

La machine 10.0.4.200 est un serveur NFS.

On observe qu'il y a beaucoup d'échanges SSH depuis la machine 10.0.4.1 vers les machines 10.0.4.101 et 10.0.4.102.

Grâce aux paquets de connexion SSH, on obtient les OS des machines :

| IP | Système d'exploitation | OpenSSH |
|---|---|---|
| 10.0.4.1 | Ubuntu 5.1 | 10 |
| 10.0.4.101 | Debian 7 | 10 |
| 10.0.4.102 | Debian 7 | 10 |
| 10.0.4.30 | Debian 7 | 10 |

On se rend compte que les échanges entre ces machines ne semblent pas suspects à premiére vu.

On tombe ensuite sur la machine 10.0.4.219.

On isole les échanges avec 10.0.4.101 :

```
ip.addr == 10.0.4.219 && ip.addr == 10.0.4.101
```

| IP | Système d'exploitation | OpenSSH |
|--- |---|---|
| 10.0.4.219 | Ubuntu 13.5 | 9 |

On remarque plusieurs tentatives avant d'avoir enfin la connexion SSH qui s'établit.  
Cela ressemble à de la force brute. Le fait que cette machine ait un OS et une version d'OpenSSH différents des autres machines, combiné aux échanges de force brute observés, laisse supposer qu'il s'agit de l'attaquant.

De plus, une fois la connexion établie, on observe une exploration du réseau suite à la compromission de la machine 10.0.4.101 :

10.0.4.101 -> 10.0.4.23:389 (ldap)

### Flags

| Élément | Valeur |
|---|---|
| Attaquant | 10.0.4.219 |
| Machine compromise | 10.0.4.101 |
| Protocole utilisé | SSHv2 |