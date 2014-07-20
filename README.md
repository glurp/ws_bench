Simple Benchmark for some ruby web serveur
==========================================
Measure node.js,thin,cuba,(femtows).

install :
----------
<< ruby and node.js>>
 >gem install rack thin cuba femtows
 
 >npm install -g express
 

Tuning linux
--------------
less WAIT_TIMEOUT...

 >sudo bash -c  "echo 30 >  /proc/sys/net/ipv4/tcp_fin_timeout "
 
more tcp ports...
 >sudo bash -c  "echo 15000 65000 >  /proc/sys/net/ipv4/ip_local_port_range" 

Recycle tcp ports (experimental):
 >echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
 
 >echo 1 >/proc/sys/net/ipv4/tcp_tw_reuse


Contents
======

express.js : little server un nore.js/express

app.rb  : cuba framework   ; >rackup -p 9293
  config.ru with app.rb
  
tthin.ru : thin standalone;>thin start -R tthin.ru -p 9293

appf.rb : femtows          ; >ruby appf.rb
a ws fullstack in 300 LOC, multithread,thread-pool

run.rb
*  script for execute all tests
*  ok for linux
*  windows: rack-based server must be killed manualy (Process.kill("KILL") does not work...)

wget.rb
*  my own http client tester, not very good, but work...

  
  
Measures
========
server Linux/xeon, 16 cores, 32GB (ovh)
---
* uname:  Linux 3.2.13-xxxx-std-ipv6-64 #1 SMP Wed Mar 28 11:20:17 UTC 2012
```
********** Measures for 10000 request in 100 concurents clients ########
*** ruby 1.9.3p0 (2011-10-30 revision 33570) [x86_64-linux]
{"node.js 50B/r"=>"Requests per second:     8880.98 [#/sec] (mean)",
 "express 50B/r"=>"Requests per second:     9752.86 [#/sec] (mean)",
 "thin    50B/r"=>"Requests per second:    12699.54 [#/sec] (mean)",
 "cuba    50B/r"=>"echec",

 "femtows 50B/r"=>"Requests per second:      3710.73 [#/sec] (mean)",
 "node.js 5000B/r"=>"Requests per second:    8309.31 [#/sec] (mean)",
 "express 5000B/r"=>"Requests per second:    8515.91 [#/sec] (mean)",
 "thin    5000B/r"=>"Requests per second:   11968.44 [#/sec] (mean)",
 "cuba    5000B/r"=>"Requests per second:    2150.61 [#/sec] (mean)",
 "femtows 5000B/r"=>"Requests per second:    3563.59 [#/sec] (mean)"}

```
nota cuba is penalized by hs log (redirect on/dev/null...) 

Ubuntu on laptop
---

``` 
Linux  3.2.0-67-generic #101-Ubuntu SMP i686 i686 i386 GNU/Linux
{"node.js 50B/r"=>"Requests per second:    5267.88 [#/sec] (mean)",
 "express 50B/r"=>"Requests per second:    5202.25 [#/sec] (mean)",
 "thin    50B/r"=>"Requests per second:    4864.63 [#/sec] (mean)",
 "cuba    50B/r"=>"Requests per second:    1094.73 [#/sec] (mean)",
 "femtows 50B/r"=>nil,

 "node.js 5000B/r"=>"Requests per second:    4053.96 [#/sec] (mean)",
 "express 5000B/r"=>"Requests per second:    4074.06 [#/sec] (mean)",
 "thin    5000B/r"=>"Requests per second:    4766.44 [#/sec] (mean)",
 "cuba    5000B/r"=>"Requests per  second:    976.08 [#/sec] (mean)",
 "femtows 5000B/r"=>"Requests per second:    3663.92 [#/sec] (mean)"
}
```

nota cuba is penalized by hs log (redirect on/dev/null...) 

Ubuntu in virtualbox in Core i7 /host windows
---
tests with wget.rb, no good....

```
********** Measures for 10000 request in 50 concurents clients ########
*** ruby 1.9.3p484 (2013-11-22 revision 43786) [i686-linux]
{"node.js 50B/r"=>"Request/seconds : 1277.7747347103582",
 "thin    50B/r"=>"Request/seconds : 1350.210535810596",
 "cuba    50B/r"=>"Request/seconds : 965.419317464408",
 "femtows 50B/r"=>"Request/seconds : 1358.9813782824401",
 
 "node.js 5000B/r"=>"Request/seconds : 1221.8282527625038",
 "thin    5000B/r"=>"Request/seconds : 1309.8024015550607",
 "cuba    5000B/r"=>"Request/seconds : 895.9974652415458",
 "femtows 5000B/r"=>"Request/seconds : 1285.8017645231191"}
```
Same machine, on windows, native

tests with wget.rb, no good....

```
********** Measures for 10000 request in 50 concurents clients ########
*** ruby 2.0.0p0 (2013-02-24) [i386-mingw32]
{"node.js 50B/r"=>"Request/seconds : 678.8695275290775",
 "thin    50B/r"=>"Request/seconds : 653.917794521648",
 "cuba    50B/r"=>"Request/seconds : 590.5401286369",
 "femtows 50B/r"=>"Request/seconds : 728.2131011702199",
 
 "node.js 5000B/r"=>"Request/seconds : 684.282091405402",
 "thin    5000B/r"=>"Request/seconds : 659.4380784178558",
 "cuba    5000B/r"=>"Request/seconds : 612.7799420834898",
 "femtows 5000B/r"=>"Request/seconds : 701.1486436381608"}
``` 

License
=======
GPL
