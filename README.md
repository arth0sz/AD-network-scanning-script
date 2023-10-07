
## Bash script for AD network scanning with Nmap

This is a script I put together to deal with scanning an Active Directory environment with Nmap after going through the Active Directory Enumeration & Attacks module on HackTheBox.

It takes a network range in CIDR notation as the only command-line argument and goes looking for port 88 and 445 to find active hosts. Then it scans them for the 1000 common ports and performs a more detailed script and version scan on all open ports.

The results are saved for each IP in the three major formats for Nmap along with being output to the terminal. 

You can uncomment the portion indicated in the script in case you don't want all the output crowding your terminal.

You can also adjust the ports it looks for to fit other environments.

The script is also made with a proxy in mind. For my testing, I was pivoting with ligolo-ng.

### Usage:

`./network-scanning.sh 172.16.7.0/24`

If you don't enter the appropriate argument, you'll receive the corresponding error messages.

![](/screenshots/20231006093500.png?raw=true)

### Output:

For a cleaner output like this, uncomment the portion of line 72 indicated in the script.

![](/screenshots/20231006105221.png?raw=true)

By default, you'll see the results of the scan in your terminal:

![](/screenshots/20231006104810.png?raw=true)

### Output files:

The results of the scan will be saved in the directory from which the script was ran like this:

![](/screenshots/20231006093549.png?raw=true)

