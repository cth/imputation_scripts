module Chunking

	def Chunking::make_script( chromosome, chunk_start, chunk_end)
		impute_cmd = [
			"impute2",
			"-m #{$cfg.map(chromosome)}",
			"-h #{$cfg.haps(chromosome)}",
			"-l #{$cfg.legend(chromosome)}",
			chromosome==23 ? "-chrX -sample_known_haps_g #{$cfg.known_haps(chromosome)}" : "-known_haps_g #{$cfg.known_haps(chromosome)}",
			"-use_prephased_g",
			"-o_gz",
			"-Ne 20000",
			"-int #{chunk_start} #{chunk_end}",
			"-buffer 500",
			"-o imputed/chr#{chromosome}-chunk-#{chunk_start}-#{chunk_end}.impute"].join(" \\\n\t")

		script = [
			"#!/bin/bash",
			"#\$ -S /bin/bash",
			"#\$ -N x.imp#{chromosome}-#{chunk_start}",
			"#\$ -cwd",
			"#\$ -l h_vmem=4G",
			"#\$ -l mem_free=4G",
			"#\$ -pe smp 1",
			impute_cmd
		].join("\n")

		script_path = "sge/impute-chr.#{chromosome}.#{chunk_start}-#{chunk_end}.sge"
		File.open(script_path, "w") do |f|
			f.write(script)
		end
		
		script_path
	end

	def Chunking::infer_chunks(chromosome,max_chunk_size=2000000) 
		positions=[]
		puts "making chunks from #{ $cfg.unphased_bim(chromosome) }" 
		DF.new($cfg.unphased_bim(chromosome)).each { |_,_,_,pos,_,_| positions << pos.to_i }
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
