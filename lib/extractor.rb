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
    eigenvectors
    renormalize
    pp round_matrix(@y, 2)
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

  def round_matrix matrix, n
    for i in 0..(@laplace.size - 1)
      for j in 0..(@laplace.size - 1)
        matrix[i][j] = matrix[i][j].round(n)
      end
    end
    return matrix
  end

  def eigenvectors
    reduce_laplace = []
    @laplace.each_with_index do |l, i|
      reduce_laplace << Array.new(@laplace.size, 0.to_f)
      l.each_with_index do |l1, j|
        reduce_laplace[i][j] = l1.to_f
      end
    end
    laplace = Matrix.rows(reduce_laplace)
    special_laplace = Matrix::EigenvalueDecomposition.new(laplace)
    x = special_laplace.eigenvector_matrix.to_a
    x.each do |line|
      line.map!{ |e| value(e.to_s)}
    end
    @x = x
  end

  def renormalize
    @y = []
    for i in 0..(@x.size - 1)
      line_sum = @x[i].inject(0){ |sum, e| sum += e ** 2.to_d }.sqrt(2)
      @y << Array.new(@x.size, 0.to_d)
      for j in 0..(@x.size - 1)
        @y[i][j] = @x[i][j] / line_sum
      end
    end
  end
end