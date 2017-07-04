require 'pp'
require 'matrix'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'
require 'rubygems'
require 'k_means'
require 'gruff'

class Extractor
  def initialize
    @phi = value('0,5')
    extract_data
    prepare_data
    raw_affinity_mt
    refined_affinity_mt
    diagonal_mt
    laplace_mt
    round_matrix
    eigenvectors
  end

  def extract_data
    options = { col_sep: ';' }
    path = "user_knowledge_data/micro.data"
    @data = []
    CSV.foreach(path, options) do |line|
      @data << line
    end
  end

  def prepare_data
    new_data = []
    for i in 0..(@data.size - 1)
      new_data << Array.new(4, value('0'))
      for j in 0..4
        new_data[i][j] = value(@data[i][j])
      end
    end
    @data = new_data
  end

  def value word
    BigDecimal.new(word.gsub(',', '.'))
  end

  def raw_affinity_mt
    @affinity = []
    for i in 0..(@data.size - 1)
      @affinity << Array.new(@data.size, value('0'))
      for j in 0..(@data.size - 1)
        for k in 0..4
          @affinity[i][j] += (@data[i][k] - @data[j][k]) ** value('2')
        end
      end
    end
  end

  def refined_affinity_mt
    for i in 0..(@affinity.size - 1)
      for j in 0..(@affinity.size - 1)
        if i != j
          @affinity[i][j] = gausian_kernel(@affinity[i][j])
        end
      end
    end
  end

  def gausian_kernel number
    a = number.sqrt(1)
    b = (a / (value('2') * @phi) ** 2) * value('-1')
    return Math::E.to_d ** b
  end

  def diagonal_mt
    @diagonal = []
    for i in 0..(@affinity.size - 1)
      @diagonal << Array.new(@affinity.size, 0.to_d)
      for j in 0..(@affinity.size - 1)
        @diagonal[i][i] += @affinity[i][j]
      end
    end
  end

  def laplace_mt
    diagonal_sqrt = []
    @diagonal.each_with_index do |line, i|
      diagonal_sqrt << Array.new(@diagonal.size, 0.to_d)
      diagonal_sqrt[i][i] = @diagonal[i][i].sqrt(2)
    end
    inverse_sqrt = Matrix.rows(diagonal_sqrt).inverse
    laplace = inverse_sqrt * Matrix.rows(@affinity) * inverse_sqrt
    @laplace = laplace.to_a
  end

  def round_matrix
    for i in 0..(@laplace.size - 1)
      for j in 0..(@laplace.size - 1)
        @laplace[i][j] = @laplace[i][j].round(7)
      end
    end
  end

  def eigenvectors
  end
end