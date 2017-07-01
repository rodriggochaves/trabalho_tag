require 'gruff'

class Graphic
  def initialize data
    g = Gruff::Dot.new(1200)
    g.title = 'Kill me plox'
    g.labels = {
      0 => '0',
      1 => '0.5',
      2 => '1'
    }
    g.data(:high, [0.2,0.3,0.4,0.5,0.6])
    g.data(:middle, [0.3,0.7,0.9,0.1,0.3])
    g.data(:low, [0.25,0.1,0.9,0.3,0.3])
    g.data(:verylow, [0.7,0.8,0.1,0.7,0.1])
    g.write('tmp/graphic.png')
  end
end