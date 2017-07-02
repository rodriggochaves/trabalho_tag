require_relative './utility'

class Graphic < Utility
  def initialize data
    container = split_data(data)    

    g = Gruff::Scatter.new(1200)
    g.title = 'Graph'
    g.data(:high, container[:high][:x], container[:high][:y])
    g.data(:middle, container[:middle][:x], container[:middle][:y])
    g.data(:low, container[:low][:x], container[:low][:y])
    g.data(:verylow, container[:verylow][:x], container[:verylow][:y])
    g.write('tmp/graphic.png')
  end
end