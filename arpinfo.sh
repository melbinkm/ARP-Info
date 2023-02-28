#!/bin/bash

# Define the default options
SHOW_INFO=""
ARP_CACHE="/proc/net/arp"

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "Error: This script must be run as root." >&2
   exit 1
fi

# Check if the arp cache is available
if [ ! -f "$ARP_CACHE" ]; then
   echo "Error: The ARP cache is not available." >&2
   exit 1
fi

# Parse command line options
while getopts ":i" opt; do
  case $opt in
    i)
      SHOW_INFO="true"
      ;;
    \?)
      echo "Error: Invalid option -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Error: Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Read the ARP cache and extract the MAC and IP addresses
MAC_ADDRESSES=$(awk '{print $4}' < "$ARP_CACHE")
IP_ADDRESSES=$(awk '{print $1}' < "$ARP_CACHE" | tail -n +2)

# Print the MAC and IP addresses in a table format
if [[ -n "$SHOW_INFO" ]]; then
  printf "+-----------------+-------------------+------------------------+\n"
  printf "| IP Address      | MAC Address       | Last Communication Time |\n"
  printf "+-----------------+-------------------+------------------------+\n"
  for ip in $IP_ADDRESSES; do
    mac=$(grep -w $ip < "$ARP_CACHE" | awk '{print $4}')
    time=$(grep -w $ip < "$ARP_CACHE" | awk '{print $2}')
    printf "| %-15s | %-17s | %-22s |\n" "$ip" "$mac" "$time"
  done
  printf "+-----------------+-------------------+------------------------+\n"
else
  printf "+-----------------+-------------------+\n"
  printf "| IP Address      | MAC Address       |\n"
  printf "+-----------------+-------------------+\n"
  paste <(echo "$IP_ADDRESSES") <(echo "$MAC_ADDRESSES") | while read ip mac; do
    printf "| %-15s | %-17s |\n" "$ip" "$mac"
  done
  printf "+-----------------+-------------------+\n"
fi
