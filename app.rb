require "cuba"

$data="*"*(ENV['SIZER'].to_i)
Cuba.define do
  on get do
    on "hello" do
      res.write $data
    end

    on root do
      res.redirect "/hello"
    end
  end
end
