#!/usr/bin/env bash
# dhcp_tools.sh - DHCP Setup, Management, and Diagnostics

set -euo pipefail
IFS=$'\n\t'

function pause() {
    read -rp "Press Enter to continue..."
}

function require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi
}

function dhcp_client_status() {
    echo "===== DHCP Client Info ====="
    ip a
    dhclient -v
    nmcli device show | grep -i dhcp
    systemctl status NetworkManager || true
    pause
}

function renew_dhcp_lease() {
    read -rp "Enter interface (e.g., eth0): " iface
    echo "Releasing and renewing DHCP lease..."
    dhclient -r "$iface"
    dhclient "$iface"
    ip a show "$iface"
    pause
}

function configure_dnsmasq_server() {
    echo "===== Configuring dnsmasq (DHCP Server) ====="
    cat <<EOF > /etc/dnsmasq.d/dhcp.conf
interface=eth0
dhcp-range=192.168.50.10,192.168.50.100,12h
EOF
    echo "dnsmasq DHCP config written to /etc/dnsmasq.d/dhcp.conf"
    systemctl restart dnsmasq
    systemctl enable dnsmasq
    pause
}

function test_dhcp_with_nmap() {
    echo "===== Scanning Local Network for DHCP Clients ====="
    read -rp "Enter subnet to scan (e.g., 192.168.50.0/24): " subnet
    nmap -sP "$subnet"
    pause
}

function show_iptables_dhcp_rules() {
    echo "===== iptables Rules Related to DHCP ====="
    iptables -L -v -n | grep -Ei '67|68|dhcp' || echo "No explicit DHCP rules found."
    pause
}

function dnsmasq_logs() {
    echo "===== dnsmasq Logs ====="
    journalctl -u dnsmasq --no-pager | tail -n 50
    pause
}

function show_lease_info() {
    echo "===== DHCP Lease Info ====="
    ls /var/lib/dhcp/ || echo "No DHCP leases found."
    cat /var/lib/dhcp/* 2>/dev/null || echo "Cannot read lease files."
    pause
}

function advanced_tools() {
    echo "===== Advanced Tools Output ====="
    echo "Interfaces:"
    ip link
    ifconfig
    echo "Routing table:"
    route -n
    echo "ARP table:"
    arp -a
    echo "System info:"
    sysctl -a | grep net.ipv4.conf
    vmstat
    iostat
    sar -n DEV 1 3 || echo "sar not available or not running."
    pause
}

function ansible_dhcp_setup() {
    read -rp "Enter Ansible inventory path: " inv
    ansible all -i "$inv" -m apt -a "name=dnsmasq state=latest" --become
    ansible all -i "$inv" -m copy -a "src=./dhcp.conf dest=/etc/dnsmasq.d/dhcp.conf" --become
    ansible all -i "$inv" -m service -a "name=dnsmasq state=restarted" --become
    pause
}

function chef_dhcp_setup() {
    echo "Running Chef recipe (assumes dnsmasq setup)..."
