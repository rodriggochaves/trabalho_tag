require 'pp'
require 'matrix'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'
require 'rubygems'
require 'k_means'
require 'gruff'

PHI = '1'
EULER = '2.718281828'

class Utility
  def split_data data
    container = {
      verylow: {x: [], y: []},
      low: {x: [], y: []},
      middle: {x: [], y: []},
      high: {x: [], y: []}
    }
    data.each do |d|
      container[d[2]][:x] << value(d[0])
      container[d[2]][:y] << value(d[1])
    end

    return container
  end

  def value n
    BigDecimal.new(n.gsub(',', '.'))
  end
end