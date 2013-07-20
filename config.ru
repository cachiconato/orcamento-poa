require 'rubygems'
require 'bundler'

Bundler.require
Dir["./app/model/*.rb"].each {|file| require file }

require './orcamento_app'

run OrcamentoApp
