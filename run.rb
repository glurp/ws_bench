##
## run ach tests :
##    run server
##    run client  (ruby wget...)
##    kill server
##    wait ports in TIME_WAIT closed
##
require 'thread'
require 'timeout'
require 'pp'


$res={}
def register(name,out)
  if out
	  perf=out.split(/\r?\n/).grep(/Request\/seconds/)[0]
	  puts "#{name} : #{perf}"
  else
	  perf="echec"
  end
  $res[name]=perf
end
def nbtw() `netstat -an`.split(/\r?\n/).grep(/WAIT/).size end
def nbtl() `netstat -an`.split(/\r?\n/).grep(/:9293.*LISTEN/).size end
def wait_free_netport(n)
  nn=0
  (puts "wait TIME_WAIT #{nn}<#{n}...";sleep 4) while (nn=nbtw())>n
  puts "Nb TIME_WAIT: #{nbtw}"
end

def run_test(name,size,timeout,srv_cmd,client_cmd)
  puts "\n\ ============== Running #{name} : #{srv_cmd} =======\n\n"
  out=nil
  ps=Process.spawn({'SIZER'=>size.to_s},srv_cmd) 
  puts "sleep after server run.."
  sleep 6
  puts `netstat -an | grep :9293 | grep LISTEN`
  puts "run client..."
  thc=Thread.new { out=`#{client_cmd}`}
  timeout(timeout) {  thc.join ; register(name,out) } rescue (p $!;register(name,nil))
  (Process.kill("KILL", ps) rescue nil) if ps
  Process.wait(ps) if ps
  wait_free_netport($maxtw)
  nn=0
  (puts "wait LISTEN free #{nn}...";sleep 4) while (nn=nbtl())>0
  3.times { puts }
end

$maxtw=[10000,nbtw()*2].max
wait_free_netport(50)

nbt=(ARGV[0]||"8").to_i
nbr=(ARGV[1]||"100").to_i
cmd_client="ruby wget.rb prepeat 2 #{nbt} #{nbr} get http://127.0.0.1:9293/hello"
run_test "node.js 50B/r",50,30,"node app.js"                   ,cmd_client
run_test "thin    50B/r",50,30,"thin start -R tthin.ru -p 9293",cmd_client
run_test "cuba    50B/r",50,30,"rackup -p 9293"                ,cmd_client
run_test "femtows 50B/r",50,30,"ruby appf.rb"                  ,cmd_client

run_test "node.js 5000B/r",5000,120,"node app.js"                   ,cmd_client
run_test "thin    5000B/r",5000,120,"thin start -R tthin.ru -p 9293",cmd_client
run_test "cuba    5000B/r",5000,120,"rackup -p 9293"                ,cmd_client
run_test "femtows 5000B/r",5000,120,"ruby appf.rb"                  ,cmd_client
puts
puts
puts
puts "********** Measures for #{2*nbt*100} request in #{nbt} concurents clients ########"
puts "*** #{RUBY_DESCRIPTION}"
pp $res
