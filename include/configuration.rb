class Configuration

	def initialize(hsh = { "panel_dir" => "panel", "genetic_map_dir" => "panel", "phase_dir" => "phasing" })
		@hsh = hsh
		@hsh["phased_dir"]="#{@hsh["phase_dir"]}/phased"
		@hsh["unphased_dir"]="#{@hsh["phase_dir"]}/unphased"
		puts @hsh.inspect
	end

	def map(chr)
		"#{@hsh["genetic_map_dir"]}/genetic_map_chr#{chr}_combined_b37.txt"
	end


###	def haps(chr)
###		"#{@hsh["panel_dir"]}/ALL*chr#{chr}_*hap*"
###	end
###
###	def legend(chr)
###		"#{@hsh["panel_dir"]}/ALL*chr#{chr}_*legend*"
###	end

	def haps(chr)
		"#{@hsh["panel_dir"]}/1000GP_Phase3_b37_chr#{chr}.hap.gz"
	end

	def legend(chr)
		"#{@hsh["panel_dir"]}/1000GP_Phase3_b37_chr#{chr}.legend.gz"
	end



	# shapeit file extensions
	["haps", "sample", "log" ].each do |ext|
		define_method("phased_#{ext}") do |chr|
			"#{@hsh["phased_dir"]}/chr#{chr}.phased.#{ext}"
		end
	end

	alias :known_haps :phased_haps

	def unphased_stem(chr)
		"#{@hsh["unphased_dir"]}/chr#{chr}"
	end

	[ "bed","bim","fam"].each do |ext|
		define_method("unphased_#{ext}") do |chr|
			"#{unphased_stem(chr)}.#{ext}"
		end
	end

	# catch all
	def method_missing(method_name, *argument, &block) 
		puts method_name.inspect
		puts @hsh.inspect
		if method_name.to_s =~ /(.*)=$/ then
			@hsh[$1] = argument.first 
		elsif @hsh.include?(method_name.to_s) then
			@hsh[method_name.to_s]
		else
			super
		end
	end
end

class CNF_1000GP_Phase3_b37 < Configuration
	def haps(chr)
		"#{@panel_dir}/1000GP_Phase3_b37_chr#{chr}.hap.gz"
	end

	def legend(chr)
		"#{@panel_dir}/1000GP_Phase3_b37_chr#{chr}.legend.gz"
	end
end 

