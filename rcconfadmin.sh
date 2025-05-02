#!/bin/sh

RC_CONF="/etc/rc.conf"
[ "$(uname)" = "OpenBSD" ] && RC_CONF="/etc/rc.conf.local"
BACKUP="$RC_CONF.bak"

backup_rcconf() {
    cp "$RC_CONF" "$BACKUP"
    echo "Backup saved to $BACKUP"
}

list_entries() {
    grep -Ev '^\s*#|^\s*$' "$RC_CONF"
}

get_value() {
    grep "^$1=" "$RC_CONF" | cut -d= -f2 | tr -d '"'
}

set_value() {
    local key=$1
    local value=$2
    if grep -q "^$key=" "$RC_CONF"; then
        sed -i.bak "s|^$key=.*|$key=\"$value\"|" "$RC_CONF"
    else
        echo "$key=\"$value\"" >> "$RC_CONF"
    fi
    echo "$key set to \"$value\""
}

delete_entry() {
    sed -i.bak "/^$1=/d" "$RC_CONF"
    echo "Removed $1 from $RC_CONF"
}

# Example CLI usage
case $1 in
    backup) backup_rcconf ;;
    list) list_entries ;;
    get) get_value "$2" ;;
    set) set_value "$2" "$3" ;;
    delete) delete_entry "$2" ;;
    *) echo "Usage: $0 {backup|list|get KEY|set KEY VALUE|delete KEY}" ;;
esac
