require 'cgi'
require "rdiscount"
require "tilt"

layout = 'view/layout.erb'

File.open 'index.html', 'w' do |fh|
  fh << Tilt::ERBTemplate.new(layout).render do
    Tilt::ERBTemplate.new('view/index.erb').render
  end
end

(Dir['../espresso/**/*.md'] + Dir['./pages/*.md']).each do |file|

  md = File.read(file).
    gsub(/```(\w+)/, "<pre>").
    gsub(/```/, "</pre>").
    gsub(/https\:\/\/github\.com\/espresso\/espresso#tutorial/, '#')

  engine = Tilt::RDiscountTemplate.new { md }

  html = Tilt::ERBTemplate.new(layout).render do
    engine.render.
      gsub(/\<h(\d)\>([^<]*)\<\/h\d\>/i) do
        d, w = $1, $2
        id = w.downcase.gsub(/\W/, '-')
        "<h#{d} id='#{id}'><a href='##{id}'>#{w}</a></h#{d}>"
      end
  end

  File.open(File.basename(file, File.extname(file)) << '.html', 'w') do |fh|
    fh << html
  end
end
