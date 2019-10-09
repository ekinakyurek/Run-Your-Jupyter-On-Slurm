# Run-Your-Jupyter-On-Slurm

This a single useful script to run a jupyter notebook on a compute node and get the link to connect from your local computer.

Just type below command and get your notebook working!

```shell
 sh jupy.sh hostname
```

You can also modify job configurations in the same file. Note that exiting from script does not terminate the job on the SLURM.

The script assumes that you have SSH Public Key Authentication to your login node (`hostname`), and you configure .ssh/known_hosts in your local computer.

If you job cannot be taken immediately ( ~60s) in your SLURM the script will fail.

Please feel free to make any improvement on the script via pull requests.
