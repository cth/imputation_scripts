#!/bin/bash 
set -x 

# Settings:
plink=plink19
shapeit_threads=16

# make folders:
mkdir -p plink
mkdir -p phasing/unphased
mkdir -p phasing/phased
mkdir -p sge
mkdir -p imputed
mkdir -p VCFs

CHIP_STRAND_FILE=additional_files/HumanCoreExome-12v1-0_B-b37.strand
#CHIP_STRAND_FILE=additional_files/Metabochip-b37.58-v2.strand

function qsubid { 
	qsub -cwd $@ | cut -d" " -f3 
} 

function waitqid { 
	while [ 1 -eq `qstat -f|grep -w $1|wc|awk '{print $1}'` ]
	do 
		echo "waiting for $1 to finish"
		qstat -f | grep -C 5 -w $1
		sleep 5 
	done 
}

i=1
for plinkstem in `cat input_files.txt` # These file is assumed to be on TOP!
do
	echo $plinkstem
	pname=`basename $plinkstem`
	script=sge/plinkqc.$pname.sge
	echo "#!/bin/bash" > $script
	echo "#$ -S /bin/bash"  >> $script 
	echo "$ -cwd" >> $script

	# update to build37 plus strand  
	echo "bash scripts/update_build.sh \"$plinkstem\"  $CHIP_STRAND_FILE \"plink/$pname.strandupdated\"" >> $script 
	echo "$plink --bfile plink/$pname.strandupdated --maf 0.01 --mind 0.05 --geno 0.05 --make-bed --out plink/$pname.maf001_geno005" >> $script

	if [ $i -eq 1 ]; then
		LATEST=$pname.maf001_geno005
		LATEST_QID=`qsubid $LATEST_QID $script`
	else	
		echo "plink19 --bfile plink/$pname.maf001_geno005 --bmerge plink/$LATEST.bed plink/$LATEST.bim plink/$LATEST.fam --out plink/merge.$i" >> $script
		LATEST=merge.$i
		LATEST_QID=`qsubid -hold_jid $LATEST_QID $script`
	fi
	i=$(($i+1))
done

# HWE pruning 
script="sge/hweprune.sge"
echo "#!/bin/bash" > $script
echo "#$ -S /bin/bash"  >> $script 
echo "$ -cwd" >> $script
echo "$plink --bfile plink/$LATEST --hwe 0.000001 --make-bed --out plink/all_hwe10e_maf001_geno005" >> $script
LATEST_QID=`qsubid -hold_jid $LATEST_QID $script`

# Divide by chromosome
for i in `seq 1 23`
do
	echo "#!/bin/bash" > sge/chrsplit.$i.sge
	echo "#$ -S /bin/bash"  >> sge/chrsplit.$i.sge
	echo "$plink --bfile plink/all_hwe10e_maf001_geno005 --chr $i --make-bed --out phasing/unphased/chr$i"  >> sge/chrsplit.$i.sge
	qsub -N x.split$i -l mem_free=1G -hold_jid $LATEST_QID -cwd sge/chrsplit.$i.sge
done

phasing_ids=
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
	LATEST_QID=`qsubid -hold_jid x.split$chr $script`
	if [ $chr -eq 1 ]; then
		phasing_ids=$LATEST_QID
	else
		phasing_ids="$phasing_ids,$LATEST_QID"
	fi
done

script=sge/chunking.sge
echo "#!/bin/bash" > $script 
echo "#$ -S /bin/bash"  >> $script 
echo "#$ -N x.chunk" >> $script
echo "ruby scripts/chunked_imputation.rb" >> $script
echo "tail -n+3 phasing/phased/chr1.phased.sample > all.sample" >> $script
chunking_qid=`qsubid -hold_jid $phasing_ids $script`

# Here we need chunking to finish before proceeding

waitqid $chunking_qid

for chr in `seq 1 23` 
do
	for script in sge/impute-chr.$chr.*
	do
		qsub -hold_jid x.phase$chr $script
	done
done


for impsge in sge/impute-chr*sge
do
	for inputplink in `cat input_files.txt`
	do
		chunkbase=`basename $impsge|cut -d'-' -f2-3|cut -d'.' -f1-3`
		inputbase=`basename $inputplink`
		chr=`echo $chunkbase|cut -d'.' -f2`
		chunkstart=`echo $chunkbase|cut -d'.' -f3|cut -d'-' -f1` 
		script=sge/vcf.$inputbase.$chunkbase.sge
		echo $script
		echo "#!/bin/bash" > $script 
		echo "#$ -S /bin/bash"  >> $script
		echo "#$ -N x.imp2vcf.$inputbase.$chunkbase" >> $script 
		echo "#$ -cwd" >>  $script 
		echo "scripts/imp2vcf -c $chr -g $(pwd)/$chunk -s all.sample -k $inputplink.fam -v $(pwd)/VCFs/$inputbase.$chunkbase.vcf -l -d -t 0.99" >> $script
		echo "bgzip $(pwd)/VCFs/$inputbase.$chunkbase.vcf" >> $script
		echo "tabix -p vcf $(pwd)/VCFs/$inputbase.$chunkbase.vcf.gz" >> $script
		qsub -hold_jid x.imp$chr-$script-$chunkstart $script
	done
done
