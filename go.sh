INPUT_PLINK=../../update_ids/data/2014-01-20/update10

bash clone_double_parents.sh $INPUT_PLINK
bash impute_qc.sh

# Reverse BOT swapped alleles
# I need to make sure that alleles are coded on ref strand and not plink major/minor
# I dont need to. It is plink major/minor. But, prephasing may need to  
bash fix_topbot.sh


bash split_in_chromosomes.sh prepare_plink/strandupdated
bash launch_shapeit.sh
