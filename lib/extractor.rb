require_relative './utility'
#require 'rubygems'
#require 'k_means'
require 'bigdecimal'
require 'bigdecimal/util'

class Extractor < Utility
  
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

  def user_scores
    {
      verylow: 0,
      low: 1,
      middle: 2,
      high: 3,
    }
  end

  def discover_index name
    self.names[name.to_sym]
  end

  def discover_name i
    self.user_scores.key(i).to_sym
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
      d1 = line[discover_index(l1)]
      d2 = line[discover_index(l2)]
      d3 = line[5].downcase.to_sym
      @f_data << [d1, d2, d3]
    end
  end

  def c_affinity 
    container = split_data(@f_data)
    @affinity_x = create_matrix(4, "value('0')")
    @affinity_y = create_matrix(4, "value('0')")

    for i in 0..3
      for j in 0..3
        if i != j
          evaluate_cal(container, i, j, :x)
          evaluate_cal(container, i, j, :y)
        end
      end
    end

    pp @affinity_x
    pp @affinity_y
  end

  def evaluate_cal container, i, j, symb
    container[discover_name].each_with_index do |a, t|
      b = array2[t]
      cal = difference(a, b)
      @affinity_x[i][j] += cal
    end
  end

  def create_matrix s1, data
    matrix = []
    s1.times do
      matrix << Array.new(s1, eval(data))
    end
    return matrix
  end

  def difference a, b
    a ||= 0
    b ||= 0
    return (a - b) ** value('2')
  end

  def print_debug_container
    container = split_data(@f_data)
    container.each do |k,v|
      pp "#{k} contem #{v}"
    end
  end

  def testando_kmeans
    new_matrix = []
    for i in 0..@data.size do
        new_matrix << Array.new(5,BigDecimal(0))
    end

    for i in -1..@data.size do
      for j in 0..4 do
        new_matrix[i][j] = BigDecimal.new(new_matrix[i][j].gsub(',','.'))
      end
    end
    pp @data
    #kmeans = KMeans.new(@data, :centroids => 2)
  end
end