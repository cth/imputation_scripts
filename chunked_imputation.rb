# Create sge scripts for chunked imputation

require_relative 'df'
require_relative 'chunking.rb'

1.upto(23) { |i| Chunking::infer_chunks(i).each { |chunk| Chunking::make_script(*chunk) } }
