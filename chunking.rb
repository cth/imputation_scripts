module Chunking
	@@genetic_map_dir="ALL_1000G_phase1integrated_v3_impute"
	#@@genetic_map_dir="../ALL.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.nomono"
	@@panel_dir=@@genetic_map_dir
	@@phased_dir="phasing/phased"
	@@unphased_dir="phasing/unphased"

	def Chunking::make_script( chromosome, chunk_start, chunk_end)
		if chromosome == 23 then
			panel_chr="X_nonPAR"
			impute_cmd = [
				"impute2",
				"-m #{@@genetic_map_dir}/genetic_map_chr#{panel_chr}_combined_b37.txt",
				"-h #{@@panel_dir}/ALL*chr#{panel_chr}_*hap*", 
				"-l #{@@panel_dir}/ALL*chr#{panel_chr}_*legend*", 
				"-chrX -sample_known_haps_g #{@@phased_dir}/chr23.phased.sample",
				"-known_haps_g #{@@phased_dir}/chr#{chromosome}.phased.haps",
				"-use_prephased_g",
				"-o_gz",
				"-Ne 20000",
				"-int #{chunk_start} #{chunk_end}",
				"-buffer 500",
				"-o imputed/chr#{chromosome}-chunk-#{chunk_start}-#{chunk_end}.impute"].join(" \\\n\t")
		else
			panel_chr=chromosome
			impute_cmd = [
				"impute2",
				"-m #{@@genetic_map_dir}/genetic_map_chr#{panel_chr}_combined_b37.txt",
				"-h #{@@panel_dir}/ALL*chr#{panel_chr}_*hap*", 
				"-l #{@@panel_dir}/ALL*chr#{panel_chr}_*legend*", 
				"-known_haps_g #{@@phased_dir}/chr#{chromosome}.phased.haps",
				"-use_prephased_g",
				"-o_gz",
				"-Ne 20000",
				"-int #{chunk_start} #{chunk_end}",
				"-buffer 500",
				"-o imputed/chr#{chromosome}-chunk-#{chunk_start}-#{chunk_end}.impute"].join(" \\\n\t")
		end

		script = [
			"#!/bin/bash",
			"#\$ -S /bin/bash",
			"#\$ -N x.imp#{chromosome}-#{chunk_start}",
			"#\$ -cwd",
			"#\$ -pe smp 4",
			impute_cmd
		].join("\n")

		File.open("sge/impute-chr.#{chromosome}.#{chunk_start}-#{chunk_end}.sge", "w") do |f|
			f.write(script)
		end
	end

	def Chunking::infer_chunks(chromosome,max_chunk_size=2000000) 
		positions=[]
		puts "making chunks from #{@@unphased_dir}/chr#{chromosome}.bim"
		DF.new("#{@@unphased_dir}/chr#{chromosome}.bim").each { |_,_,_,pos,_,_| positions << pos.to_i }
		positions.sort!
		index = positions.first.to_i
		chunks = []
		loop do 
			next_index=index+max_chunk_size
			break if next_index > positions.last.to_i
			puts "\t" + [ index, next_index ].inspect
			chunks << [ chromosome, index, next_index ]
			index = next_index
		end 

		chunks	
	end
end
