#!/usr/bin/env bash
# interfaceadmin.sh - Network Interface Admin Toolkit
# Bash 5.0.0 to 5.2.x compatible

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

function list_interfaces() {
    echo "Available interfaces:"
    ip link show
    echo
    nmcli device status
    echo
    ifconfig -a || echo "ifconfig not available"
    pause
}

function bring_up_interface() {
    read -rp "Enter interface to bring UP: " iface
    ifup "$iface" || ip link set "$iface" up || echo "Failed to bring up $iface"
    pause
}

function bring_down_interface() {
    read -rp "Enter interface to bring DOWN: " iface
    ifdown "$iface" || ip link set "$iface" down || echo "Failed to bring down $iface"
    pause
}

function set_static_ip() {
    read -rp "Enter interface name: " iface
    read -rp "Enter IP address (e.g. 192.168.1.100/24): " ipaddr
    read -rp "Enter gateway (optional): " gw
    ip addr flush dev "$iface"
    ip addr add "$ipaddr" dev "$iface"
    ip link set "$iface" up
    [[ -n "$gw" ]] && ip route add default via "$gw" dev "$iface"
    echo "Static IP configured."
    pause
}

function get_dhcp_ip() {
    read -rp "Enter interface to request DHCP on: " iface
    dhclient -v "$iface"
    pause
}

function show_interface_stats() {
    echo "Interface statistics:"
    for iface in $(ls /sys/class/net); do
        echo "[$iface]"
        cat /sys/class/net/"$iface"/statistics/* | paste - - - - - - - - - -
    done
    pause
}

function wifi_tools() {
    echo "Wireless interface check:"
    iwconfig 2>/dev/null || echo "No wireless interfaces or iwconfig not installed"
    pause
}

function ethtool_diag() {
    read -rp "Enter Ethernet interface: " iface
    ethtool "$iface" || echo "ethtool failed or interface not found"
    pause
}

function set_hostname() {
    read -rp "Enter new hostname: " newhost
    hostnamectl set-hostname "$newhost"
    echo "Hostname set to $newhost"
    pause
}

function use_nmtui() {
    echo "Launching NetworkManager TUI..."
    nmtui
}

function configure_mac_address() {
    read -rp "Enter interface: " iface
    read -rp "Enter new MAC address (e.g. 00:11:22:33:44:55): " mac
    ip link set dev "$iface" down
    ip link set dev "$iface" address "$mac"
    ip link set dev "$iface" up
    echo "MAC address changed."
    pause
}

function sysctl_net_config() {
    echo "Kernel network settings:"
    sysctl -a | grep net.
    pause
}

function interface_audit_report() {
    echo "===== INTERFACE AUDIT ====="
    hostnamectl
    echo
    echo "Interfaces:"
    ip addr
    echo
    echo "Routing Table:"
    ip route show
    echo
    echo "ARP Table:"
    arp -a
    echo
    echo "Netstat Summary:"
    netstat -i
    echo
    echo "DHCP leases (if available):"
    ls /var/lib/dhcp/ || echo "No DHCP lease files"
    echo
    echo "Loaded network kernel modules:"
    lsmod | grep -E 'e1000|ixgbe|r8169|iwlwifi|ath9k'
    echo
    echo "sysctl net config:"
    sysctl -a | grep ^net.
    pause
}

function show_menu() {
    clear
    echo "===== Interface Admin Toolkit ====="
    echo "1) List network interfaces"
    echo "2) Bring UP an interface"
    echo "3) Bring DOWN an interface"
    echo "4) Set static IP on interface"
    echo "5) Request IP via DHCP"
    echo "6) View interface stats"
    echo "7) Wireless (iwconfig) check"
    echo "8) Ethernet diagnostics (ethtool)"
    echo "9) Change system hostname"
    echo "10) Use NetworkManager TUI (nmtui)"
    echo "11) Change MAC address"
    echo "12) View kernel net settings (sysctl)"
    echo "13) Interface audit report"
    echo "14) Exit"
    echo "===================================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) list_interfaces ;;
        2) bring_up_interface ;;
        3) bring_down_interface ;;
        4) set_static_ip ;;
        5) get_dhcp_ip ;;
        6) show_interface_stats ;;
        7) wifi_tools ;;
        8) ethtool_diag ;;
        9) set_hostname ;;
        10) use_nmtui ;;
        11) configure_mac_address ;;
        12) sysctl_net_config ;;
        13) interface_audit_report ;;
        14) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
