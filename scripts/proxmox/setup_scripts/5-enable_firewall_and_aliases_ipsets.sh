#!/bin/bash

# This script enables firewall at datacenter and node levels.
# It also defines a few firewall configurations at datacenter level
# namely aliases and IPsets.

set -e

declare -A ALIASES=(
    ["minipc-physical-network-01"]="192.168.1.70"
    ["minipc-physical-network-02"]="192.168.1.71"
    ["home-network-01"]="192.168.1.0/24"
    ["lxc-network-01"]="192.168.1.80/28"
    ["vm-network-01"]="192.168.1.100/28"
    ["lxc-management-01"]="192.168.1.80"
    ["lxc-reverse-proxy-01"]="192.168.1.81"
)

declare -A IPSETS=(
    ["minipc-network"]="dc/minipc-physical-network-01 dc/minipc-physical-network-02"
    ["home-network"]="dc/home-network-01"
    ["lxc-network"]="dc/lxc-network-01"
    ["vm-network"]="dc/vm-network-01"
    ["management-nodes"]="dc/lxc-management-01"
    ["reverse-proxy"]="dc/lxc-reverse-proxy-01"
)

NODE="pve01"

# Enable firewall on datacenter and node levels
echo "Start firewall datacenter level"
pvesh set /cluster/firewall/options --enable 1
echo "Start firewall node $NODE level"
pvesh set /nodes/$NODE/firewall/options --enable 1

# Add aliases
for ALIAS in "${!ALIASES[@]}"; do
    CIDR="${ALIASES[$ALIAS]}"

    echo "Creating alias: $ALIAS -> $CIDR"

    pvesh create /cluster/firewall/aliases \
        --name "$ALIAS" \
        --cidr "$CIDR"
done

# Add IPsets
for IPSET in "${!IPSETS[@]}"; do

    echo "Creating IPSet: $IPSET"
    pvesh create /cluster/firewall/ipset \
        --name "$IPSET"
    
    # Add aliases to IP set
    for ALIAS in ${IPSETS[$IPSET]}; do
        echo "-Adding alias: $ALIAS"
        pvesh create "/cluster/firewall/ipset/$IPSET" \
            --cidr "$ALIAS"

    done
done