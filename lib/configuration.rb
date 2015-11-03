
class Configuration
	def initialize(hsh = {
			"panels" => [ { 
				:haps => proc { |chr| "1000GP_Phase3_b37/1000GP_Phase3_chr#{chr}.hap.gz" }, 
				:legends => proc { |chr| "1000GP_Phase3_b37/1000GP_Phase3_chr#{chr}.legend.gz" }
			}], 
			"maps" => proc { |chr| "1000GP_Phase3_b37/genetic_map_chr#{chr}_combined_b37.txt" },
			"phase_dir" => "phasing" })
		@hsh = hsh
		@hsh["phased_dir"]="#{@hsh["phase_dir"]}/phased"
		@hsh["unphased_dir"]="#{@hsh["phase_dir"]}/unphased"

	end

	def map(chr)
		@hsh["maps"].call(chr)
	end

	[:haps, :legends].each do |type|
		define_method(type.to_s) do |chr|
			@hsh["panels"].collect { |pnl| pnl[type].call(chr) }
		end
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

