module Chunking
	class Configuration
		attr_accessor :phased_dir, :unphased_dir, :genetic_map_dir, :panel_dir

		def initialize(panel_dir = "panel", genetic_map_dir = "panel", phase_dir="phasing")
			@panel_dir = panel_dir
			@genetic_map_dir = panel_dir
			@phased_dir="#{phase_dir}/phased"
			@unphased_dir="#{phase_dir}/unphased"
		end

		def map(chr)
			"#{@genetic_map_dir}/genetic_map_chr#{chr}_combined_b37.txt",
		end

		def haps(chr)
			"#{@panel_dir}/ALL*chr#{chr}_*hap*", 
		end

		def legend(chr)
			"#{@panel_dir}/ALL*chr#{chr}_*legend*", 
		end

		def phased_haps
			"-known_haps_g #{@@phased_dir}/chr#{chromosome}.phased.haps",
		end
	end

	class CNF_1000GP_Phase3_b37 < Configuration
		def haps(chr)
			"#{@panel_dir}/1000GP_Phase3_b37_chr#{chr}.hap.gz", 
		end

		def legend(chr)
			"#{@panel_dir}/1000GP_Phase3_b37_chr#{chr}.legend.gz", 
		end


	end 

	def Chunking::make_script( cnf, chromosome, chunk_start, chunk_end)
		impute_cmd = [
			"impute2",
			"-m #{cnf.map(chromosome)}",
			"-h #{cnf.haps(chromosome)}",
			"-l #{cnf.legend(chromosome)}",
			chromosome==23 ? "-chrX -sample_known_haps_g #{cnf.known_haps(chromosome)}" : "-known_haps_g #{cnf.known_haps(chromosome)}",
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
