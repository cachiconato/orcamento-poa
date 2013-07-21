require 'json'

module ToJson
  def to_json(options={})
    hash_with_attributes.to_json
  end

  private

  def hash_with_attributes
    instance_variables.inject({}) do |hash, variable|
      variable_name = variable.to_s.sub('@', '')
      hash[variable_name] = instance_variable_get(variable)
      hash
    end
  end
end

class Product
  include ToJson

  attr_accessor :decription, :unit, :value, :total_spent, :percentage
  
  def initialize(description, unit, value)
    @description = description
    @unit = unit
    @value = value
    @percentage = 0
    @total_spent = (unit == 'R$' && value) || 0
  end

end

class Project
  include ToJson

  attr_accessor :name, :total_budgeted, :total_paid, :percentage

  def initialize(name, total_budgeted, total_paid)
    @name = name
    @total_budgeted = total_budgeted
    @total_paid = total_paid
    @percentage = 0
  end

end

class Action
  include ToJson

  attr_accessor :title, :description, :total_spent, :projects, :products, :percentage

  def initialize(title, description)
    @title = title
    @description = description
    @total_spent = 0
    @percentage = 0
    @projects = []
    @products = {}
  end

  def add_project!(project)
    @total_spent += project.total_paid
    @projects << project
  end

  def add_product!(product)
    @total_spent += product.total_spent

    @products[product.unit] ||= []
    @products[product.unit] << product
  end 

end

class Program
  include ToJson

  attr_accessor :name, :goal, :total_spent, :actions, :percentage

  def initialize(name, goal)
    @name = name
    @goal = goal
    @total_spent = 0
    @percentage = 0
    @actions = []
  end

  def add_action!(action)
    @total_spent += action.total_spent
    @actions << action
  end

end

class Agency
  include ToJson

  attr_accessor :name, :total_spent, :programs, :percentage

  def initialize(name)
    @name = name
    @total_spent = 0
    @percentage = 0
    @programs = []
  end

  def add_program!(program)
    @total_spent += program.total_spent
    @programs << program
  end

end

file = File.read('ppa-orcamento-rs-2013.txt')
data = JSON.parse(file)

actions_by_id = data['acao'].inject({}) do |hash, ac|
  hash[ac['id_acao']] = Action.new ac['titulo_acao'], ac['desc_acao']
  hash
end

data['projeto'].each do |prj|
  project = Project.new prj['nome_projeto'], prj['valor_orcado'].to_f, prj['valor_liquidado'].to_f
  actions_by_id[prj['id_acao']].add_project! project
end

data['produto'].each do |prd|
  product = Product.new prd['produto'], prd['unidade_medida'], prd['quantidade'].to_f
  actions_by_id[prd['id_acao']].add_product! product
end

programs_by_agency = {}

data['acao'].each do |ac|
  programs_by_agency[ac['id_orgao']] ||= {}
  program = programs_by_agency[ac['id_orgao']][ac['id_programa']]

  unless program
    prg = data['programa'].find { |prg| prg['id_programa'] == ac['id_programa']  }
    program = Program.new prg['nome_programa'], prg['objetivo_programa']
    programs_by_agency[ac['id_orgao']][ac['id_programa']] = program
  end

  program.add_action! actions_by_id[ac['id_acao']]
end

agencies = data['orgao'].collect do |org|
  agency = Agency.new org['nome_orgao']
  programs_by_agency[org['id_orgao']].each { |id, program| agency.add_program! program }
  agency
end

def calculate_percentage!(values)
  total = values.inject(0) {|sum, obj| sum + obj.total_spent}
  return if total == 0

  values.each { |obj| obj.percentage = (obj.total_spent / total) * 100 }
end

def sort_by_percentage(values)
  values.sort_by { |obj| obj.percentage * -1 }
end

calculate_percentage! agencies
agencies = sort_by_percentage agencies

agencies.each do |agency| 
  calculate_percentage! agency.programs 
  agency.programs = sort_by_percentage agency.programs

  agency.programs.each do |program|
    calculate_percentage! program.actions
    program.actions = sort_by_percentage program.actions

    program.actions do |action|
      calculate_percentage! action.projects
      action.projects = sort_by_percentage action.projects 

      calculate_percentage! action.products
      action.products = sort_by_percentage action.products 
    end
  end
end

File.open('data.json', 'w:UTF-8') { |f| f.write agencies.to_json }
