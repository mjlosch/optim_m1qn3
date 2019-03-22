#!/usr/bin/env python
# -*- coding: iso-8859-15 -*-
######################## -*- coding: utf-8 -*-
"""Usage: plotfc.py INPUTFILE
Simple script to visualize output of m1qn3 with omode>0 as saved in INPUTFILE.
The script plots the cost function value minus the final (smallest) value
and the number of simulations as a function of iterations.
"""
import matplotlib.pyplot as plt
import numpy as np
import sys
from getopt import gnu_getopt as getopt
# parse command-line arguments
try:
    optlist,args = getopt(sys.argv[1:], ':', ['verbose'])
    assert len(args) == 1
except (AssertionError):
    sys.exit(__doc__)

fname=args[0]
print("reading from "+fname)

def get_output (fname, mystring):
    """parse fname and get some numbers out"""
    iters = []
    simuls= []
    fc    = []
    try:
        f=open(fname)
    except:
        print(fname + " does not exist, continuing")
    else:
        for line in f:
            if mystring in line: 
                ll = line.split()
                iters.append( int(ll[2].replace(',','')))
                simuls.append(int(ll[4].replace(',','')))
                fc.append(  float(ll[6].replace('D','e').replace(',','')))

    return iters, simuls, fc

iters, simuls, fc = get_output(fname, "f=")
# sort out restarts
iters0 = np.asarray(iters)
for k,it in enumerate(iters[1:]):
    kp1=k+1
    if iters0[kp1]<iters0[kp1-1]:
        iters0[kp1:] = iters0[kp1:]+(iters0[k]-iters0[kp1]+1)
        
fig, ax1 = plt.subplots()
ax1.semilogy(iters0,(np.asarray(fc)-fc[-1]),'bx-')
ax1.set_xlabel('iterations')
ax1.set_ylabel('fc-min(fc)', color='b')
ax1.tick_params('y', colors='b')
ax1.grid()

ax2 = ax1.twinx()
ax2.plot(iters0,simuls, 'r.')
ax2.set_ylabel('# simulations', color='r')
ax2.tick_params('y', colors='r')

plt.show()
