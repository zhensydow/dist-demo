#!/bin/bash

FSTPORT=7866
HOST=`hostname`

~/.cabal/bin/demo-worksteal master $HOST $((SLURM_LOCALID + FSTPORT)) 1000
