#!/bin/bash

# clean up after an old run
rm -f *sge
rm -f imputed/*

ruby chunked_imputation.rb 

for script in *sge
do
	qsub $script
done
