mkdir -p VCFs

for chunk in imputed/chr*gz
do
	for inputplink in `cat input_files.txt`
	do
		chunkbase=`basename $chunk`
		inputbase=`basename $inputplink`
		chr=`echo $chunkbase|cut -d'-' -f1|cut -d'r' -f2`
		script=sge/vcf.$inputbase.$chunkbase.sge
		echo $script
		echo "#!/bin/bash" > $script 
		echo "#$ -S /bin/bash"  >> $script
		echo "#$ -N x.imp2vcf.$inputbase.$chunkbase" >> $script 
		echo "#$ -cwd" >>  $script 
		echo "scripts/imp2vcf -c $chr -g $(pwd)/$chunk -s "tmp/plink.sample" -k $inputplink.fam -v $(pwd)/VCFs/$inputbase.$chunkbase.vcf -l -d -t 0.99" >> $script
		echo "bgzip $(pwd)/VCFs/$inputbase.$chunkbase.vcf" >> $script
		echo "tabix -p vcf $(pwd)/VCFs/$inputbase.$chunkbase.vcf.gz" >> $script
		qsub $script
	done
done
