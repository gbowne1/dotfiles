#!/usr/bin/env bash
# container_tools.sh - Container Admin & Diagnostic Toolkit
# This script provides various tools for managing and diagnosing container environments.
# It includes functions for listing containers, entering namespaces, inspecting network settings,
# managing firewall rules, monitoring resources, and transferring files.

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

function list_containers() {
    echo "Listing running containers (searching by namespaces)..."
    pgrep -a -f lxc-start || echo "No LXC containers found."
    echo "Looking for container namespaces using nsenter:"
    for pid in $(ls /proc | grep -E '^[0-9]+$'); do
        if [[ -d "/proc/$pid/ns" && -L "/proc/$pid/ns/pid" ]]; then
            ns_name=$(ls -l "/proc/$pid/ns/pid" 2>/dev/null | awk '{print $NF}')
            echo "PID $pid has namespace $ns_name"
        fi
    done
    pause
}

function enter_container_ns() {
    read -rp "Enter PID of container process to enter: " target_pid
    echo "Entering container namespace using nsenter..."
    nsenter --target "$target_pid" --mount --uts --ipc --net --pid bash || echo "Failed to enter namespace"
    pause
}

function inspect_container_net() {
    read -rp "Enter container PID to inspect network: " container_pid
    echo "Inspecting container network info..."
    nsenter -t "$container_pid" -n ip a
    nsenter -t "$container_pid" -n netstat -tuln
    pause
}

function inspect_container_sys() {
    read -rp "Enter container PID to inspect sysctl settings: " container_pid
    echo "Inspecting sysctl settings inside container..."
    nsenter -t "$container_pid" -m sysctl -a | grep -E 'net|kernel'
    pause
}

function manage_container_firewall() {
    echo "Container-level firewall (requires specific network setup)..."
    iptables -L -v -n
    echo "Use iptables or ufw manually for container bridge rules."
    pause
}

function monitor_container_resources() {
    read -rp "Enter container PID to monitor: " container_pid
    echo "Showing container resource usage..."
    top -p "$container_pid" -H -n 1
    echo "I/O stats (all):"
    iostat
    vmstat
    pause
}

function copy_file_to_container() {
    read -rp "Enter container name or target IP: " container_host
    read -rp "Enter username (e.g., root): " user
    read -rp "Enter local file path: " local_path
    read -rp "Enter destination path in container: " dest_path
    scp "$local_path" "$user@$container_host:$dest_path"
    echo "File transferred."
    pause
}

function run_remote_command_in_container() {
    read -rp "Enter container IP or hostname: " container_host
    read -rp "Enter username: " user
    read -rp "Enter command to run in container: " remote_cmd
    ssh "$user@$container_host" "$remote_cmd"
    pause
}

function show_menu() {
    clear
    echo "===== Container Tools Toolkit ====="
    echo "1) List Containers (via namespaces/processes)"
    echo "2) Enter Container Namespace"
    echo "3) Inspect Container Network"
    echo "4) Inspect Container Sysctl Config"
    echo "5) Manage Container Firewall Rules"
    echo "6) Monitor Container Resources"
    echo "7) Copy File to Container"
    echo "8) Run Remote Command in Container"
    echo "9) Exit"
    echo "==================================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) list_containers ;;
        2) enter_container_ns ;;
        3) inspect_container_net ;;
        4) inspect_container_sys ;;
        5) manage_container_firewall ;;
        6) monitor_container_resources ;;
        7) copy_file_to_container ;;
        8) run_remote_command_in_container ;;
        9) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
