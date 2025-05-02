#!/usr/bin/env bash
# sshtools.sh - SSH Tools and Management Toolkit

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

function check_ssh_status() {
    echo "Checking SSH service status..."
    systemctl status sshd || echo "sshd is not installed or running."
    pause
}

function restart_ssh_service() {
    echo "Restarting SSH service..."
    systemctl restart sshd
    echo "SSH service restarted."
    pause
}

function configure_ssh_port() {
    read -rp "Enter new SSH port (e.g., 2222): " new_port
    if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1 ] && [ "$new_port" -le 65535 ]; then
        sed -i "s/^#Port 22/Port $new_port/" /etc/ssh/sshd_config
        systemctl restart sshd
        echo "SSH port changed to $new_port."
    else
        echo "Invalid port number."
    fi
    pause
}

function configure_ssh_keys() {
    echo "Configuring SSH key-based authentication..."
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote username: " remote_user
    read -rp "Enter local private key path (default: ~/.ssh/id_rsa): " private_key
    private_key=${private_key:-~/.ssh/id_rsa}

    if [ -f "$private_key" ]; then
        ssh-copy-id -i "$private_key" "$remote_user@$remote_host"
        echo "SSH keys configured."
    else
        echo "Private key file not found."
    fi
    pause
}

function test_ssh_connection() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote username: " remote_user
    echo "Testing SSH connection to $remote_user@$remote_host..."
    ssh -v "$remote_user@$remote_host" || echo "Failed to connect to $remote_host."
    pause
}

function generate_ssh_key() {
    echo "Generating a new SSH key pair..."
    read -rp "Enter email for key (e.g., user@example.com): " email
    ssh-keygen -t rsa -b 4096 -C "$email"
    echo "SSH key pair generated."
    pause
}

function manage_ssh_agent() {
    echo "Managing SSH agent..."
    eval "$(ssh-agent -s)"
    read -rp "Enter the path to your private key to add to the agent (default: ~/.ssh/id_rsa): " key_path
    key_path=${key_path:-~/.ssh/id_rsa}
    ssh-add "$key_path"
    echo "Private key added to the SSH agent."
    pause
}

function check_open_ssh_ports() {
    echo "Checking for open SSH ports..."
    nmap -p 22 --open "$1" || echo "Failed to scan SSH ports."
    pause
}

function view_ssh_connections() {
    echo "Viewing active SSH connections..."
    ss -tuln | grep ":22" || echo "No active SSH connections."
    pause
}

function disable_root_login() {
    echo "Disabling root login via SSH..."
    sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Root login disabled."
    pause
}

function enable_ssh_password_authentication() {
    echo "Enabling SSH password authentication..."
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Password authentication enabled."
    pause
}

function disable_ssh_password_authentication() {
    echo "Disabling SSH password authentication..."
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Password authentication disabled."
    pause
}

function configure_iptables_for_ssh() {
    echo "Configuring iptables for SSH..."
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables-save > /etc/iptables/rules.v4
    echo "SSH port 22 allowed in iptables."
    pause
}

function test_ssh_with_scp() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote username: " remote_user
    read -rp "Enter file to transfer (e.g., /path/to/file): " file_path
    scp "$file_path" "$remote_user@$remote_host:/tmp"
    echo "File transferred via SCP."
    pause
}

function ssh_port_scan() {
    read -rp "Enter target IP or hostname: " target
    nmap -p 22 "$target" || echo "Failed to scan for SSH port."
    pause
}

function check_ssh_logs() {
    echo "Checking SSH logs..."
    tail -n 50 /var/log/auth.log | grep sshd || echo "No SSH logs found."
    pause
}

function view_system_ssh_config() {
    echo "Viewing current system SSH configuration..."
    cat /etc/ssh/sshd_config
    pause
}

function show_menu() {
    clear
    echo "===== SSH Tools Admin Toolkit ====="
    echo "1) Check SSH service status"
    echo "2) Restart SSH service"
    echo "3) Change SSH port"
    echo "4) Configure SSH key-based authentication"
    echo "5) Test SSH connection"
    echo "6) Generate new SSH key pair"
    echo "7) Manage SSH agent"
    echo "8) Check open SSH ports"
    echo "9) View active SSH connections"
    echo "10) Disable root login via SSH"
    echo "11) Enable SSH password authentication"
    echo "12) Disable SSH password authentication"
    echo "13) Configure iptables for SSH"
    echo "14) Test SSH connection with SCP"
    echo "15) SSH port scan with Nmap"
    echo "16) View SSH logs"
    echo "17) View system SSH configuration"
    echo "18) Exit"
    echo "===================================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) check_ssh_status ;;
        2) restart_ssh_service ;;
        3) configure_ssh_port ;;
        4) configure_ssh_keys ;;
        5) test_ssh_connection ;;
        6) generate_ssh_key ;;
        7) manage_ssh_agent ;;
        8) check_open_ssh_ports ;;
        9) view_ssh_connections ;;
        10) disable_root_login ;;
        11) enable_ssh_password_authentication ;;
        12) disable_ssh_password_authentication ;;
        13) configure_iptables_for_ssh ;;
        14) test_ssh_with_scp ;;
        15) ssh_port_scan ;;
        16) check_ssh_logs ;;
        17) view_system_ssh_config ;;
        18) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
