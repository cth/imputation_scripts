require_relative 'cfg.rb'
require_relative 'lib/chunking.rb'

$cfg.chromosomes.each do |chr| 
	Chunking::infer_chunks(chr, $cfg.impute2_chunksize).each do |chr,from,to| 
		puts "#{chr} #{from} #{to}"
		pwd=`pwd`.chomp
		chunkbase=Chunking::chunkbase(chr,from,to)
                genofile=pwd + "/imputed/#{chunkbase}.impute.gz"
                infofile=pwd + "/imputed/#{chunkbase}.impute_info"
		samplefile= pwd + "/phasing/unphased/chr1.fam"
                vcf= pwd + "/VCFs/#{chunkbase}.vcf"
                vcfgz=vcf + ".gz"
		script="sge/impute-to-vcf-#{chr}-#{from}-#{to}.sge"
		File.open(script, "w") do |file|
			file.puts "#!/bin/bash"
			file.puts "\#$ -S /bin/bash" 
			file.puts "\#$ -N x.vcf" 
			file.puts "\#$ -cwd"
			file.puts "if [ -f #{infofile} ]; then"
                	file.puts "\t#{$cfg.vcf_from_imputed}  -c #{chr} -J #{infofile} -G #{genofile} -S #{samplefile} -V #{vcf} -l -d -g -t #{$cfg.vcf_call_threshold}"
                	file.puts "\t#{$cfg.bgzip} #{vcf}"
               		file.puts "\t#{$cfg.tabix} -p vcf #{vcfgz}"
			file.puts "fi"
		end
		`qsub #{script}`
		#`sbatch -p normal -n1 -c1 --mem=#{$cfg.impute2_memory} #{script}`
	end
end
