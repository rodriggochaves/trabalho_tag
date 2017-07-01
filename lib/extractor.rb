require 'pp'
require 'matrix'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'
require 'rubygems'
require 'k_means'

PHI = '1'
EULER = '2.718281828'

class Extractor
  
  attr_reader :f_data

  def names
    {
      'stg': 0,
      'scg': 1,
      'str': 2,
      'lpr': 3,
      'peg': 4,
      'uns': 5
    }
  end

  def discover_name name
    self.names[name.to_sym]
  end

  def extract
    options = { col_sep: ';' }
    path = "user_knowledge_data/mini.data"
    @data = []
    CSV.foreach(path, options) do |line|
      @data << line
    end
  end

  def filter_data l1, l2
    @f_data = []
    @data.each do |line|
      d1 = line[discover_name(l1)]
      d2 = line[discover_name(l2)]
      d3 = line[5].downcase.to_sym
      @f_data << [d1, d2, d3]
    end
  end

  def create_matrix s1
    matrix = []
    s1.times do
      matrix << Array.new(s1, 0)
    end
  end
end