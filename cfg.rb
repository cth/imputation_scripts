require_relative 'lib/configuration.rb'

$cfg = Configuration.new({

	# These are the chromosomes to be analyzed 
	"chromosomes" => (1..22).to_a,

	# input plink file
	"input_plink" =>  "../b37/strandup",

	# where the phasing resides
	"phase_dir" => "phasing",


	# Where the imputation panel resides
	"panel_dir" => "../1000GP_Phase3_b37",

	# Where the imputation panel resides (map files)
	"genetic_map_dir" => "../1000GP_Phase3_b37",


	"shapeit_threads" => 16,

	# setup progs
	"plink" => "../common/software/plink",
	"shapeit" => "../common/software/shapeit",
	"impute2" => "../../common/software/impute_v2.3.2_x86_64_static/impute2"
})
