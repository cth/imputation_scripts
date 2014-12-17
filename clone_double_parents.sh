INPUT_PLINK=$1
#../../update_ids/data/2014-01-20/update10.fam

clones=prepare_plink/double_parents
final=prepare_plink/merge_with_clones

rm -f double_parents_keeplist.txt
for par in `cat double_parents.txt`
do
	family=`cat $INPUT_PLINK.fam|grep $par|cut -d" " -f 1|head -n1`
	echo $family
	echo "$family $par" >> double_parents_keeplist.txt
done

plink --noweb --bfile  $INPUT_PLINK --keep double_parents_keeplist.txt --make-bed --out $clones


for par in `cat double_parents.txt`
do
	sed -i "s/$par/$par.clone/" $clones.fam
done

# Merge with original file
plink --noweb --bfile $INPUT_PLINK --bmerge $clones.bed $clones.bim $clones.fam --make-bed --out $final

# For each double parent, extract children and set one of them to have the clone as parent 
for par in `cat double_parents.txt`
do
	family=`cat $INPUT_PLINK.fam|grep $par|cut -d" " -f 1|head -n1`
	sed -i -e "0,/$family \([^ ]*\) \([^ ]*\) $par/s//$family \1 \2 $par.clone/" $final.fam 
done
