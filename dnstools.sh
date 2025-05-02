#!/usr/bin/env bash
# dnstools.sh - DNS Tools and Management Toolkit


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

function show_dns_settings() {
    echo "Current DNS settings:"
    cat /etc/resolv.conf
    pause
}

function configure_dns() {
    echo "Configuring DNS servers..."
    read -rp "Enter primary DNS server (e.g. 8.8.8.8): " primary_dns
    read -rp "Enter secondary DNS server (e.g. 8.8.4.4): " secondary_dns

    echo -e "nameserver $primary_dns\nnameserver $secondary_dns" > /etc/resolv.conf
    echo "DNS servers configured."
    pause
}

function check_dns_resolution() {
    read -rp "Enter domain name to resolve (e.g. google.com): " domain
    echo "Resolving $domain..."
    nslookup "$domain" || dig "$domain"
    pause
}

function test_dns_traceroute() {
    read -rp "Enter domain for DNS trace (e.g. google.com): " domain
    mtr --dns "$domain" || traceroute "$domain"
    pause
}

function flush_dns_cache() {
    echo "Flushing DNS cache..."
    if command -v systemd-resolve &>/dev/null; then
        systemd-resolve --flush-caches
    elif command -v nscd &>/dev/null; then
        service nscd restart
    elif command -v dnsmasq &>/dev/null; then
        systemctl restart dnsmasq
    else
        echo "DNS cache flush method not found."
    fi
    pause
}

function check_port_open_for_dns() {
    read -rp "Enter IP address or domain for DNS port check: " target
    nc -zv "$target" 53 || echo "DNS port 53 is closed or unreachable."
    pause
}

function test_dns_with_dig() {
    read -rp "Enter domain to query (e.g. google.com): " domain
    dig "$domain" || echo "Failed to query DNS for $domain."
    pause
}

function check_reverse_dns() {
    read -rp "Enter IP address for reverse DNS lookup: " ip
    host "$ip" || echo "Failed to resolve reverse DNS for $ip."
    pause
}

function show_iptables_dns_rules() {
    echo "Checking iptables for DNS-related rules..."
    iptables -L -v -n | grep "53" || echo "No DNS-related rules found."
    pause
}

function configure_local_dns_server() {
    echo "Configuring local DNS server (dnsmasq)..."
    read -rp "Enter the DNS interface (e.g. eth0): " iface
    read -rp "Enter DNS server address to forward (e.g. 8.8.8.8): " dns_server

    echo "interface=$iface" > /etc/dnsmasq.conf
    echo "server=$dns_server" >> /etc/dnsmasq.conf
    systemctl restart dnsmasq
    echo "Local DNS server configured."
    pause
}

function view_dns_cache() {
    echo "DNS cache (using nscd or dnsmasq):"
    if command -v nscd &>/dev/null; then
        nscd -g
    elif command -v dnsmasq &>/dev/null; then
        cat /var/cache/dnsmasq/*.log || echo "No DNS cache available."
    else
        echo "No DNS cache tools available."
    fi
    pause
}

function nslookup_multiple() {
    echo "Performing bulk DNS lookups..."
    read -rp "Enter domains (space-separated): " domains
    for domain in $domains; do
        nslookup "$domain"
    done
    pause
}

function check_dns_using_whois() {
    read -rp "Enter domain name to check DNS records (e.g. google.com): " domain
    whois "$domain" | grep -i "Name Server" || echo "No Name Server information found."
    pause
}

function show_menu() {
    clear
    echo "===== DNS Tools Admin Toolkit ====="
    echo "1) Show current DNS settings"
    echo "2) Configure DNS servers"
    echo "3) Check DNS resolution for domain"
    echo "4) Test DNS resolution with traceroute/mtr"
    echo "5) Flush DNS cache"
    echo "6) Check DNS port (53) status"
    echo "7) Test DNS with dig"
    echo "8) Reverse DNS lookup"
    echo "9) Show iptables DNS rules"
    echo "10) Configure local DNS server (dnsmasq)"
    echo "11) View DNS cache"
    echo "12) Bulk nslookup for multiple domains"
    echo "13) Check DNS using Whois"
    echo "14) Exit"
    echo "===================================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) show_dns_settings ;;
        2) configure_dns ;;
        3) check_dns_resolution ;;
        4) test_dns_traceroute ;;
        5) flush_dns_cache ;;
        6) check_port_open_for_dns ;;
        7) test_dns_with_dig ;;
        8) check_reverse_dns ;;
        9) show_iptables_dns_rules ;;
        10) configure_local_dns_server ;;
        11) view_dns_cache ;;
        12) nslookup_multiple ;;
        13) check_dns_using_whois ;;
        14) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
