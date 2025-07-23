#!/bin/bash

# List of DNS servers to test
DNS_SERVERS=(
    "8.8.8.8"   # Google DNS
    "1.1.1.1"   # Cloudflare DNS
    "9.9.9.9"   # Quad9 DNS
    "208.67.222.222" # OpenDNS
)

# Domain to test
TEST_DOMAIN="example.com"

# Log file
LOG_FILE="/var/log/dns_performance_test.log"

# Function to test DNS server
test_dns_server() {
    local dns_server=$1
    local response_time

    # Measure response time using dig
    response_time=$(dig +stats @$dns_server $TEST_DOMAIN | grep "Query time" | awk '{print $4}')
    
    # Log the result
    echo "$dns_server: $response_time ms" >> "$LOG_FILE"
    
    # Return response time
    echo $response_time
}

# Clear previous log
echo "DNS Performance Test - $(date)" > "$LOG_FILE"

# Test each DNS server and store results
declare -A results
for dns in "${DNS_SERVERS[@]}"; do
    response_time=$(test_dns_server "$dns")
    results["$dns"]=$response_time
done

# Find the fastest DNS server
fastest_dns=""
fastest_time=9999

for dns in "${!results[@]}"; do
    if [ "${results[$dns]}" -lt "$fastest_time" ]; then
        fastest_time=${results[$dns]}
        fastest_dns=$dns
    fi
done

# Log the fastest DNS server
echo "Fastest DNS Server: $fastest_dns with response time: $fastest_time ms" >> "$LOG_FILE"

# Set the fastest DNS server
echo "Setting DNS to $fastest_dns"
echo "nameserver $fastest_dns" | sudo tee /etc/resolv.conf > /dev/null

# Display the log file
cat "$LOG_FILE"
