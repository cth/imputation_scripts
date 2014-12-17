require_relative 'df.rb'
require_relative 'chunking.rb'

`rm -f all_1_22.impute`

1.upto(22) do |i| 
	Chunking::infer_chunks(i).each do |chr,chunk_start,chunk_end|
		puts "merging imputed/chr#{chr}-chunk-#{chunk_start}-#{chunk_end}.impute.gz"
		`zcat imputed/chr#{chr}-chunk-#{chunk_start}-#{chunk_end}.impute.gz >> all_1_22.impute`
	end
end
