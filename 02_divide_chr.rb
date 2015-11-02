#!/bin/sh
plink=`../common/software/plink`

# Divide by chromosome
$cfg.chromosomes.each do |chr| 
	script="sge/chrsplit.#{chr}.sge"
	File.open(script, "w")) do |file|
		file.puts "#!/bin/bash"
		file.puts "\#$ -S /bin/bash"
		file.puts "#{$cfg.plink} --bfile plink/all_hwe10e_maf001_geno005 --chr #{chr} --make-bed --out #{$cfg.unphased_stem(chr)}"
	end
	`sbatch -p normal -n1 -c1 sge/chrsplit..sge`
done

