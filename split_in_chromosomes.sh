INPUT_PLINK=$1

mkdir -p unphased

# Divide by chromosome
for i in `seq 1 23`
do
	plink --noweb --bfile  $INPUT_PLINK --chr $i --make-bed --out unphased/chr$i.unphased &
done
wait


