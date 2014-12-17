
#plink19 --bfile prepare_plink/hwe10e-4 --update-alleles reverse_allele/rev_alleles.list --make-bed --out prepare_plink/reversed_alleles

sh update_build.sh prepare_plink/hwe10e-4 HumanCoreExome-12v1-0_B-b37.strand prepare_plink/strandupdated 

