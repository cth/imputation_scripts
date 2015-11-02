require_relative 'cfg.rb'
require_relative 'include/chunking.rb'
$cfg.chromosomes.each do |chr| 
	Chunking::infer_chunks(i).each do |chunk| 
		script=Chunking::make_script(*chunk)
		`sbatch -p normal -n1 -c1 #{script}`
	end
end
