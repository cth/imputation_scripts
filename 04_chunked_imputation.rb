require_relative 'cfg.rb'
require_relative 'lib/chunking.rb'


puts $cfg.inspect

$cfg.chromosomes.each do |chr| 
	Chunking::infer_chunks(chr).each do |chunk| 
		script=Chunking::make_script(*chunk)
		`sbatch -p normal -n1 -c1 #{script}`
	end
end
