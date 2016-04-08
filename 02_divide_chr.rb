require_relative 'cfg.rb'
require_relative 'lib/utils.rb'

hsh=({ :maf => $cfg.QC_maf, :mind => $cfg.QC_mind, :geno => $cfg.QC_geno, :hwe => $cfg.QC_hwe })

# Divide by chromosome
$cfg.chromosomes.each do |chr| 
	script="sge/chrsplit.#{chr}.sge"
	infile="plink/qc-" + hash_param_str(hsh)
	File.open(script, "w") do |file|
		file.puts '#!/bin/bash'
		file.puts '#$ -S /bin/bash'
		file.puts '#$ -cwd'
		file.puts "#{$cfg.plink} --bfile #{infile} --chr #{chr} --make-bed --out #{$cfg.unphased_stem(chr)}"
	end
	`qsub sge/chrsplit.#{chr}.sge`
	#`sbatch -p normal -n1 -c1 sge/chrsplit.#{chr}.sge`
end

