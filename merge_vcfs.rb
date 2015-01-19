#!/home/fng514/bin/ruby
#$ -S /home/fng514/bin/ruby 
#$ -N x.merge 
#$ -cwd

require_relative 'df'
require_relative 'chunking.rb'

#`rm -f all_1_22.impute`

#i=ARGV[0]


`mkdir -p VCFs_by_chromosome`
chr = 21


File.open("input_files.txt") do |file|
	file.each do |line|
		cohort_name=`basename #{line}`.chomp
		puts cohort_name

		
		1.upto(23).each do |chr|
			script_name = "sge/vcf-merge-#{cohort_name}-#{chr}.sge"
			output_file="VCFs_by_chromosome/#{cohort_name}_chr#{chr}.vcf"

			puts script_name
			script = File.open("sge/vcf-merge-#{cohort_name}-#{chr}.sge","w")
			script.puts("\#$ -S /bin/bash")
			script.puts("\#$ -N x.mvcf#{chr}-#{cohort_name}")
			script.puts("\#$ -cwd")
			script.puts("rm -f #{output_file}")
			line=1

			Chunking::infer_chunks(chr).each do |_,chunk_start,chunk_end|
				chunk_file="VCFs/#{cohort_name}.chr#{chr}-chunk-#{chunk_start}-#{chunk_end}.impute.gz.vcf.gz"
				next unless File.exists?(chunk_file)

				if line == 1 then 
					skip_header=" "
				else 
					skip_header="|grep -v \"^#\""
				end


				script.puts "zcat  #{chunk_file} #{skip_header} >> #{output_file}"
				line = line + 1
			end

			script.puts "bgzip #{output_file}"
			script.puts "tabix -p vcf #{output_file}.gz"	
			script.close
			`qsub #{script_name}`
		end
	end
end
