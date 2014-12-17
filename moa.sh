plink=plink19

# make folders:
mkdir -p phasing/unphased
mkdir -p phasing/phased
mkdir -p sge
mkdir -p imputed

# This file is assumed to be on TOP!
INPUT_PLINK=/eva/data/clean/target/chip_data/Target_and_GBparents_clean_V1

# QC filters:
$plink --noweb --bfile $INPUT_PLINK --maf 0.01 --geno 0.05 --hwe 0.0001 --make-bed --out plink/hwe10e_maf001_geno005

# remove gastric bypass parents:
$plink --bfile plink/hwe10e_maf001_geno005 --remove <( cat plink/hwe10e_maf001_geno005.fam|awk '{print $1,$2}'|grep "GB") --make-bed --out plink/hwe10e_maf001_geno005_nogastric_par

# update to build37 plus strand  
bash scripts/update_build.sh plink/hwe10e_maf001_geno005_nogastric_par  additional_files/HumanCoreExome-12v1-0_B-b37.strand plink/strandupdated 

# Divide by chromosome
for i in `seq 1 23`
do
	echo "#!/bin/bash" > sge/chrsplit.$i.sge
	echo "#$ -S /bin/bash"  >> sge/chrsplit.$i.sge
	echo "$plink --bfile plink/strandupdated --chr $i --make-bed --out phasing/unphased/chr$i"  >> sge/chrsplit.$i.sge
	qsub -N chrspl$i  -cwd sge/chrsplit.$i.sge
done

shapeit_threads=16

for chr in `seq 1 23` 
do
	script=sge/phase.$chr.sge
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
	echo "#$ -N x.phase$chr" >> $script 
	echo "#$ -cwd" >>  $script 
	echo "#$ -pe smp $shapeit_threads" >> $script 
	echo "shapeit --input-bed phasing/unphased/chr${chr}.bed phasing/unphased/chr${chr}.bim phasing/unphased/chr${chr}.fam --input-map $chrmap -O phasing/phased/chr$chr.phased.haps phasing/phased/chr$chr.phased.sample --thread $shapeit_threads -L phasing/phased/chr$chr.phased.log $extraopts" >> $script
	chmod +x $script
	qsub -hold_jid chrspl$chr $script
done

ruby scripts/chunked_imputation.rb

for chr in `seq 1 23` 
do
	for script in sge/impute-chr.$chr.*
	do
		qsub -hold_jid x.phase$chr $script
	done
done
