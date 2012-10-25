#!/bin/bash

NODES=$1
FSTPORT=7866
HOST=`hostname`

~/.cabal/bin/demo-worksteal master $HOST $((SLURM_LOCALID + FSTPORT)) "$NODES" 1000
