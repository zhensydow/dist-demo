#!/bin/bash

FSTPORT=7866
HOST=`hostname`

echo RUN-SERVER $HOST $SLURM_LOCALID $((SLURM_LOCALID + FSTPORT))

~/.cabal/bin/demo-worksteal master $HOST $((SLURM_LOCALID + FSTPORT)) 1000
