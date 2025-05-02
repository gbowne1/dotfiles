#!/usr/bin/env bash
# routing_tools.sh - Routing Setup and Configuration Script

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

function show_current_routes() {
    echo "===== IPv4 Routing Table ====="
    ip route
    echo
    echo "===== Legacy (route) Table ====="
    route -n
    echo
    echo "===== IPv6 Routing Table ====="
    ip -6 route
    pause
}

function add_static_route() {
    read -rp "Destination network (e.g., 192.168.1.0/24): " net
    read -rp "Gateway IP (e.g., 192.168.1.1): " gw
    read -rp "Interface (e.g., eth0): " iface
    ip route add "$net" via "$gw" dev "$iface"
    echo "Route added."
    pause
}

function delete_route() {
    read -rp "Destination network to delete: " net
    ip route delete "$net"
    echo "Route deleted."
    pause
}

function show_interfaces() {
    ip addr
    ifconfig
    nmcli device status
    pause
}

function test_connectivity() {
    read -rp "Target IP or hostname: " target
    ping -c 4 "$target" || echo "Ping failed"
    mtr -rw "$target" || echo "MTR failed"
    traceroute "$target" || echo "Traceroute failed"
    pause
}

function configure_iptables_routing() {
    echo "===== IP Forwarding & NAT ====="
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    echo "Enabled IP forwarding and added basic NAT rule."
    pause
}

function view_firewall_rules() {
    echo "===== Firewall Rules ====="
    iptables -L -n -v
    ufw status verbose || true
    pause
}

function use_tc_for_qos() {
    echo "===== Traffic Control (tc) ====="
    tc qdisc show
    pause
}

function show_network_diagnostics() {
    ss -tulwn
    netstat -rn
    lsof -i
    fuser -vn tcp 22
    arp -a
    pause
}

function ansible_route_config() {
    read -rp "Enter Ansible inventory path: " inv
    read -rp "Enter static route (e.g., 192.168.2.0/24 via 192.168.1.1): " route_cmd
    ansible all -i "$inv" -m shell -a "ip route add $route_cmd" --become
    pause
}

function chef_route_config() {
    echo "Running Chef recipe for route management..."
    chef-client --runlist 'recipe[routing::default]'
    pause
}

function view_kernel_network_config() {
    echo "===== Kernel IP Stack Settings ====="
    sysctl -a | grep net.ipv4.conf
    pause
}

function remote_route_config() {
    read -rp "Enter user@host: " remote
    read -rp "Enter route (e.g., 192.168.100.0/24 via 10.0.0.1): " route_str
    ssh "$remote" "sudo ip route add $route_str"
    echo "Route configured remotely on $remote."
    pause
}

function show_menu() {
    clear
    echo "========== Routing Tools Menu =========="
    echo "1) Show current routing tables"
    echo "2) Add static route"
    echo "3) Delete route"
    echo "4) Show interface info"
    echo "5) Test network connectivity"
    echo "6) Enable IP forwarding and NAT (iptables)"
    echo "7) Show firewall rules"
    echo "8) View traffic control (tc) settings"
    echo "9) General network diagnostics"
    echo "10) Configure route via Ansible"
    echo "11) Configure route via Chef"
    echo "12) Configure route remotely via SSH"
    echo "13) View kernel network stack config"
    echo "14) Exit"
    echo "========================================"
}

require_root

while true; do
    show_menu
    read -rp "Select an option: " opt
    case "$opt" in
        1) show_current_routes ;;
        2) add_static_route ;;
        3) delete_route ;;
        4) show_interfaces ;;
        5) test_connectivity ;;
        6) configure_iptables_routing ;;
        7) view_firewall_rules ;;
        8) use_tc_for_qos ;;
        9) show_network_diagnostics ;;
        10) ansible_route_config ;;
        11) chef_route_config ;;
        12) remote_route_config ;;
        13) view_kernel_network_config ;;
        14) echo "Exiting."; exit 0 ;;
        *) echo "Invalid selection"; pause ;;
    esac
done
