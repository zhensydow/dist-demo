#!/bin/bash

FSTPORT=7766
HOST=`hostname`

~/.cabal/bin/demo-worksteal slave $HOST $((SLURM_LOCALID + FSTPORT))
