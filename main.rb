require_relative './lib/extractor'

e = Extractor.new
e.extract
e.init_affinity_matrix
e.create_diagonal_matrix
e.create_laplace_matrix
e.eigenvectors
e.renormalize
e.kmeans