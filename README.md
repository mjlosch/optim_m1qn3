# optim_m1qn3
optimisation package for MITgcm based on m1qn3 with proper reverse communication
(code and documentation can be found here: https://who.rocq.inria.fr/Jean-Charles.Gilbert/modulopt/optimization-routines/m1qn3/m1qn3.html)

These are some basic instructions to an optimization of MITgcm/verification/tutorial_global_oce_optim with optim_m1qn3. Some tweaking is definitely possible and not described here.

```
cd MITgcm/verification
```

This is just to compile and run the model for testing. I use TAF (just because I have it and OpenAD is a pain to compile on a Mac), but that should not make any difference

```
./testreport -t tutorial_global_oce_optim -adm -j 4 -ncad
```

This is the result:

```
G D M    C  A  F
e p a R  o  d  D
n n k u  s  G  G
2 d e n  t  r  r
Y Y Y Y 15>16< 7 pass  tutorial_global_oce_optim  (e=0, w=2)
```

here is the cost function value that I get

```
(PID.TID 0000.0001)   local fc =  0.620023228182336D+01
(PID.TID 0000.0001)  global fc =  0.620023228182336D+01
```

now I download and compile optim_m1qn3

```
cd ../../
git clone https://github.com/mjlosch/optim_m1qn3.git
cd optim_m1qn3/src
```

Edit Makefile to adjust to your platform and compiler. It is important that you use the same compiler and compiler flags here as for compiling the MITgcm. This is important to ensure that the binary files written by the MITgcm are read correctly. For me this involves choosing the correct CPP command and setting SUFF=for (because I use MacOS and this is case-insensitive in my case), but you may want to check `tutorial_global_oce_optim/build/Makefile` to see, what compilers and options you actually used. Pay attention to the values of `FC` and `FFLAGS`; the optimization flags in `FOPTIM` are usually not important.

The file `src/Makefile.ARCHER` in this repository can be used to compile optim_m1qn3 on ARCHER, the UK national supercomputer.  

```
make depend
make
```

Then I get executable ```optim.x```

```
cd ../../MITgcm/verification/tutorial_global_oce_optim/run
cp ../../../../optim_m1qn3/src/optim.x .
```

Then:
- turn off the gradient check (in data.pkg: ```useGrdchk = .FALSE.```)
- tweak the namelist files data.ctrl and data.optim to the compiler needs (I need a ```/``` to terminate a namelist)
- I would replace fmin with dfminFrac = 0.1 (expected reduction of 10%) in ```data.optim&OPTIM``` to be independent of the absolute value of the  cost function. (Note: When you run ```./mitgcmuv_ad``` with code prior to Apr 12, 2019 with this you need to comment out ```dfminFrac```, because older versions of ```mitgcmuv_ad``` did not know about this namelist parameter.)
- set ```numiter=100```, ```nfunc=10```, or some other large value. ```nfunc*numiter``` is the number of simulations that are allowed in total. This number should be much larger than numiter, because you may need more than one function call (= run of mitgcmuv_ad) per iteration, see m1qn3 docs for details
- add an empty namelist &M1QN3 to data.optim

```
&M1QN3
/
```
Ready to run:

```./optim.x > opt0.txt ```

I get a lot of output in opt0.txt, which is easier to read with ```less -S opt0.out``` (to truncate long lines); essentially I have the same value for the cost function.

```
==================================================
Large Scale Optimization with off-line capability.
==================================================

OPTIM_READPARMS: Control options have been read.
OPTIM_READPARMS: Minimization options have been read.

OPTIM_READDATA: Reading cost function and gradient of cost function
                for optimization cycle:            0

OPTIM_READDATA: opened file ecco_cost_MIT_CE_000.opt0000
OPTIM_READDATA: nvartype            1
OPTIM_READDATA: nvarlength         2315
OPTIM_READDATA: yctrlid MIT_CE_000
OPTIM_READDATA: filenopt            0
OPTIM_READDATA: fileff    6.2002322818233591
OPTIM_READDATA: fileiG            1
OPTIM_READDATA: filejG            1
OPTIM_READDATA: filensx            2
OPTIM_READDATA: filensy            2
[...]
OPTIM_READDATA: end of optim_readdata


OPTIM_READPARMS: Iteration number =            0
number of control variables       =         2315
cost function value in ecco_ctrl  =    6.2002322818233591
expected cost function minimum    =    5.5802090536410232
expected cost function decrease   =   0.62002322818233591
Data will be read from the following file: ecco_ctrl_MIT_CE_000.opt0000

OPTIM_SUB: Calling m1qn3_optim for iteration:            0
OPTIM_SUB: with nn, REAL_BYTE =         2315           4
OPTIM_SUB: read model state

OPTIM_READDATA: Reading control vector
                for optimization cycle:            0

OPTIM_READDATA: opened file ecco_ctrl_MIT_CE_000.opt0000
OPTIM_READDATA: nvartype            1
OPTIM_READDATA: nvarlength         2315
OPTIM_READDATA: yctrlid MIT_CE_000
OPTIM_READDATA: filenopt            0
OPTIM_READDATA: fileff    6.2002322818233591
OPTIM_READDATA: fileiG            1
OPTIM_READDATA: filejG            1
OPTIM_READDATA: filensx            2
OPTIM_READDATA: filensy            2
OPTIM_READDATA: end of optim_readdata


OPTIM_READDATA: Reading cost function and gradient of cost function
                for optimization cycle:            0

OPTIM_READDATA: opened file ecco_cost_MIT_CE_000.opt0000
OPTIM_READDATA: nvartype            1
OPTIM_READDATA: nvarlength         2315
OPTIM_READDATA: yctrlid MIT_CE_000
OPTIM_READDATA: filenopt            0
OPTIM_READDATA: fileff    6.2002322818233591
OPTIM_READDATA: fileiG            1
OPTIM_READDATA: filejG            1
OPTIM_READDATA: filensx            2
OPTIM_READDATA: filensy            2
OPTIM_READDATA: end of optim_readdata

OPTIM_SUB after reading ecco_ctrl and ecco_cost:
OPTIM_SUB      nn =         2315
OPTIM_SUB    objf =    6.2002322818233591
OPTIM_SUB   xx(1) =    0.0000000000000000
OPTIM_SUB adxx(1) =   -6.7879882408306003E-005
OPTIM_SUB: cold start, optimcycle =           0
OPTIM_SUB: call m1qn3_offline ........
OPTIM_SUB: ...........................
OPTIM_SUB: returned from m1qn3_offline
OPTIM_SUB:      nn =         2315
OPTIM_SUB:   xx(1) =   0.51934864251896229       0.73000729032300782
OPTIM_SUB: adxx(1) =   -6.7879882408306003E-005  -9.5413379312958568E-005
OPTIM_SUB: omode   =           -1
OPTIM_SUB: niter   =            1
OPTIM_SUB: nsim    =        10000
OPTIM_SUB: reverse =            1

OPTIM_SUB: mean(xx) =  0.16365068483545642
OPTIM_SUB:  max(xx) =   4.6525355815045790
OPTIM_SUB:  min(xx) =  -9.3326211896764324
OPTIM_SUB:  std(xx) =   15.613450260548481


OPTIM_STORE_M1QN3: saving the state of m1qn3 in OPWARM.opt0001

OPTIM_SUB: writing         2315  sized control to file ecco_ctrl

OPTIM_WRITEDATA: Writing new control vector to file(s)
                 for optimization cycle:            1

OPTIM_WRITEDATA: nvartype              1
OPTIM_WRITEDATA: nvarlength         2315
OPTIM_WRITEDATA: yctrlid    MIT_CE_000
OPTIM_WRITEDATA: nopt                  1
OPTIM_WRITEDATA: ff           -9999.0000000000000
OPTIM_WRITEDATA: iG                    1
OPTIM_WRITEDATA: jG                    1
OPTIM_WRITEDATA: nsx                   2
OPTIM_WRITEDATA: nsy                   2
OPTIM_WRITEDATA: end of optim_writedata, icvoffset         2315


======================================
Large Scale Optimization run finished.
======================================
```

```ff = -9999``` is an intentional dummy value.

Now you can organize the rest in a loop. In bash, it could look like this:
first comment out ```dfminFrac```, if ```mitgcmuv_ad``` does not know about it (see above); ```dfminFrac``` is really only needed in the zeroth iteration.
```
# tabula rasa:
rm ecco_c* OPWARM.* m1qn3_output.txt
#
myiter=0
cat > data.optim <<EOF #
# ********************************
# Off-line optimization parameters
# ********************************
&OPTIM
 optimcycle=${myiter},
 numiter=10,
 nfunc=10,
 dfminFrac = 0.1,
 iprint=10,
 nupdate=8,
/

&M1QN3
/
EOF

while (( $myiter < 20 ))
do
    # formatter iteration count
    it=`echo $myiter | awk '{printf "%03i",$1}'`
    echo "iteration ${myiter}"
    # increment counter in data.optim
    sed -i .${it} "s/.*optimcycle.*/ optimcycle=${myiter},/" data.optim
    ./mitgcmuv_ad > output${it}.txt
    ./optim.x > opt${it}.txt
    m1qn3out=`grep "m1qn3: output mode" m1qn3_output.txt`
    if test "x${m1qn3out}" != x; then
	    echo "m1qn3 has finished"
	    break
    fi
    # increase counter for next iteration
    ((myiter++))
done
```

```grep "fc " output001.txt```
```
(PID.TID 0000.0001)   early fc =  0.000000000000000D+00
(PID.TID 0000.0001)   local fc =  0.132325873958879D+02
(PID.TID 0000.0001)  global fc =  0.132325873958879D+02
```

```grep "global fc " output???.txt```
```
output000.txt:(PID.TID 0000.0001)  global fc =  0.620023228182336D+01
output001.txt:(PID.TID 0000.0001)  global fc =  0.132325873958879D+02
output002.txt:(PID.TID 0000.0001)  global fc =  0.615567811433600D+01
output003.txt:(PID.TID 0000.0001)  global fc =  0.615556878869932D+01
output004.txt:(PID.TID 0000.0001)  global fc =  0.615547009131471D+01
```

As you can see, the improvement is not very good after the initial steps, and the optimization will not be successful in the end, i.e. satisfy the tolerance set by ```epsg```. This is likely because the number of timesteps in ```data``` is small (20) for this test. Try longer intergations (e.g. 1 year) and wait longer. Check out ```m1qn3_output.txt```, which records the output of m1qn3. The python script ```plotfc.py``` greps the cost function values out of ```m1qn3_ouput.txt``` and plots them and the number of simulations per iteration; the latter typically increases with decreasing cost function.
