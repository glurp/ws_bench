# test thin brute ; >thin start tthin.ru -p 9292

$data="*"*(ENV['SIZER'].to_i)
app = proc do |env|
  [
    200,          # Status code
    {             # Response headers
      'Content-Type' => 'text/html',
      'Content-Length' => $data.length.to_s,
    },
    [$data]        # Response body
  ]
end


run app


