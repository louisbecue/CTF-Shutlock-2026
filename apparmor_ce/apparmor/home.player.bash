profile player_shell /bin/bash {
  #include <abstractions/base>
  #include <abstractions/bash>
  #include <abstractions/nameservice>

  /lib/**                        rm,
  /lib64/**                      rm,
  /usr/lib/**                    rm,
  /usr/lib64/**                  rm,
  /usr/lib/x86_64-linux-gnu/**   rm,

  /bin/**                        rix,
  /usr/bin/**                    rix,
  /usr/bin/gcc*                  rix,
  /usr/bin/cc*                   rix,
  /usr/bin/ld                    rix,
  /usr/bin/as                    rix,
  /usr/local/bin/**              rix,
  /sbin/**                       rix,
  /usr/sbin/**                   r,

  /home/player/                  rw,
  /home/player/**                rw,

  /tmp/**                        rw,

  /var/scan/                     rw,
  /var/scan/**                   rwixm,

  /proc/**                       r,
  /sys/**                        r,

  /etc/**                        r,
  deny /etc/apparmor.d/**        w,
  deny /sys/kernel/security/apparmor/** w,
  /secure_data/                  r,
  deny /secure_data/agents.txt   r,

  /dev/pts/**                    rw,
  /dev/tty                       rw,
  /dev/null                      rw,

  signal (receive) set=(term,kill,hup,int,quit),
  signal (send)    set=(term,kill,hup,int,quit),
}
