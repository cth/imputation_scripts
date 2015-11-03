require 'cfg.rb'

$cfg.chromosomes.each do |chr|
	script="sge/phase.#{chr}.sge"
	File.open(script, "w") do |file|
		file.puts "#!/bin/bash"
		file.puts "\#$ -S /bin/bash" 
		file.puts "\#$ -N x.phase$chr" 
		file.puts "\#$ -cwd"
		file.puts "\#$ -pe smp #{$cfg.shapeit_threads}"
		extra_opts = chr==23 ? "--chrX" : ""
		file.puts "#{shapeit} --input-bed #{$cfg.unphased_bed} #{$cfg.unphased_bim} #{$cfg.unphased_fam} --input-map #{$cfg.map(chr)} -O #{$cfg.phased_haps(chr)} #{$cfg.phased_sample(chr)} --thread #{$cfg.shapeit_threads} -L #{cfg.phased_log(chr)} #{extra_opts}"
		chmod +x $script
		`chmod + #{script}`	
		`sbatch -p normal -n1 -c16 #{script}`
	end
end
