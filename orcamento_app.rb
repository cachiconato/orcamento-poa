require "sinatra/base"
require "sinatra/json"

class OrcamentoApp < Sinatra::Base
  helpers Sinatra::JSON

  configure do
    set :views, Proc.new { File.join(root, "public/views") }
  end

  get '/' do
    erb :index
  end

  get '/agencies' do
    json :x => 'bla'
  end

end
