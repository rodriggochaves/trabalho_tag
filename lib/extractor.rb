require 'pp'
require 'matrix'
require 'csv'

class Extractor
  def extract
    options = { col_sep: ';' }
    path = "user_knowledge_data/mini.data"
    @data = []
    CSV.foreach(path, options) do |line|
      @data << line
    end
  end

  def create_affinity_matrix
    @affinity = self.create_matrix @data.size
    @data.each_with_index do |line, outer_index|
      line_sum = 0
      line.each_with_index do |c, index|
        line_sum += (c.to_i + @data[outer_index][index + 1].to_i)
      end
      pp line_sum
    end
  end

  def create_matrix size
    matrix = []
    size.times do
      matrix << Array.new(5, 0)
    end
    matrix
  end
end