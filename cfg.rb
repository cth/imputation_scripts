require 'include/configuration.rb'

$cfg = CNF_1000GP_Phase3_b37.new({

	# These are the chromosomes to be analyzed 
	"chromosomes" => (1..22).to_a,


	# Where the imputation panel resides
	"panel_dir" => "#{`pwd`}/../1000GP_Phase3_b7",

	"shapeit" => "../common/software/shapeit",
	"shapeit_threads" => 16
})

