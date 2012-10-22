#!/bin/bash

FSTPORT=7766
HOST=`hostname`

echo RUN-CLIENT $HOST $SLURM_LOCALID $((SLURM_LOCALID + FSTPORT))

~/.cabal/bin/demo-worksteal slave $HOST $((SLURM_LOCALID + FSTPORT))
