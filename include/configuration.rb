class Configuration
	attr_accessor :phased_dir, :unphased_dir, :genetic_map_dir, :panel_dir

	def initialize(panel_dir = "panel", genetic_map_dir = "panel", phase_dir="phasing")
		@panel_dir = panel_dir
		@genetic_map_dir = panel_dir
		@phased_dir="#{phase_dir}/phased"
		@unphased_dir="#{phase_dir}/unphased"
		@hsh = {}
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


	# shapeit file extensions
	["haps", "sample", "log" ].each do |ext|
		define_method("phased_#{ext}") do |chr|
			"#{@phased_dir}/chr#{chr}.phased.#{ext}"
		end
	end


	["bed","bim","fam"].each do |ext|
		define_method("unphased_#{ext}") do |chr|
			"#{@unphased_dir}/chr#{chr}.#{ext}"
		end
	end
	

	# catch all to  
	def method_missing(method_name, *argument, &block) 
		if method_name.to_s =~ /(.*)=$/ then
			@hsh[$1] = argument.first 
		elsif @hsh.include?[method_name] then
			@hsh[method_name]
		else
			super
		end
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

