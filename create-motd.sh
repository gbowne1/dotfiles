#!/bin/bash

# --- Get system information ---
UPTIME=$(uptime -p)
# Load average: 1-minute, 5-minute, 15-minute
LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# --- Create the MOTD using a Here Document (cat << EOF) ---
cat << EOF
╭──────────────────────────────────────────────────────────────────────╮
│                                                                      │
│                🚀 Welcome to Your Awesome Linux System! 🚀           │
│                                                                      │
│                Uptime: $UPTIME                                       │
│                Load Average: $LOAD                                   │
│                Current Date: $DATE                                   │
│                                                                      │
│        "Code is like humor. When you have to explain it, it's bad." 🤔 │
│                                                                      │
│          Remember to check your commits and keep your code clean! ✅  │
│                                                                      │
│                Have a great day! 😊                                  │
│                                                                      │
╰──────────────────────────────────────────────────────────────────────╯
EOF
