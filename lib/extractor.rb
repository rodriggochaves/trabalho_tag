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
    @affinity = create_matrix(4, "[value('0'), value('0')]")

    [:x, :y].each_with_index do |c, k|
      for i in 0..3
        for j in 0..3
          if i != j
            container[discover_name(i)][:x].each_with_index do |a, t|
              b = container[discover_name(j)][:x][t]
              cal = difference(a, b)
              @affinity[i][j][k] += cal
            end
          end
        end
      end
    end

    pp @affinity
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
end