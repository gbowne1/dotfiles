#!/usr/bin/env bash
# firewall_admin.sh - Firewall Admin Toolkit
# This script provides a menu-driven interface for managing firewall rules
# using iptables and UFW, as well as network diagnostics and auditing.

set -euo pipefail
IFS=$'\n\t'

function pause() {
    read -rp "Press Enter to continue..."
}

function check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi
}

function show_iptables_rules() {
    echo "Current iptables rules:"
    iptables -L -v -n --line-numbers
    pause
}

function add_iptables_rule() {
    read -rp "Enter iptables rule (e.g. -A INPUT -p tcp --dport 22 -j ACCEPT): " rule
    iptables $rule
    echo "Rule added."
    pause
}

function delete_iptables_rule() {
    iptables -L --line-numbers
    read -rp "Enter chain (INPUT, OUTPUT, FORWARD): " chain
    read -rp "Enter rule number to delete: " num
    iptables -D "$chain" "$num"
    echo "Rule deleted."
    pause
}

function save_iptables_rules() {
    iptables-save > /etc/iptables.rules
    echo "Rules saved to /etc/iptables.rules"
    pause
}

function ufw_status() {
    ufw status verbose
    pause
}

function ufw_enable_disable() {
    read -rp "Do you want to enable or disable UFW? (enable/disable): " action
    ufw "$action"
    echo "UFW $action complete."
    pause
}

function ufw_add_rule() {
    read -rp "Enter rule (e.g. allow 22/tcp or deny from 192.168.0.0/16): " rule
    ufw $rule
    echo "Rule added."
    pause
}

function ufw_delete_rule() {
    ufw status numbered
    read -rp "Enter rule number to delete: " num
    ufw delete "$num"
    echo "Rule deleted."
    pause
}

function view_open_ports() {
    echo "Open ports (ss):"
    ss -tuln
    echo
    echo "Open ports (netstat):"
    netstat -tuln
    pause
}

function test_port() {
    read -rp "Enter host:port (e.g. 192.168.1.1 22): " host port
    nc -zv "$host" "$port" || echo "Connection failed or port closed."
    pause
}

function scan_with_nmap() {
    read -rp "Enter IP or subnet to scan: " target
    nmap -Pn "$target"
    pause
}

function firewall_audit_report() {
    echo "===== FIREWALL AUDIT ====="
    hostname
    echo
    echo "Interfaces:"
    ip addr show
    echo
    echo "ARP Table:"
    arp -a
    echo
    echo "Routing Table:"
    route -n
    echo
    echo "Open Ports:"
    ss -tuln
    echo
    echo "iptables Rules:"
    iptables -L -v -n
    echo
    echo "UFW Rules:"
    ufw status verbose
    pause
}

function run_ansible_chef_fw_check() {
    read -rp "Use Ansible or Chef? (ansible/chef): " tool
    case $tool in
        ansible)
            read -rp "Enter target host: " host
            ansible "$host" -m command -a "iptables -L -v -n"
            ;;
        chef)
            echo "Running chef-client firewall cookbook (requires setup)..."
            chef-client --once || echo "Chef not configured."
            ;;
        *)
            echo "Invalid tool."
            ;;
    esac
    pause
}

function show_menu() {
    clear
    echo "===== Firewall Admin Toolkit ====="
    echo "1) Show iptables rules"
    echo "2) Add iptables rule"
    echo "3) Delete iptables rule"
    echo "4) Save iptables rules"
    echo "5) Show UFW status"
    echo "6) Enable/Disable UFW"
    echo "7) Add UFW rule"
    echo "8) Delete UFW rule"
    echo "9) View open ports (ss/netstat)"
    echo "10) Test remote port with netcat"
    echo "11) Scan network with Nmap"
    echo "12) Firewall audit report"
    echo "13) Remote check with Ansible/Chef"
    echo "14) Exit"
    echo "==================================="
}

# Ensure running as root
check_root

while true; do
    show_menu
    read -rp "Choose an option: " choice
    case "$choice" in
        1) show_iptables_rules ;;
        2) add_iptables_rule ;;
        3) delete_iptables_rule ;;
        4) save_iptables_rules ;;
        5) ufw_status ;;
        6) ufw_enable_disable ;;
        7) ufw_add_rule ;;
        8) ufw_delete_rule ;;
        9) view_open_ports ;;
        10) test_port ;;
        11) scan_with_nmap ;;
        12) firewall_audit_report ;;
        13) run_ansible_chef_fw_check ;;
        14) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
