require 'sinatra/base'
require 'sinatra/json'
require 'json'

class OrcamentoApp < Sinatra::Base
  helpers Sinatra::JSON

  @@agencies = JSON.parse File.read('data/data.json')

  configure do
    set :views, Proc.new { File.join(root, "public/views") }
  end

  get '/' do
    erb :index
  end

  get '/agencies' do
    json exclude_from @@agencies, ['programs']
  end

  get '/agency/:name' do
    json @@agencies.find { |ag| ag['name'] == params[:name] }
  end

  private 

  def exclude_from(values, attr_to_exclude)
    values.collect do |value|
      value.reject { |key| attr_to_exclude.include? key  }
    end
  end

end
