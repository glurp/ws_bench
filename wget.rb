
####################################################################################
#  wget.rb : execute une commande http
####################################################################################
#  Usage
#   >ruby wget.rb <method>  <url> ....
#   >ruby wget.rb get <url> name1 value1 name2 ...
#             HTTP GET  avec parametres
#   >ruby wget.rb post <url> name1 value1 name2 ...
#             HTTP POST avec parametres
#   >ruby wget.rb  repeat nn <get/post> <url> name1 value1 nameé ...
#   >ruby wget.rb prepeat <nbrepeat> <nbthread> nn <url> name1 value1 nameé ...
#       execute repeat <nbrepeat> fois avec pour chaque fois, nbThread en paralle executant
#            le repeat nn de <url>:
#                <nbrepeat>.time do
#                  <nbthread>.times { ths <<Thread.new { repeat(nn ....) } }
#                  ths.each.join()
#                end
#
####################################################################################

require 'open-uri'
require 'timeout'
require 'net/http'
require 'cgi'
require 'enumerator'
require 'tracer'

module Kernel
  def chrono(txt,n=1)
    date_start=Time.now.to_f
    yield
    date_end=Time.now.to_f
    duree= (date_end - date_start)*1000
    rduree=duree
    duree /=  n if n>0
    sduree= case duree
    when 0..3000 then duree.to_s + " ms"
    when 3000..10000 then (duree/1000).to_s + " sec"
    when 10000..180000 then (duree/1000).to_i.to_s + " sec"
    else
      (duree/60000).to_s +" mn"
    end
    puts "\n=========  #{txt} Duree #{n>1 ? 'par iteration':''} = #{sduree}"
    rduree
  end
end


def wget(url,*args)
  trace=false
  url = "#{url}/"  unless url =~ /\// 
  url = "http://#{url}"  unless url =~ /^http:.*/ 

  if !args || args.size==0
     args=url.split(/[\?&=]/)[1..-1]
	 url=url.split(/\?/)[0]
  end
  h={}
  args.each_slice(2) {|k,v| h[k]= v.gsub('+',"%2B").gsub(' ',"+")||"" } 
  if h["_auth"]
    user,pass=h["_auth"].split('/')
	puts "BasicAuth : #{user}/****"
	h.delete("_auth")
  end
  args=""
  args=  "?" + h.map { |k,v| "#{k}=#{v}" }.join("&") if h.size>0 

  uri = URI.parse(url + args) 
  puts "GET " +url + " " + h.inspect if trace
  
  #def uri.empty?() ; false ; end
  q=( uri.query && uri.query.length>0 ) ?  ("?" + uri.query ) : ""
  suri=uri.path+q 
  suri="/"  if suri.size==0
  req = Net::HTTP::Get.new(suri,{"User-Agent"=>"ruby", "Host"=>"10.177.235.50","Accept"=>"*/*"})
  req.basic_auth(user,pass) if defined?(user)

  http=Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = http.read_timeout = 200

  res = http.start { |http1| 
    http1.request(req) 
  }
  case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      print "HTTPSuccess :  #{res.read_body || "<vide>"}. #{res.value}" if trace
      $nbRequette+=1
      return( res.read_body )
    else
      print res.inspect if trace
      $nbEchec+=1
      ""
  end
end


def wpost(url,*args)
  h={}
  args.each_slice(2) {|k,v| h[k]=v} 
  url = "#{url}/"  unless url =~ /\// 
  url = "http://#{url}"  unless url =~ /^http:.*/ 
  puts "POST " +url + " " + h.inspect

  uri = URI.parse(url) 
  def uri.empty?() ; false ; end
  suri= uri.path.size>0 ? uri.path : "/"
  req = Net::HTTP::Post.new(suri,{"User-Agent"=>"ruby", "Host"=>"localhost", "Accept"=>"*/*"})
  req.basic_auth('admin', 'admin')
  req.set_form_data(h,"\r\n")

  http=Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = http.read_timeout = 10

  res = http.start { |http1| 
    puts "set request..."
    http1.request(req) 
  }
  case res
    when Net::HTTPSuccess, Net::HTTPRedirection
	  print "HTTPSuccess : #{res.body || "<vide>"}"
    else
      print res
  end
end

# wget repeat 10 get http://localhost:7070/appliserveur/http/config/rtdb:RtdbVideo:get_cameras.rb 

def repeat(nb,method,*params)
 inb=nb.to_i
 chrono("stat",inb) { 
  inb.times {
   case method.downcase
    when "get"
      wget(*params) 
    when "post"
      puts wpost(*params) 
    else
      puts "Method #{method} pas supportee! . Usage : wget GET/POST http://dddd/ddddd k1 v1 k2 v2 ..."
   end
  }
 }
end

# wget prepeat 10 20 5 get http://localhost:7070/appliserveur/http/config/rtdb:RtdbVideo:get_cameras.rb 
# 10 packets de 20 threads, chacun effectuant 5 wget en sequence

def prepeat(nbp,pack,*params)
 ipack=pack.to_i
 n=nbp.to_i*ipack*(params[0].to_i) 
 dur=chrono("avec #{n} requettes",n) { nbp.to_i.times { (1..ipack).map { Thread.new() {  repeat(*params)   } } .each { |th| th.join }  }}
 puts "Request/seconds : #{1000*n/dur}"
end

####################################################################################
#  - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - - 
####################################################################################
$nbRequette=0
$nbEchec=0
if __FILE__ == $0
	Thread.abort_on_exception = true 
	if ARGV.length<2
	 puts "Usage:"
	 puts "  wget get    url [_auth user/pass] arg1 value1 ...."
	 puts "  wget post   url arg1 value1 ...."
	 puts "  wget repeat                        <nbrepeat> get url arg1 value1..."
	 puts "  wget prepeat <nbboucle> <nbthread> <nbrepeat> get url arg1 value1..."
	 exit!
	end
	trap("INT") { exit!() } 
	method=ARGV.shift
	chrono("total") {
	 case method.downcase
	  when "repeat"
	   repeat(*ARGV)
	   puts "====== nb wget : #{$nbRequette} / #{$nbEchec}"
	  when "prepeat"
	   prepeat(*ARGV)
	   puts "====== nb wget : #{$nbRequette} / #{$nbEchec}"
	  when "get"
	   puts wget(*ARGV) 
	  when "post"
	  puts wpost(*ARGV) 
	  else
	   puts "Method #{method} pas supportee! . Usage : wget GET/POST http://dddd/ddddd k1 v1 k2 v2 ..."
	 end
	}
	sleep 1
end

