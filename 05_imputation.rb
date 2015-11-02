require_relative 'cfg.rb' 

$cfg.chromosomes.each
for chr in `seq 1 23`
do
        for script in sge/impute-chr.$chr.*
        do
		sbatch -p normal -n1 -c1 $script 
        done
done
