require_relative 'cfg.rb'
require_relative 'lib/chunking.rb'

`mkdir -p VCFs_by_chromosome`

$cfg.chromosomes.each do |chr| 
	script_name = "sge/vcf-merge-#{chr}.sge"
	output_file="VCFs_by_chromosome/chr#{chr}.vcf"

	puts script_name
	script = File.open("sge/vcf-merge-#{chr}.sge","w")
	script.puts("\#$ -S /bin/bash")
	script.puts("\#$ -N x.mvcf#{chr}")
	script.puts("\#$ -cwd")
	script.puts("rm -f #{output_file}")
	line=1

	Chunking::infer_chunks(chr, $cfg.impute2_chunksize).each do |_,from,to| 
		pwd=`pwd`.chomp
		chunkbase=Chunking::chunkbase(chr,from,to)
		vcf= pwd + "/VCFs/#{chunkbase}.vcf"
                vcfgz=vcf + ".gz"

		next unless File.exists?(vcfgz)

		if line == 1 then 
			skip_header=" "
		else 
			skip_header="|grep -v \"^#\""
		end

		script.puts "zcat  #{vcfgz} #{skip_header} >> #{output_file}"
		line = line + 1
	end

	script.puts "bgzip #{output_file}"
	script.puts "tabix -p vcf #{output_file}.gz"	
	script.close
	`qsub #{script_name}`
end

