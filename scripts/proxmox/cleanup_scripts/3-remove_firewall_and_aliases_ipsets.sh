#!/bin/bash

# This script removes firewall at datacenter and node levels.
# It also removes a few firewall configurations at datacenter level
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
    ["reverse-proxy-nodes"]="dc/lxc-reverse-proxy-01"
)

NODE="pve01"

# IPsets
for IPSET in "${!IPSETS[@]}"; do

    echo "IPSet: $IPSET"
    # Add aliases to IP set
    for ALIAS in ${IPSETS[$IPSET]}; do
        echo "-Deleting alias: $ALIAS"
        pvesh delete "/cluster/firewall/ipset/$IPSET/$ALIAS"

    done

    echo "Delete IPSet: $IPSET"
    pvesh delete "/cluster/firewall/ipset/$IPSET"
done

# Aliases
for ALIAS in "${!ALIASES[@]}"; do
    CIDR="${ALIASES[$ALIAS]}"

    echo "Delete alias: $ALIAS -> $CIDR"
    pvesh delete "/cluster/firewall/aliases/$ALIAS"
done

# firewall on datacenter and node levels
echo "Removing firewall datacenter level"
pvesh set /cluster/firewall/options --enable 0
echo "Removing firewall node $NODE level"
pvesh set /nodes/$NODE/firewall/options --enable 0
