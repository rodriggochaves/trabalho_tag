require_relative './utility'

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

    for i in 0..3
      for j in 0..3
        if i != j
          @affinity_x[i][j] = gaussian_kernel(@affinity_x[i][j])
          @affinity_y[i][j] = gaussian_kernel(@affinity_y[i][j])
        end
      end
    end
  end

  def evaluate_cal container, i, j, symb
    container[discover_name(i)][symb].each_with_index do |a, t|
      b = container[discover_name(j)][symb][t]
      cal = difference(a, b)
      eval("@affinity_#{symb.to_s}[i][j] += cal")
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

  def gaussian_kernel a
    if a.zero?
      return 0
    else
      b = BigDecimal(a).sqrt(5)
      c = b * (value('-1.0')) / (value('2') * (value(PHI) ** value('2')) ) 
      return value(EULER) ** c
    end
  end

  def c_diagonals
    @diagonal_x = create_matrix 4, "value('0')"
    @diagonal_y = create_matrix 4, "value('0')"
    @affinity_x.each_with_index do |line, i|
      @diagonal_x[i][i] = line.inject(0){ |sum, e| sum + e }
    end
    @affinity_y.each_with_index do |line, i|
      @diagonal_y[i][i] = line.inject(0){ |sum, e| sum + e }
    end
  end

  def c_laplaces
    @laplace_x = create_laplace_matrix @diagonal_x, @affinity_x
    @laplace_y = create_laplace_matrix @diagonal_y, @affinity_y
  end

  def create_laplace_matrix source_d, source_a
    diagonal_sqrt = create_matrix 4, "value('0')"
    source_d.each_with_index do |line, i|
      diagonal_sqrt[i][i] = BigDecimal(source_d[i][i]).sqrt(5)
    end
    inverse_sqrt = Matrix.rows(diagonal_sqrt).inverse
    laplace = inverse_sqrt * Matrix.rows(source_a) * inverse_sqrt
    return laplace.to_a
  end

  def c_eigenvectors
    @eigenvector_x = create_eigenvectors @laplace_x
    @eigenvector_y = create_eigenvectors @laplace_y
  end

  def create_eigenvectors source
    reduce_laplace = create_matrix 4, "value('0')"
    source.each_with_index do |l, i|
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
    return x
  end

  def c_renormalize 
    @normalized_x = renormalize @eigenvector_x
    @normalized_y = renormalize @eigenvector_y

    pp @normalized_x
    pp @normalized_y
  end

  def renormalize source
    y = create_matrix 4, "value('0')"
    helper = Array.new(4, 0)
    for i in 0..3
      for j in 0..3
        helper[i] += source[i][j] ** value('2')
      end
    end
    helper.each do |h|
      h = BigDecimal(h).sqrt(5)
    end
    for i in 0..3
      for j in 0..3
        y[i][j] = source[i][j] / helper[i]
      end
    end

    return y
  end
end