class OrcamentoApp < Sinatra::Base
  configure do
    set :views, Proc.new { File.join(root, "public/views") }
  end

  get '/' do
    erb :index
  end

end
