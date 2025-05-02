#!/usr/bin/env bash
# file_transfer.sh - File Transfer and Networking Toolkit


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

function test_connection() {
    read -rp "Enter remote host to test connectivity: " remote_host
    ping -c 4 "$remote_host" || echo "Ping failed. Unable to reach $remote_host."
    pause
}

function check_open_ports() {
    read -rp "Enter remote host to check open ports: " remote_host
    nmap "$remote_host" || echo "Failed to perform port scan on $remote_host."
    pause
}

function check_ftp_server() {
    read -rp "Enter FTP server address: " ftp_server
    nc -zv "$ftp_server" 21 || echo "FTP port 21 is closed on $ftp_server."
    pause
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

function receive_file_scp() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote user: " remote_user
    read -rp "Enter remote file path to receive (e.g., /remote/path/file): " remote_file_path
    read -rp "Enter local destination path (e.g., /local/path/): " local_path
    scp "$remote_user@$remote_host:$remote_file_path" "$local_path"
    echo "File received via SCP."
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

function receive_file_sftp() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote user: " remote_user
    read -rp "Enter remote file path to receive (e.g., /remote/path/file): " remote_file_path
    read -rp "Enter local destination path (e.g., /local/path/): " local_path
    sftp "$remote_user@$remote_host" <<EOF
get "$remote_file_path" "$local_path"
EOF
    echo "File received via SFTP."
    pause
}

function send_file_ftp() {
    read -rp "Enter FTP server address: " ftp_server
    read -rp "Enter FTP user: " ftp_user
    read -rsp "Enter FTP password: " ftp_password
    read -rp "Enter local file path (e.g., /local/path/file): " file_path
    read -rp "Enter remote FTP directory (e.g., /remote/path/): " remote_path
    ftp -n "$ftp_server" <<EOF
quote USER "$ftp_user"
quote PASS "$ftp_password"
binary
cd "$remote_path"
put "$file_path"
quit
EOF
    echo "File sent via FTP."
    pause
}

function receive_file_ftp() {
    read -rp "Enter FTP server address: " ftp_server
    read -rp "Enter FTP user: " ftp_user
    read -rsp "Enter FTP password: " ftp_password
    read -rp "Enter remote file path to receive (e.g., /remote/path/file): " remote_file_path
    read -rp "Enter local destination path (e.g., /local/path/): " local_path
    ftp -n "$ftp_server" <<EOF
quote USER "$ftp_user"
quote PASS "$ftp_password"
binary
cd "$(dirname "$remote_file_path")"
get "$(basename "$remote_file_path")" "$local_path"
quit
EOF
    echo "File received via FTP."
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

function receive_file_rsync() {
    read -rp "Enter remote host: " remote_host
    read -rp "Enter remote user: " remote_user
    read -rp "Enter remote file or directory path: " remote_path
    read -rp "Enter local destination path: " local_path
    rsync -avz "$remote_user@$remote_host:$remote_path" "$local_path"
    echo "File(s) received via rsync."
    pause
}

function test_transfer_speed() {
    read -rp "Enter remote host for transfer speed test: " remote_host
    read -rp "Enter remote path to test (e.g., /remote/path/): " remote_path
    echo "Testing transfer speed to $remote_host..."
    rsync --dry-run -avz "$remote_host:$remote_path" /tmp/test | tail -n 10
    pause
}

function show_menu() {
    clear
    echo "===== File Transfer Tools ====="
    echo "1) Test network connection (Ping)"
    echo "2) Check open ports on remote host"
    echo "3) Check FTP server availability"
    echo "4) Send file via SCP"
    echo "5) Receive file via SCP"
    echo "6) Send file via SFTP"
    echo "7) Receive file via SFTP"
    echo "8) Send file via FTP"
    echo "9) Receive file via FTP"
    echo "10) Send file via rsync"
    echo "11) Receive file via rsync"
    echo "12) Test transfer speed with rsync"
    echo "13) Exit"
    echo "==============================="
}

require_root

while true; do
    show_menu
    read -rp "Choose an option: " opt
    case "$opt" in
        1) test_connection ;;
        2) check_open_ports ;;
        3) check_ftp_server ;;
        4) send_file_scp ;;
        5) receive_file_scp ;;
        6) send_file_sftp ;;
        7) receive_file_sftp ;;
        8) send_file_ftp ;;
        9) receive_file_ftp ;;
        10) send_file_rsync ;;
        11) receive_file_rsync ;;
        12) test_transfer_speed ;;
        13) echo "Exiting."; exit 0 ;;
        *) echo "Invalid option."; pause ;;
    esac
done
