#!/bin/sh

threads=16

for chr in `seq 1 23` 
do
	script=phase.$chr.sge
	if [ $chr == 23 ]; then
		map_chr="X_nonPAR"
		extraopts="--chrX"
	else
		map_chr=$chr
		extraopts=
	fi
	chrmap=map/genetic_map_chr${map_chr}_combined_b37.txt.gz
	echo "#!/bin/bash" > $script 
	echo "#$ -S /bin/bash"  >> $script 
	echo "#$ -N phase$chr" >> $script 
	echo "#$ -cwd" >>  $script 
	echo "#$ -pe smp $threads" >> $script 
	echo "shapeit --input-bed unphased/chr${chr}.unphased.bed unphased/chr${chr}.unphased.bim unphased/chr${chr}.unphased.fam --input-map $chrmap --output-max phased/chr$chr.phased.haps phased/chr$chr.phased.sample --thread $threads -L phased/chr$chr.phased.log $extraopts" >> $script
	chmod +x $script
	#qsub $script
done

