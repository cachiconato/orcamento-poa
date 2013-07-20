require 'json'


def write_header(obj, output)
  headers = obj.keys.join('</th><th>')
  output.write("<tr><th>#{headers}</th></tr>")
end

def write_data(obj, output)
  values = obj.values.join('</td><td>')
  output.write("<tr><td>#{values}</td></td>")
end

def extract_data(data, output)
  output.write('<table border="1">')
  write_header(data.first, output)

  data.each do |obj|
    write_data(obj, output)
  end

  output.write('</table>')
end


text = File.read('ppa-orcamento-rs-2013.txt')
data = JSON.parse(text)

output = File.open('output.html', 'w')
output.write('<html><head><meta charset="utf-8"></head><body>')

data.each do |key, value|
  output.write("<h1>#{key}</h1>")
  extract_data(value, output)
end

output.write('</body>')
output.close()
