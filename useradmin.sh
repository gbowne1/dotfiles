#!/bin/bash

LOG_FILE="/var/log/user_group_mgmt.log"

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    if [[ -w "$LOG_FILE" || ! -e "$LOG_FILE" ]]; then
        echo "$timestamp [$level] $message" >> "$LOG_FILE"
    else
        logger "$message"
    fi
}

# Function to validate username
function validateUsername() {
    local username="$1"
    if ! [[ $username =~ ^[a-zA-Z0-9_-]{3,32}$ ]]; then
        echo "Invalid username. Only alphanumeric characters, underscores, and hyphens are allowed."
        log "ERROR" "Invalid username attempt: $username"
        return 1
    fi
    return 0
}

# Function to validate group name
function validateGroupName() {
    local groupName="$1"
    if ! [[ $groupName =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid group name. Only alphanumeric characters, underscores, and hyphens are allowed."
        log "ERROR" "Invalid group name attempt: $groupName"
        return 1
    fi
    return 0
}

# Function to securely handle password input with confirmation
function setPassword() {
    local username=$1
    local password
    while true; do
        read -sp "Enter password for $username: " password
        echo
        read -sp "Confirm password: " confirm
        echo
        if [[ "$password" == "$confirm" ]]; then
            if [[ ! $password =~ [A-Z] || ! $password =~ [a-z] || ! $password =~ [0-9] ]]; then
                echo "Password must contain at least one uppercase, lowercase letter, and a digit."
                continue
            fi
            if [[ ${#password} -lt 12 ]]; then
                echo "Password too short. Must be at least 12 characters."
                continue
            fi
            echo "$username:$password" | sudo chpasswd
            if [[ $? -eq 0 ]]; then
                log "INFO" "Password set for user $username"
                return 0
            else
                echo "Failed to set password for $username."
                log "ERROR" "Failed to set password for $username"
                return 1
            fi
        fi
        echo "Passwords don't match. Please try again."
    done
}

# Function to add a new user
function addUser() {
    local username=$1
    local home_dir="/home/$username"

    if ! validateUsername "$username"; then
        return 1
    fi

    if id "$username" &>/dev/null; then
        echo "User $username already exists."
        log "ERROR" "Attempted to create existing user: $username"
        return 1
    fi

    echo "Creating user $username"
    if sudo useradd -m -s /bin/bash -d "$home_dir" "$username"; then
        if setPassword "$username"; then
            echo "User $username created successfully."
            log "INFO" "User $username created successfully."
        else
            echo "Failed to set password for $username."
            log "ERROR" "User $username creation succeeded but password setup failed."
        fi
    else
        echo "Failed to create user $username."
        log "ERROR" "User creation failed: $username"
        return 1
    fi
}

# Function to add a new group
function addGroup() {
    local groupName=$1

    if ! validateGroupName "$groupName"; then
        return 1
    fi

    if getent group "$groupName" &>/dev/null; then
        echo "Group $groupName already exists."
        log "ERROR" "Attempted to create existing group: $groupName"
        return 1
    fi

    echo "Creating group $groupName"
    if sudo groupadd "$groupName"; then
        echo "Group $groupName created successfully."
        log "INFO" "Group $groupName created successfully."
    else
        echo "Failed to create group $groupName."
        log "ERROR" "Group creation failed: $groupName"
        return 1
    fi
}

# Function to check user/group existence
function checkUserOrGroup() {
    local entity=$1
    local type=$2
    if getent "$type" "$entity" &>/dev/null; then
        echo "$entity exists."
        log "INFO" "$type $entity exists."
    else
        echo "$entity does not exist."
        log "INFO" "$type $entity does not exist."
    fi
}

# Function to delete user or group
function deleteUserOrGroup() {
    local entity=$1
    local type=$2
    if [[ "$type" == "user" && $(id -u "$entity" 2>/dev/null) ]]; then
        sudo userdel -r "$entity"
        echo "Deleted user $entity."
        log "INFO" "Deleted user $entity."
    elif [[ "$type" == "group" && $(getent group "$entity") ]]; then
        sudo groupdel "$entity"
        echo "Deleted group $entity."
        log "INFO" "Deleted group $entity."
    else
        echo "$entity does not exist."
        log "ERROR" "Delete failed. $type $entity does not exist."
    fi
}

# Function to list users or groups
function listUsersOrGroups() {
    local type=$1
    if [[ "$type" == "users" ]]; then
        echo "Listing users:"
        getent passwd | cut -d: -f1
        log "INFO" "Listed users."
    elif [[ "$type" == "groups" ]]; then
        echo "Listing groups:"
        getent group | cut -d: -f1
        log "INFO" "Listed groups."
    else
        echo "Invalid type. Please enter 'users' or 'groups'."
        log "ERROR" "Invalid list request: $type"
    fi
}

# Function to add a user to a group
function addUserToGroup() {
    local user=$1
    local group=$2
    if ! id "$user" &>/dev/null; then
        echo "User $user does not exist."
        log "ERROR" "Cannot add to group: user $user does not exist."
        return 1
    fi
    if ! getent group "$group" &>/dev/null; then
        echo "Group $group does not exist."
        log "ERROR" "Cannot add to group: group $group does not exist."
        return 1
    fi
    if sudo usermod -aG "$group" "$user"; then
        echo "User $user added to group $group."
        log "INFO" "User $user added to group $group."
    else
        echo "Failed to add user $user to group $group."
        log "ERROR" "Failed to add user $user to group $group."
    fi
}

# Main script
trap 'echo "Exiting..."; log "INFO" "Script exited."' EXIT

echo "Welcome to User and Group Management Script"
log "INFO" "Script started."

while true; do
    echo "Menu:"
    echo "1. Add a new user"
    echo "2. Add a new group"
    echo "3. Check if a user or group exists"
    echo "4. Delete a user or group"
    echo "5. List users or groups"
    echo "6. Add user to group"
    echo "7. Exit"
    read -p "Select an option: " choice

    case $choice in
        1)
            read -p "Enter username: " username
            addUser "$username"
            ;;
        2)
            read -p "Enter group name: " groupName
            addGroup "$groupName"
            ;;
        3)
            read -p "Enter entity (username or groupname): " entity
            read -p "Enter type (user or group): " entityType
            entityType="${entityType,,}"  # normalize to lowercase
            if [[ "$entityType" == "user" || "$entityType" == "group" ]]; then
                checkUserOrGroup "$entity" "$entityType"
            else
                echo "Invalid type. Please enter 'user' or 'group'."
                log "ERROR" "Invalid type entered in check: $entityType"
            fi
            ;;
        4)
            read -p "Enter entity (username or groupname): " entity
            read -p "Enter type (user or group): " entityType
            entityType="${entityType,,}"
            if [[ "$entityType" == "user" || "$entityType" == "group" ]]; then
                deleteUserOrGroup "$entity" "$entityType"
            else
                echo "Invalid type. Please enter 'user' or 'group'."
                log "ERROR" "Invalid type entered in delete: $entityType"
            fi
            ;;
        5)
            read -p "Enter type (users or groups): " type
            listUsersOrGroups "$type"
            ;;
        6)
            read -p "Enter username: " user
            read -p "Enter group name: " group
            addUserToGroup "$user" "$group"
            ;;
        7)
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            log "ERROR" "Invalid menu option selected: $choice"
            ;;
    esac
done
