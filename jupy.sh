#!/bin/bash
: ${@?no positional parameters}
REMOTE=$1
SLURMFILE="./jupyter_submit.sh"
[ -d $SLURMFILE ] && rm $SLURMFILE
cat > $SLURMFILE <<EOF
#!/bin/bash
#SBATCH --job-name=JupiterNotebook
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=gpu
#SBATCH --constrain=xeon-e5
#SBATCH --gres=gpu:volta:1
#SBATCH --output=jupyter-%J.log

# Source env variables
source ~/.bashrc
#echo
#echo "============================== ENVIRONMENT VARIABLES ==============================="
#env
#echo "===================================================================================="
#echo

# Set stack size to unlimited
echo "Setting stack size to unlimited..."
ulimit -s unlimited
ulimit -l unlimited
ulimit -a
echo
# get tunneling info
XDG_RUNTIME_DIR=""
port=\$(shuf -i 6000-6999 -n1)
node=\$(hostname -s)
user=\$(whoami)

# print tunneling instructions jupyter-log
echo -e "ssh -N -L \${port}:\${node}:\${port} ${REMOTE}"

jupyter notebook  --no-browser --port=\${port} --ip="*"
EOF
echo "sending job file to the ${REMOTE}:~/"
scp $SLURMFILE ${REMOTE}:~/
LOCAL_LOG_FOLDER=".jupyter_logs"
[ ! -d $LOCAL_LOG_FOLDER ] && mkdir $LOCAL_LOG_FOLDER

echo "just wait for 1 minute"
ssh -T ${REMOTE} <<'ENDSSH'
      sbatch  jupyter_submit.sh  && sleep 1m
ENDSSH
echo "getting log files from ${REMOTE}:~/"
scp ${REMOTE}:~/jupyter*.log $LOCAL_LOG_FOLDER
cd $LOCAL_LOG_FOLDER
logfile=`ls -tp | grep -v /$ | head -1`
tunnel=`grep 'ssh -N' $logfile`
echo "creating the tunnel: $tunnel"
jlink=`grep -i 'http' $logfile | tail -n -1 | grep -o 'http.*'`
echo "You're ready! notebook is running on: $jlink"
eval $tunnel
