#!/bin/bash 
#

# a simple bash script that compiles two exectubales driver and offline_driver,
# runs thems to compare the output of optimizing simple test functions
# (defined in mysimul.F) between the original m1qn3 and the m1qn3_offline
# algorithms. This test is not foolproof as I missed at least one variable
# (moderl) that should have been stored offline and included in the common
# blocks of m1qn3_offline that replace the "save" statement in m1qn3.

m=7
cp driver.F driver.F_bak
cp offline_driver.F offline_driver.F_bak
cp model.F model.F_bak
sed 's/parameter (n = [0-9]*/parameter (n = '$m'/' driver.F_bak >| driver.F
sed 's/parameter (n = [0-9]*/parameter (n = '$m'/' offline_driver.F_bak >| offline_driver.F
sed 's/parameter (nn=[0-9]*/parameter (nn='$m'/' model.F_bak >| model.F

make scratch
make all

./driver

COUNTER=0
while [  $COUNTER -lt 1000 ]; do
    echo $COUNTER >| count.txt
    echo The counter is $COUNTER
    ./offline_driver >| output.txt
    cat output.txt
    stopper=`grep stoptheloop output.txt`
    if [ "${#stopper}" -gt 0 ]; then
     echo $stopper
     break
    fi
    ./model
    let COUNTER=COUNTER+1 
done

