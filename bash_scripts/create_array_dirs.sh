#!/bin/bash
# searches through a directory (the first argument) for files with the .fastq extension.
# it then creates subdirectories in the second directory (second argument), with links
# to those pairs of fastqs.

indir=$1
outdir=$2

ind=0

# obtaining previxes matching pattern *R*.fastq
prefixes=`for fp in $indir/*.fastq
do
	echo $(basename ${fp%R*.fastq})
done | uniq`

# linking files to output dirs
for p in $prefixes
do
	if [ ${p: -1} = "_" ]
	then
		ptrim=${p::-1}
	else
		ptrim=$p
	fi

	subdir=$outdir/$ptrim
	mkdir -p $subdir
	for f in $indir/$p*
	do
		fn=`basename $f`
		ln -s `realpath $indir/$fn` $subdir/$fn
	done
done
