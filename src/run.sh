#!/bin/bash
# tabula rasa:
rm ecco_c* OPWARM.* m1qn3_output.txt
rm data.optim*
#
myiter=0
nIter=10
nSim=10
cat > data.optim <<EOF #
# ********************************
# Off-line optimization parameters
# ********************************
&OPTIM
 optimcycle=$myiter,
 numiter=$nIter,
 nfunc=$nSim,
 dfminFrac = 0.1,
 iprint=10,
 nupdate=8,
/

&M1QN3
/
EOF

# this could also be a copy
ln -s ~/MITgcm/optim_m1qn3/src/optim.x
# allow one extra iteration/simulation so that m1qn3 can finish with a
# proper exit mode
nn=$(( $nIter*$nSim + 1 ))
while (( $myiter < $nn ))
do
    # formatter iteration count
    it=`echo $myiter | awk '{printf "%03i",$1}'`
    echo "iteration ${myiter}"
    # increment counter in data.optim
    sed -i .${it} "s/.*optimcycle.*/ optimcycle=${myiter},/" data.optim
    # run the model
    ./mitgcmuv_ad > output${it}.txt
    # report cost function value
    grep "global fc " output${it}.txt
    # run optimizer
    ./optim.x > opt${it}.txt
    m1qn3out=`grep "m1qn3: output mode" m1qn3_output.txt`
    if test "x${m1qn3out}" != x; then
	    echo "m1qn3 has finished"
	    break
    fi
    # increase counter for next iteration
   ((myiter++))
done

# comment in for a summary of all cost function values after the optimization
#grep fc costfunction* | awk '{print $1, $2, $3}'
