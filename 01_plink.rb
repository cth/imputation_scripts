# Settings:
require_relative 'cfg.rb'
require_relative 'lib/utils.rb'

# make folders:
`mkdir -p plink`
`mkdir -p phasing/unphased`
`mkdir -p phasing/phased`
`mkdir -p sge`
`mkdir -p imputed`
`mkdir -p VCFs` 


qc_opts=({ :maf => $cfg.QC_maf, :mind => $cfg.QC_mind, :geno => $cfg.QC_geno, :hwe => $cfg.QC_hwe })

# QC pruning 
script="sge/plinkqc.sge"

File.open(script, "w") do |f|
	f.puts "#!/bin/bash" 
	f.puts "#\$ -S /bin/bash"
	f.puts "#\$ -cwd"
	f.puts "#{$cfg.plink} --bfile #{$cfg.input_plink} --allow-extra-chr #{hash_param_longopt(qc_opts)} --make-bed --out plink/qc-#{hash_param_str(qc_opts)}"
end

`qsub #{script}`
#`sbatch -p normal -n1 -c1 $script`
