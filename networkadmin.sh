#!/usr/bin/env bash
# network_diag.sh - Network Diagnostics Toolkit

set -euo pipefail
IFS=$'\n\t'

# Ensure root for certain commands
function require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This option requires root privileges."
        exit 1
    fi
}

function pause() {
    read -rp "Press Enter to continue..."
}

function check_connectivity() {
    read -rp "Enter host (IP or domain): " host
    echo "Pinging $host..."
    ping -c 4 "$host"
    echo
    echo "Running traceroute..."
    traceroute "$host"
    echo
    echo "Running mtr..."
    mtr --report "$host"
    echo
    echo "Running dig..."
    dig "$host"
    echo
    echo "Running nslookup..."
    nslookup "$host"
    echo
    echo "Running whois..."
    whois "$host"
    pause
}

function local_interface_info() {
    echo "Displaying interface information..."
    ip addr
    echo
    ifconfig -a || echo "ifconfig not found"
    echo
    nmcli device show || echo "nmcli not available"
    echo
    iwconfig 2>/dev/null || echo "iwconfig not available or no wireless interfaces"
    echo
    echo "Route table:"
    route -n
    echo
    ip route show
    pause
}

function dns_status() {
    echo "Checking DNS servers..."
    cat /etc/resolv.conf
    echo
    echo "Testing with dnsmasq (if running)..."
    systemctl status dnsmasq || echo "dnsmasq service not found"
    pause
}

function arp_info() {
    echo "Current ARP table:"
    arp -a
    pause
}

function socket_and_port_info() {
    echo "Showing open TCP/UDP ports..."
    ss -tulnp
    echo
    netstat -tulnp || echo "netstat not found"
    echo
    echo "Testing port connectivity with netcat"
    read -rp "Enter host:port (e.g. google.com 80): " host port
    nc -zv "$host" "$port" || echo "Connection failed"
    pause
}

function scan_remote_host() {
    read -rp "Enter IP or hostname to scan: " target
    echo "Running Nmap scan..."
    nmap -sS -Pn "$target"
    pause
}

function test_file_transfer() {
    read -rp "Test SCP or rsync? (scp/rsync): " method
    read -rp "Enter remote user@host:path: " remote
    read -rp "Enter local file to send: " file
    case $method in
        scp) scp "$file" "$remote" ;;
        rsync) rsync -avz "$file" "$remote" ;;
        *) echo "Invalid option";;
    esac
    pause
}

function dhcp_and_ethtool() {
    echo "Running DHCP client renewal..."
    dhclient -v || echo "dhclient failed"
    echo
    echo "Displaying ethtool data for eth0 (change interface if needed)..."
    ethtool eth0 || echo "ethtool failed or eth0 not found"
    pause
}

function ssh_check() {
    echo "Checking SSH service..."
    systemctl status sshd || echo "sshd not found"
    echo
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)"
    pause
}

function rpc_services() {
    echo "Listing RPC services (portmapper)..."
    rpcinfo -p || echo "rpcinfo not found"
    pause
}

function run_ansible_or_chef_ping() {
    echo "Testing Ansible/Chef connectivity..."
    read -rp "Use (ansible/chef): " choice
    case $choice in
        ansible)
            read -rp "Enter host to ping via Ansible: " ansible_host
            ansible "$ansible_host" -m ping
            ;;
        chef)
            echo "Running Chef client..."
            chef-client --once || echo "Chef client not configured"
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
    pause
}

function show_menu() {
    clear
    echo "===== Network Diagnostics Toolkit ====="
    echo "1) Check Connectivity (ping, traceroute, mtr, dig)"
    echo "2) Interface & IP Info (ip, ifconfig, nmcli)"
    echo "3) DNS Info (resolv.conf, dnsmasq)"
    echo "4) ARP Table"
    echo "5) Open Ports & Socket Info (ss, netstat, nc)"
    echo "6) Nmap Scan"
    echo "7) Test File Transfer (scp/rsync)"
    echo "8) DHCP Renew & Ethtool"
    echo "9) SSH Check (sshd, ssh-agent)"
    echo "10) RPC Service Check"
    echo "11) Ansible/Chef Connectivity"
    echo "12) Exit"
    echo "======================================="
}

while true; do
    show_menu
    read -rp "Select an option: " opt
    case $opt in
        1) check_connectivity ;;
        2) local_interface_info ;;
        3) dns_status ;;
        4) arp_info ;;
        5) socket_and_port_info ;;
        6) scan_remote_host ;;
        7) test_file_transfer ;;
        8) dhcp_and_ethtool ;;
        9) ssh_check ;;
        10) rpc_services ;;
        11) run_ansible_or_chef_ping ;;
        12) echo "Exiting."; exit 0 ;;
        *) echo "Invalid choice." ;;
    esac
done
