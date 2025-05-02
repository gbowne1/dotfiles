#!/usr/bin/env bash
# hostname.sh - Fully Featured Hostname Setup and Configuration Tool

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

function show_current_hostname() {
    echo "===== Current Hostname Information ====="
    hostname
    hostnamectl
    echo "DNS Resolution:"
    dig "$(hostname)" +short || true
    getent hosts "$(hostname)" || true
    pause
}

function set_new_hostname() {
    read -rp "Enter new hostname (short): " new_hostname
    hostnamectl set-hostname "$new_hostname"
    echo "Hostname updated to: $new_hostname"
    pause
}

function update_etc_hosts() {
    echo "===== Editing /etc/hosts ====="
    echo "Current /etc/hosts:"
    cat /etc/hosts
    read -rp "Enter IP address to map to hostname: " ip
    read -rp "Enter hostname to associate: " hostname
    echo "$ip    $hostname" >> /etc/hosts
    echo "Entry added."
    pause
}

function verify_dns_records() {
    read -rp "Enter hostname or FQDN to verify DNS: " fqdn
    echo "===== Verifying DNS for $fqdn ====="
    dig "$fqdn" +short
    nslookup "$fqdn"
    host "$fqdn"
    whois "$fqdn" | grep -Ei 'domain|name server|registrar'
    pause
}

function test_hostname_resolution() {
    read -rp "Enter hostname or IP to test: " target
    echo "Ping:"
    ping -c 4 "$target" || echo "Ping failed."
    echo "Traceroute:"
    traceroute "$target" || echo "Traceroute failed."
    mtr -rw "$target" || echo "MTR failed."
    pause
}

function restart_network_stack() {
    echo "Restarting networking to apply hostname changes..."
    systemctl restart NetworkManager || echo "NetworkManager restart failed."
    systemctl restart networking || echo "Legacy networking restart failed."
    pause
}

function remote_hostname_setup() {
    read -rp "Enter remote user@host: " remote
    read -rp "Enter new hostname to apply on remote: " remote_host
    ssh "$remote" "sudo hostnamectl set-hostname $remote_host && echo 'Remote hostname set to $remote_host'"
    pause
}

function ansible_hostname_setup() {
    read -rp "Enter inventory file path: " inv
    read -rp "Enter hostname variable value: " newhost
    ansible all -i "$inv" -m hostname -a "name=$newhost" --become
    pause
}

function chef_hostname_setup() {
    echo "Running Chef client to apply hostname via cookbook (assumes proper recipe exists)..."
    chef-client --runlist 'recipe[hostname::default]'
    pause
}

function edit_hostname_files_manually() {
    echo "===== Manual Editing ====="
    echo "You can now manually edit hostname-related files:"
    echo " - /etc/hostname"
    echo " - /etc/hosts"
    echo " - /etc/network/interfaces (if applicable)"
    pause
    nano /etc/hostname || true
    nano /etc/hosts || true
}

function show_menu() {
    clear
    echo "===== Hostname Setup & Configuration ====="
    echo "1) Show current hostname"
    echo "2) Set new hostname"
    echo "3) Update /etc/hosts"
    echo "4) Verify DNS records"
    echo "5) Test hostname/IP resolution (ping, traceroute, mtr)"
    echo "6) Restart network stack"
    echo "7) Configure hostname on remote server via SSH"
    echo "8) Configure hostname via Ansible"
    echo "9) Configure hostname via Chef"
    echo "10) Manually edit hostname files"
    echo "11) Exit"
    echo "=========================================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) show_current_hostname ;;
        2) set_new_hostname ;;
        3) update_etc_hosts ;;
        4) verify_dns_records ;;
        5) test_hostname_resolution ;;
        6) restart_network_stack ;;
        7) remote_hostname_setup ;;
        8) ansible_hostname_setup ;;
        9) chef_hostname_setup ;;
        10) edit_hostname_files_manually ;;
        11) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
