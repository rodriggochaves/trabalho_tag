require 'pp'
require 'matrix'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'

class Extractor
  def extract
    options = { col_sep: ';' }
    path = "user_knowledge_data/micro.data"
    @data = []
    CSV.foreach(path, options) do |line|
      @data << line
    end
  end

  def create_affinity_matrix
    @affinity = self.create_matrix @data.size
    @data.each_with_index do |line, outer_index|
      line_sum = 0
      for i in 0..4
        for j in 0..@data.size
          a = numeric_value(line[i])
          b = numeric_value(@data[outer_index + 1][j])
          pp "Vou somar #{a.to_digits} e #{b.to_digits}"
        end
      end
      # line.each_with_index do |c, index|
      #   pp "valor de c: #{c}"
      #   # pp (c.to_i + @data[outer_index][index + 1].to_i)
      # end
      # pp line_sum
    end
  end

  def create_matrix size
    matrix = []
    size.times do
      matrix << Array.new(5, 0)
    end
    matrix
  end

  def numeric_value n
    BigDecimal.new(n.gsub(",", "."))
  end
end