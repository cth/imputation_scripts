require_relative 'cfg.rb'

$cfg.chromosomes.each do |chr|
	script="sge/phase.#{chr}.sge"
	File.open(script, "w") do |file|
		file.puts "#!/bin/bash"
		file.puts "\#$ -S /bin/bash" 
		file.puts "\#$ -N x.phase#{chr}" 
		file.puts "\#$ -cwd"
		file.puts "\#$ -pe smp #{$cfg.shapeit_threads}"
		extra_opts = chr==23 ? "--chrX" : ""
		file.puts "#{$cfg.shapeit} --input-bed #{$cfg.unphased_bed(chr)} #{$cfg.unphased_bim(chr)} #{$cfg.unphased_fam(chr)} --input-map #{$cfg.map(chr)} -O #{$cfg.phased_haps(chr)} #{$cfg.phased_sample(chr)} --thread #{$cfg.shapeit_threads} -L #{$cfg.phased_log(chr)} #{extra_opts}"
	end
	`qsub #{script}`
	#`sbatch -p normal -n1 -c16 #{script}`
end
