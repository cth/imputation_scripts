require_relative 'include/configuration.rb'

$cfg = CNF_1000GP_Phase3_b37.new({

	# These are the chromosomes to be analyzed 
	"chromosomes" => (1..22).to_a,

	# input plink file
	"input_plink" =>  "../b37/strandup",


	# Where the imputation panel resides
	"panel_dir" => "../1000GP_Phase3_b37",

	"shapeit_threads" => 16,

	# setup progs
	"plink" => "../common/software/plink",
	"shapeit" => "../common/software/shapeit"
})
