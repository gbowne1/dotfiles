#!/usr/bin/env bash
# sysmon.sh - System Monitoring Toolkit

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

function show_system_info() {
    echo "===== System Info ====="
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "Kernel Version: $(uname -r)"
    echo "OS: $(lsb_release -d | cut -f2-)"
    echo "================================"
}

function monitor_network_usage() {
    echo "===== Network Usage ====="
    netstat -tuln
    ss -tuln
    ifconfig
    ip addr
    pause
}

function monitor_cpu_usage() {
    echo "===== CPU Usage ====="
    top -n 1 -b | grep "Cpu(s)"
    iostat -c
    vmstat 1 5
    sar -u 1 5
    pause
}

function monitor_memory_usage() {
    echo "===== Memory Usage ====="
    free -h
    vmstat -s
    sar -r 1 5
    pause
}

function monitor_disk_usage() {
    echo "===== Disk Usage ====="
    df -h
    iostat -d 1
    sar -d 1 5
    pause
}

function monitor_network_latency() {
    echo "===== Network Latency ====="
    ping -c 4 google.com || echo "Ping failed, no network."
    traceroute google.com || echo "Unable to traceroute."
    mtr -rw google.com || echo "MTR failed."
    pause
}

function monitor_firewall_status() {
    echo "===== Firewall Status ====="
    ufw status || echo "UFW not installed."
    iptables -L || echo "iptables not configured."
    pause
}

function monitor_services() {
    echo "===== Service Status ====="
    read -rp "Enter service name to check (e.g., sshd, apache2): " service_name
    systemctl status "$service_name" || echo "$service_name is not running."
    pause
}

function monitor_network_interfaces() {
    echo "===== Network Interfaces ====="
    ifconfig
    ip addr
    pause
}

function monitor_connections() {
    echo "===== Active Connections ====="
    netstat -tuln
    ss -tuln
    nmap localhost
    pause
}

function monitor_detailed_logs() {
    echo "===== System Logs ====="
    journalctl -xe
    tail -n 20 /var/log/syslog
    pause
}

function monitor_arp_cache() {
    echo "===== ARP Cache ====="
    arp -a
    pause
}

function monitor_processes() {
    echo "===== Process List ====="
    ps aux --sort=-%mem | head -n 20
    ps aux --sort=-%cpu | head -n 20
    pause
}

function monitor_system_stats() {
    echo "===== System Stats ====="
    vmstat 1 5
    iostat 1 5
    sar -u 1 5
    pause
}

function show_menu() {
    clear
    echo "===== System Monitoring Toolkit ====="
    echo "1) Show System Info"
    echo "2) Monitor Network Usage"
    echo "3) Monitor CPU Usage"
    echo "4) Monitor Memory Usage"
    echo "5) Monitor Disk Usage"
    echo "6) Monitor Network Latency"
    echo "7) Monitor Firewall Status"
    echo "8) Monitor Services"
    echo "9) Monitor Network Interfaces"
    echo "10) Monitor Active Connections"
    echo "11) Monitor System Logs"
    echo "12) Monitor ARP Cache"
    echo "13) Monitor Process List"
    echo "14) Monitor System Stats"
    echo "15) Exit"
    echo "===================================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) show_system_info ;;
        2) monitor_network_usage ;;
        3) monitor_cpu_usage ;;
        4) monitor_memory_usage ;;
        5) monitor_disk_usage ;;
        6) monitor_network_latency ;;
        7) monitor_firewall_status ;;
        8) monitor_services ;;
        9) monitor_network_interfaces ;;
        10) monitor_connections ;;
        11) monitor_detailed_logs ;;
        12) monitor_arp_cache ;;
        13) monitor_processes ;;
        14) monitor_system_stats ;;
        15) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
