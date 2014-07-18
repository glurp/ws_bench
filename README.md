Bench divers web serveur
=======================
http://ip:9292/hello
renvoi un packet de 500..5000 octets

preinstall :
 >gem install femtowws
 >gem install thin
 >gem install rack
 >gem install cuba

Reglages linux

 sudo bash -c  "echo 30 >  /proc/sys/net/ipv4/tcp_fin_timeout "
 sudo bash -c  "echo 15000 65000 >  /proc/sys/net/ipv4/ip_local_port_range" 


Contenu:
======
appf.rb : femtows          ; >ruby appf.rb
app.rb  : cuba framework   ; >rackup
  config.ru avec app.rb
tthin.ru : thin standalone;>thin start -R tthin.ru -p 9292

Resultats
========
virutalbox dans 8i /windows, 5000 octets/reponse requette
  femtows : 1206 r/s
  cuba :     896 r/s
  thin :    1237 r/s

virutalbox dans 8i /windows, 50 octets/reponse requette
  femtows :  1253 r/s
  cuba :      957 r/s
  thin :     1266 r/s

serveur ovh, xeon, 16 cores, 32GB,
  uname:  Linux 3.2.13-xxxx-std-ipv6-64 #1 SMP Wed Mar 28 11:20:17 UTC 2012

  node.js 50 B/rq : 1606 rq/s 5 ms/rq (2*8*200 requettes)
  femtows 50 B/rq : 1749 rq/s 2,2ms/rq
  cuba    50 B/rq : 1202 rq/s (2*4*200 requettes)
  thin    50 B/rq : 1817 rq/s 2ms/rq (2*4*100 requettes)
  nota: too many port in TIME_WAIT...

  node.js 5000 B/rq : 1587 rq/s 5 ms/rq (2*8*200 requettes)
  femtows 5000 B/rq : 1803 rq/s 4.3ms/rq (2*8*200 requettes)
  cuba    5000 B/rq : 1578 rq/s 5ms/rq (2*8*200 requettes)
  thin    5000 B/rq : 1702 rq/s 4.6 ms/rq (2*8*200 requettes)
