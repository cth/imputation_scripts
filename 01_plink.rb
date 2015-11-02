# Settings:
require 'configuration.rb' 
require 'include/queue_runner.rb'


plink="../common/software/plink"

# make folders:
`mkdir -p plink`
`mkdir -p phasing/unphased`
`mkdir -p phasing/phased`
`mkdir -p sge`
`mkdir -p imputed`
`mkdir -p VCFs` 

# QC pruning 
script="sge/hweprune.sge"
File.open("sge/hweprune.sge", "w") do |f|
	f.puts "#!/bin/bash" 
	f.puts "#{plink}} --bfile ../b37/strandup --allow-extra-chr --maf 0.01 --mind 0.05 --geno 0.05 --hwe 0.000001 --make-bed --out plink/all_hwe10e_maf001_geno005"
end

`sbatch -p normal -n1 -c1 $script`
