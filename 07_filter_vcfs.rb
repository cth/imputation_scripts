require_relative 'cfg.rb'

`mkdir -p filtered_VCFs`

$cfg.chromosomes.each do |chr| 
	input_file="VCFs_by_chromosome/chr#{chr}.vcf.gz"
	output_file="filtered_VCFs/chr#{chr}.vcf"
	script_name = "sge/vcf-filter-#{chr}.sge"
	script = File.open(script_name,"w")
	script.puts("\#$ -S /bin/bash")
	script.puts("\#$ -N x.filt#{chr}")
	script.puts("\#$ -cwd")
	script.puts "zcat #{input_file}|ruby -e \"require './lib/utils.rb'; filter_by_info(#{$cfg.minimum_info})\" > #{output_file}"
	script.puts "#{$cfg.bgzip} #{output_file}"
	script.puts "#{$cfg.tabix} -p vcf #{output_file}.gz"	
	script.close
	`qsub #{script_name}`
end

