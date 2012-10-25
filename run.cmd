#!/bin/bash
#@ job_name = cloud_haskell
#@ initialdir = .
#@ output = cloud_haskell_%j.out
#@ error = cloud_haskell_%j.err
#@ total_tasks = 32
#@ wall_clock_limit = 1:00:00

echo Running on $SLURM_NODELIST

date

srun --exclusive -c1 -n$((SLURM_NTASKS-1)) run-client.sh &

sleep 30

srun --exclusive -c1 -n1 run-server.sh

sleep 10

date
