require_relative 'cfg.rb'
require_relative 'lib/chunking.rb'

$cfg.impute2_memory = $cfg.impute2_memory_failed

failed=0
success=0

$cfg.chromosomes.each do |chr| 
	Chunking::infer_chunks(chr, $cfg.impute2_chunksize).each do |chunk|
		outfile=Chunking::chunk_output_file(*chunk)
		if File.exists?(outfile + ".gz")
			success = success + 1
		else
			puts outfile
			script=Chunking::make_script(*chunk)
			`cat #{script}`
			failed = failed + 1
			`qsub #{script}`
		end
		#`sbatch -p normal -n1 -c1 #{script}`
	end
end

puts "Successfully imputed chunks: #{success}"
puts "Failed chunks: #{failed}"

