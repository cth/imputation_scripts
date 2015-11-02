#!/bin/sh
plink=`../common/software/plink`

# Divide by chromosome
1.upto(23) do |chr| 
	script="sge/chrsplit.#{chr}.sge"
	File.open(script, "w")) do |file|
		[ "#!/bin/bash",
		"\#$ -S /bin/bash",
		"$plink --bfile plink/all_hwe10e_maf001_geno005 --chr $i --make-bed --out phasing/unphased/chr$i"]

		file.puts(lines.join("\n"))
	end
	#`sbatch -p normal -n1 -c1 sge/chrsplit..sge`
done

