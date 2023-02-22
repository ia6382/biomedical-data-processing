#!/bin/bash

###########################################################
#                                                         #
# Wrapper for evaluation of QRS detectnion Matlab program #
#                                                         #
###########################################################

#rm eval1.txt
#rm eval2.txt
FILES=./*.dat

#Run algorithm in Matlab. Output should be annotations in text files
#with WFDB annotator structure. See Matlab frame on the webclassroom.

for f in $FILES
do
    f=$(basename $f)
    f=${f%.*}
    
    echo $f

    #convert text annotator to WFDB format
    wrann -r $f -a dat < $f".asc"
    #evaluate using reference annotations atr and your .det files
    bxb -r $f -a atr dat -l eval1.txt eval2.txt
done

sumstats eval1.txt eval2.txt > results.txt #final statistics
#Now you can copy average Se and +P from results.txt