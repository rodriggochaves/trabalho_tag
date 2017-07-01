require 'pp'
require 'matrix'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'

class Extractor
  PHI = '1'
  EULER = '2.718281828'

  def extract
    options = { col_sep: ';' }
    path = "user_knowledge_data/mini.data"
    @data = []
    CSV.foreach(path, options) do |line|
      @data << line
    end
  end

  def init_affinity_matrix
    @affinity = self.create_matrix 4
    @data.each do |line|
      for i in 0..3
        sum = 0
        a = line[i]
        for j in 0..3
          if !(i == j)
            b = line[j]
            cal = difference(value(a), value(b))
            @affinity[i][j] += cal
          end
        end
      end
    end
    @affinity.each do |l|
      for j in 0..3
        l[j] = gaussian_kernel(l[j])
      end
    end
  end

  def create_matrix size
    matrix = []
    size.times do
      matrix << Array.new(4, 0)
    end
    matrix
  end

  def value n
    BigDecimal.new(n.gsub(",", "."))
  end

  def difference a, b
    return (a - b) ** value('2')
  end

  def gaussian_kernel a
    if a.zero?
      return 0
    else
      b = BigDecimal(a).sqrt(10)
      c = b * (value('-1.0')) / (value('2') * (value(PHI) ** value('2')) ) 
      return value(EULER) ** c
    end
  end

  def create_diagonal_matrix
    @diagonal = create_matrix 4
    @affinity.each_with_index do |line, i|
      @diagonal[i][i] = line.inject(0){ |sum, e| sum + e }
    end
  end

  def create_laplace_matrix
    diagonal_sqrt = create_matrix 4
    @diagonal.each_with_index do |line, i|
      diagonal_sqrt[i][i] = BigDecimal(@diagonal[i][i]).sqrt(10)
    end
    inverse_sqrt = Matrix.rows(diagonal_sqrt).inverse
    @laplace = inverse_sqrt * Matrix.rows(@affinity) * inverse_sqrt
  end
end