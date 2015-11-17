require_relative 'lib/configuration.rb'

$cfg = Configuration.new({
	# These are the chromosomes to be analyzed 
	"chromosomes" => (1..22).to_a,

	# input plink file
	"input_plink" => "../b37/strandup",

	# where the phasing resides
	"phase_dir" => "phasing",


	# Where the imputation panel resides
	"panels" => [
		{ 	
			:haps => proc { |chr| "../1000GP_Phase3_b37/1000GP_Phase3_chr#{chr}.hap.gz" },
			:legends => proc { |chr| "../1000GP_Phase3_b37/1000GP_Phase3_chr#{chr}.legend.gz" }
		}
#		{ 
#			:haps => proc { |chr| "../1000GP_Phase3_b37/1000GP_Phase3_chr#{chr}.hap.gz" },
#			:legends => proc { |chr| "../1000GP_Phase3_b37/1000GP_Phase3_chr#{chr}.legend.gz" }
#		}
	],

	"maps" => proc { |chr| "../1000GP_Phase3_b37/genetic_map_chr#{chr}_combined_b37.txt" },


	# setup progs
	"plink" => "../common/software/plink",
	"bgzip" => "../common/software/bgzip",
	"tabix" => "../common/software/tabix",


	"shapeit" => "../common/software/shapeit",
	"shapeit_threads" => 16,


	"impute2" => "../common/software/impute_v2.3.2_x86_64_static/impute2",
	"impute2_memory" => "10000", # Specified in megabytes or slurm
	
	"impute2_chunksize" => 2000000,

	"vcf_from_imputed" => "vcf-misc-tools/vcf-from-imputed",
	"vcf_call_threshold" => 0.9
})
