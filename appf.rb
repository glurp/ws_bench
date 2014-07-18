require 'femtows'

$stderr.puts "running appf..."

$ws=WebserverRoot.new(9293,"/tmp","femto ws",10,300, {})
p (ENV['SIZER'].to_i)
$data="*"*(ENV['SIZER'].to_i)

$ws.serve("/hello")    {|p|  
 [200,".html", $data ] 
}
sleep
