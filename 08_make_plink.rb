require_relative 'cfg.rb'

`mkdir -p filtered_VCFs`

jobs=[]
merge_list_file="plink/list_imputed_plink_files.txt"
File.open(merge_list_file,"w") do |file|
	$cfg.chromosomes.each do |chr| 
		input_file="filtered_VCFs/chr#{chr}.vcf.gz"
		output_file="plink/imputed-#{chr}"
		script_name = "sge/vcf-to-plink-#{chr}.sge"
		script = File.open(script_name,"w")
		script.puts("\#$ -S /bin/bash")
		script.puts("\#$ -N x.plink#{chr}")
		script.puts("\#$ -cwd")
		script.puts("#{cfg.plink} --vcf #{input_file} --make-bed --out #{output_file}")
		script.close
		qsubout=`qsub #{script_name}`
		jobs<<$1 if qsubout =~ /Your job ([0-9]+)/ 
		file<<output_file
	end
end

script_name = "sge/merge-imputed-plink.sge"
script = File.open(script_name,"w")
script.puts("\#$ -S /bin/bash")
script.puts("\#$ -N x.mrgplnk")
script.puts("\#$ -cwd")
script.puts("#{$cfg.plink} --merge-list #{merge_list_file} --out plink/imputed-all-chromosomes")
script.close

`qsub -hold_jid #{jobs.join(",")} #{script_name}`
