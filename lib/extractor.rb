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

    pp @affinity_x
    pp @affinity_y
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

  
end