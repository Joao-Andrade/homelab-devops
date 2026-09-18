#/bin/bash

# Variables

kubeconfig="$HOME/.kube/homelab_cluster01"
duration=3600 # 1 hour
step=600 # 10 minutes
current_step=1
start_time=`date +%s`
current_time=$start_time

echo "Start time: `date`"

while [ $(($current_time - $start_time)) -lt $duration ]; do
    echo "$((current_time - start_time)) seconds out of $duration seconds ($current_step/$((duration/step+1)))"
    kubectl top nodes --kubeconfig "$kubeconfig"
    sleep $step
    current_time=`date +%s`
    current_step=$((current_step + 1))
done

current_time=$((start_time + duration))

echo "Current time: `date`"
echo "Total time: $((current_time - start_time)) seconds"