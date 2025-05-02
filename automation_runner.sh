#!/usr/bin/env bash
# automation_runner.sh - Automation Runner for SysAdmin Tasks

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

function run_ansible_playbook() {
    read -rp "Enter the Ansible playbook path: " playbook_path
    ansible-playbook "$playbook_path"
    echo "Ansible playbook executed."
    pause
}

function run_chef_recipe() {
    read -rp "Enter the Chef recipe path: " recipe_path
    chef-client --local-mode "$recipe_path"
    echo "Chef recipe executed."
    pause
}

function automate_file_transfer() {
    echo "Choose file transfer method:"
    echo "1) SCP"
    echo "2) SFTP"
    echo "3) Rsync"
    read -rp "Choose an option: " transfer_method

    case "$transfer_method" in
        1) send_file_scp ;;
        2) send_file_sftp ;;
        3) send_file_rsync ;;
        *) echo "Invalid option."; pause ;;
    esac
}

function send_file_scp() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote user: " remote_user
    read -rp "Enter file to send (e.g., /path/to/file): " file_path
    read -rp "Enter remote path to send to (e.g., /remote/path/): " remote_path
    scp "$file_path" "$remote_user@$remote_host:$remote_path"
    echo "File sent via SCP."
    pause
}

function send_file_sftp() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote user: " remote_user
    read -rp "Enter file to send (e.g., /path/to/file): " file_path
    read -rp "Enter remote path to send to (e.g., /remote/path/): " remote_path
    sftp "$remote_user@$remote_host" <<EOF
put "$file_path" "$remote_path"
EOF
    echo "File sent via SFTP."
    pause
}

function send_file_rsync() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote user: " remote_user
    read -rp "Enter local file or directory path: " local_path
    read -rp "Enter remote destination path: " remote_path
    rsync -avz "$local_path" "$remote_user@$remote_host:$remote_path"
    echo "File(s) sent via rsync."
    pause
}

function run_system_diagnostics() {
    echo "Running system diagnostics..."
    # Network Tools
    netstat -tuln
    ping -c 4 google.com || echo "Network is down, unable to ping."
    traceroute google.com || echo "Unable to traceroute to google.com."
    
    # CPU, Memory, and Disk Usage
    iostat
    vmstat
    sar
    df -h
    
    # Firewall Status
    ufw status || echo "Firewall is not installed."
    iptables -L || echo "iptables not configured."
    
    # Network Interfaces
    ifconfig
    ip addr
    
    pause
}

function configure_firewall() {
    echo "Configuring firewall..."
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw enable
    echo "Firewall configured."
    pause
}

function configure_network() {
    echo "Configuring network settings..."
    nmcli device status
    read -rp "Enter interface to configure (e.g., eth0): " iface
    read -rp "Enter new IP address (e.g., 192.168.1.100): " ip_addr
    nmcli con mod "$iface" ipv4.addresses "$ip_addr/24"
    nmcli con up "$iface"
    echo "Network interface $iface configured."
    pause
}

function check_service_status() {
    read -rp "Enter service name (e.g., sshd): " service_name
    systemctl status "$service_name" || echo "$service_name is not running."
    pause
}

function run_script_remotely() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote user: " remote_user
    read -rp "Enter local script path to run remotely (e.g., /path/to/script.sh): " local_script
    scp "$local_script" "$remote_user@$remote_host:/tmp/"
    ssh "$remote_user@$remote_host" "bash /tmp/$(basename "$local_script")"
    echo "Script executed remotely."
    pause
}

function automate_software_installation() {
    echo "Choose a software installation method:"
    echo "1) Ansible"
    echo "2) Chef"
    read -rp "Choose an option: " install_method

    case "$install_method" in
        1) run_ansible_playbook ;;
        2) run_chef_recipe ;;
        *) echo "Invalid option."; pause ;;
    esac
}

function show_menu() {
    clear
    echo "===== Automation Runner Toolkit ====="
    echo "1) Run Ansible playbook"
    echo "2) Run Chef recipe"
    echo "3) Automate file transfer"
    echo "4) Run system diagnostics"
    echo "5) Configure firewall"
    echo "6) Configure network settings"
    echo "7) Check service status"
    echo "8) Run script remotely"
    echo "9) Automate software installation"
    echo "10) Exit"
    echo "====================================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) run_ansible_playbook ;;
        2) run_chef_recipe ;;
        3) automate_file_transfer ;;
        4) run_system_diagnostics ;;
        5) configure_firewall ;;
        6) configure_network ;;
        7) check_service_status ;;
        8) run_script_remotely ;;
        9) automate_software_installation ;;
        10) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
