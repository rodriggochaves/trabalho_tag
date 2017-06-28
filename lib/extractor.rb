require 'pp'

class Extractor
  def extract
    File.open("mini.data", "r") do |descriptor|
      @matrix = []
      while line = descriptor.gets
        @matrix << line.gsub("\n", '').split(",")
      end
    end
  end

  def create_affinity_matrix
    @affinity_matrix = self.create_matrix
    for i in 1..100 # rows
      for j in 1..11 # columns
        unless i != j
          aux = 0
          for k in 1..11 # columns
            aux += Math.sqrt((@matrix[i-1][j-1] - @matrix[i-1][k-1]) ** 2)
          end
        end
      end
    end
  end

  def print_matrix
    pp @matrix
  end

  def create_matrix
    matrix = []
    for i in 1..100
      matrix << Array.new(11, 0)
    end
    matrix
  end
end