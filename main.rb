require_relative './lib/extractor'
require_relative './lib/graphic'

label1, label2 = ARGV[0], ARGV[1]

unless ARGV[0] && ARGV[1]
  pp "numerado errado de argumentos"
  exit
end

e = Extractor.new
e.extract
e.filter_data(label1, label2)
Graphic.new(e.f_data)
e.c_affinity
e.c_diagonals