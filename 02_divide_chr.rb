#!/bin/sh
plink=`../common/software/plink`

# Divide by chromosome
$cfg.chromosomes.each do |chr| 
	script="sge/chrsplit.#{chr}.sge"
	File.open(script, "w")) do |file|
		file.puts "#!/bin/bash"
		file.puts "\#$ -S /bin/bash"
		file.puts "#{$cfg.plink} --bfile plink/qc-#{hash_param_str(qc_opts)} --chr #{chr} --make-bed --out #{$cfg.unphased_stem(chr)}"
	end
	`sbatch -p normal -n1 -c1 sge/chrsplit.#{chr}.sge`
done

