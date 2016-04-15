require_relative 'cfg.rb'
require_relative 'lib/chunking.rb'

puts $cfg.inspect

$cfg.chromosomes.each do |chr| 
	Chunking::infer_chunks(chr, $cfg.impute2_chunksize).each do |chunk|
		script=Chunking::make_script(*chunk)
		`qsub #{script}`
		#`sbatch -p normal -n1 -c1 #{script}`
	end
end
