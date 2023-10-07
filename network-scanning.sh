#!/bin/bash

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

echo -e "${green}==========================${clear}"

# Check if the CIDR notation is provided as a command line argument
if [ -z "$1" ]; then
    echo -e "${red}No command-line argument provided.${clear}"
    echo -e "${cyan}Please provide a valid network range in CIDR notation.${clear}"
    echo -e "${green}Usage: $0 <network range in CIDR notation>${clear}"
    echo -e "${yellow}Example: $0 10.10.110.0/24${clear}"
    echo -e "${green}==========================${clear}"
    exit 1
fi

# Extract the network range from the command line argument
network_range="$1"

# Validate the CIDR notation using grep and regex
if ! echo "$network_range" | grep -P '^(\d+\.\d+\.\d+\.\d+/\d{1,2})$' > /dev/null; then
    echo -e "${red}Invalid command-line argument.${clear}"
    echo -e "${cyan}Please provide a valid network range in CIDR notation.${clear}"
    echo -e "${green}Usage: $0 <network range in CIDR notation>${clear}"
    echo -e "${yellow}Example: $0 10.10.110.0/24${clear}"
    echo -e "${green}==========================${clear}"
    exit 1
fi


echo -e "${cyan}Starting scan of the provided network range.${clear}"

# Use nmap to scan for most likely open ports in a networked environment and extract IP addresses
# This is done with an Active Directory environment in mind
# Add for example any or all of these ports to fit other cases - 21,22,25,53,80,88,139,443,445
open_ports=$(sudo nmap -Pn -sT -p 88,445 --open -oG - "$network_range" 2>/dev/null | awk '/88\/open/ || /445\/open/ {print $2}')
echo -e "${green}==========================${clear}"
echo -e "${cyan}The following IP addresses were found to have open ports:${clear}"

# Print out all IPs with open ports on a new line.
for ip in $open_ports; do
    echo -e "${green}[${clear}${red}+${clear}${green}]${clear} ${yellow}$ip${clear}"
done

echo -e "${green}==========================${clear}"

# More detailed scan on the IPs found
for ip in $open_ports; do
    echo -e "${green}[${clear}${red}+${clear}${green}]${clear} ${cyan}Scanning $ip for the 1000 most common ports...${clear}"

# Perform initial scan and save to a temporary file
    sudo nmap -Pn -sT -oN "temp_service_scan_$ip.txt" "$ip" > /dev/null 2>&1
    
# Extract open ports from the temporary file
    open_ports_list=$(awk '/open/ && /tcp/{gsub("/tcp", "", $1); print $1}' "temp_service_scan_$ip.txt")
    echo -e "${green}[${clear}${red}+${clear}${green}]${clear} ${cyan}Open ports for $ip extracted...${clear}"

# Join open ports into a comma-separated string
    ports_string=$(echo "$open_ports_list" | tr '\n' ',' | sed 's/,$//')

# Perform detailed service scan for all open ports
    echo -e "${green}[${clear}${red}+${clear}${green}]${clear} ${cyan}Performing service scan for all open ports found for $ip... ${clear}"
    echo -e "${yellow}-------------------------${clear}"
    
# Uncomment the last portion of the next line if you'd rather not have the output of the scan on the terminal.
    sudo nmap -Pn -sT -sCV -p$ports_string $ip -oA service_scan_$ip #> /dev/null 2>&1
  
    echo -e "${yellow}-------------------------${clear}"
    echo -e "${green}[${clear}${red}+${clear}${green}]${clear} ${green}Service scan for $ip completed."
    echo -e "${green}[${clear}${red}+${clear}${green}]${clear} ${green}Results saved with the naming convention service_scan_$ip in all three major formats.${clear}"
    echo -e "${green}==========================${clear}"

    # Clean up temporary file
    sudo rm "temp_service_scan_$ip.txt"

done
