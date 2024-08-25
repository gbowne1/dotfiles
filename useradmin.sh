#!/bin/bash

# Function to validate username
function validateUsername() {
    local username="$1"
    if ! [[ $username =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid username. Only alphanumeric characters, underscores, and hyphens are allowed."
        return 1
    fi
    return 0
}

# Function to validate group name
function validateGroupName() {
    local groupName="$1"
    if ! [[ $groupName =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid group name. Only alphanumeric characters, underscores, and hyphens are allowed."
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
            # Basic password strength check (optional)
            if [[ ${#password} -lt 8 ]]; then
                echo "Password too short."
                continue
            fi
            echo "$username:$password" | sudo chpasswd
            return 0
        fi
        echo "Passwords don't match. Please try again."
    done
}

# Function to add a new user
function addUser() {
    local username=$1
    local home_dir="/home/$username"

    # Validate username
    if ! validateUsername "$username"; then
        return 1
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
        return 1
    fi

    echo "Creating user $username"
    if sudo useradd -m -s /bin/bash -d "$home_dir" "$username"; then
        setPassword "$username"
        echo "User $username created successfully."
    else
        echo "Failed to create user $username."
        return 1
    fi
}

# Function to add a new group
function addGroup() {
    local groupName=$1

    # Validate group name
    if ! validateGroupName "$groupName"; then
        return 1
    fi

    # Check if group already exists
    if getent group "$groupName" &>/dev/null; then
        echo "Group $groupName already exists."
        return 1
    fi

    echo "Creating group $groupName"
    if sudo groupadd "$groupName"; then
        echo "Group $groupName created successfully."
    else
        echo "Failed to create group $groupName."
        return 1
    fi
}

# Function to check an existing user or group
function checkUserOrGroup() {
    local entity=$1
    local type=$2
    if getent "$type" "$entity" &>/dev/null; then
        echo "$entity exists."
    else
        echo "$entity does not exist."
    fi
}

# Function to delete a user or group
function deleteUserOrGroup() {
    local entity=$1
    local type=$2
    if [[ "$type" == "user" ]] && id "$entity" &>/dev/null; then
        sudo userdel -r "$entity"
        echo "Deleted user $entity."
    elif [[ "$type" == "group" ]] && getent group "$entity" &>/dev/null; then
        sudo groupdel "$entity"
        echo "Deleted group $entity."
    else
        echo "$entity does not exist."
    fi
}

# Function to list users or groups
function listUsersOrGroups() {
    local type=$1
    if [[ "$type" == "users" ]]; then
        echo "Listing users:"
        getent passwd | cut -d: -f1
    elif [[ "$type" == "groups" ]]; then
        echo "Listing groups:"
        getent group | cut -d: -f1
    else
        echo "Invalid type. Please enter 'users' or 'groups'."
    fi
}

# Function to add a user to a group
function addUserToGroup() {
    local user=$1
    local group=$2
    if ! id "$user" &>/dev/null; then
        echo "User $user does not exist."
        return 1
    fi
    if ! getent group "$group" &>/dev/null; then
        echo "Group $group does not exist."
        return 1
    fi
    sudo usermod -aG "$group" "$user"
    echo "User $user added to group $group."
}

# Main script starts here
trap 'echo "Exiting..."' EXIT

echo "Welcome to User and Group Management Script"

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
            if [[ "$entityType" == "user" || "$entityType" == "group" ]]; then
                checkUserOrGroup "$entity" "$entityType"
            else
                echo "Invalid type. Please enter 'user' or 'group'."
            fi
            ;;
        4)
            read -p "Enter entity (username or groupname): " entity
            read -p "Enter type (user or group): " entityType
            if [[ "$entityType" == "user" || "$entityType" == "group" ]]; then
                deleteUserOrGroup "$entity" "$entityType"
            else
                echo "Invalid type. Please enter 'user' or 'group'."
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
            ;;
    esac
done
