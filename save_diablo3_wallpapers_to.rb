require 'net/http'

# save wallpapers from http://eu.battle.net/d3/en/media/wallpapers/
folder_target = ARGV[0]
if folder_target.nil?
  puts 'provide an location as argument'
  exit
end

Dir.chdir(folder_target)

uri = URI('http://eu.battle.net/d3/en/media/wallpapers/')
resp = Net::HTTP.get_response(uri)
unless resp.is_a? Net::HTTPSuccess
  puts "error in response: #{resp}"
  exit
end

folder_diablo = 'Diablo III wallpapers'
Dir.mkdir(folder_diablo) unless Dir.exist? folder_diablo
Dir.chdir(folder_diablo)

regex = /var indices = \[((?:"wallpaper\d+",? ?)+)\];/
images = resp.body.match(regex)[1].split(', ').map { |img| img.gsub(/"/, '') }

images.each do |img|

  params = { view: img }
  uri.query = URI.encode_www_form(params)
  resp = Net::HTTP.get_response(uri)
  next unless resp.is_a? Net::HTTPSuccess

  folder_xxx = img.match(/\d+/)[0]
  Dir.mkdir(folder_xxx) unless Dir.exist? folder_xxx
  Dir.chdir(folder_xxx)

  regex = /class="format".*?href="([^-]+-(\d+x\d+-?\w*)\.(\w+))"/

  resp.body.scan(regex) do |link, format, extension|
    img_resp = Net::HTTP.get_response(URI(link))
    next unless resp.is_a? Net::HTTPSuccess
    open("#{format}.#{extension}", 'wb') { |file| file.write(img_resp.body) }
  end

  Dir.chdir('..')

end

