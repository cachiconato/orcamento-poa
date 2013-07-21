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
  return if data.empty?

  output.write('<table border="1">')
  write_header(data.first, output)

  data.each do |obj|
    write_data(obj, output)
  end

  output.write('</table>')
end

def describe_object(obj, output)
  output.write "<p>"

  obj.each do |key, value|
    unless value.is_a? Array or value.is_a? Hash
      output.write "<b>#{key.capitalize}:</b> #{value} "
    end
  end

  output.write "</p>"
end


text = File.read('data.json')
data = JSON.parse(text)

output = File.open('data.html', 'w')
output.write('<html><head><meta charset="utf-8"></head><body>')

data.each do |agency|
  output.write("<h1>#{agency['name']}</h1>")
  describe_object agency, output

  agency['programs'].each do |program|
    output.write("<h2>Program:</h2>")
    describe_object program, output

    program['actions'].each do |action|
      output.write("<h3>Action:</h3>")
      describe_object action, output

      output.write("<h4>Projects:</h4>")
      extract_data action['projects'], output

      output.write("<h4>Products:</h4>")
      action['products'].each do |unit, products|
        extract_data products, output
      end

      output.write('<hr/>')
    end
    
    output.write('<hr/>')
  end
end

output.write('</body>')
output.close()
