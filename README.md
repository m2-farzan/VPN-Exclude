# VPN-Exclude

A simple tool for excluding some websites or IP's from VPN tunnel

## Introduction

In Linux desktops, when you connect to a VPN, all traffic is routed through a virtual tunnel. This behavior is what most people need. In some circumstances however, you may want some specific traffic to bypass this tunnel.

This lightweight tool enables you to stop some specific traffic from going through the VPN tunnel.

Keywords: *VPN Exclusion, VPN Exception, VPN Bypass, Linux VPN Routing Rules*

## Usage

1. Make sure you have `zenity` and `dnsutils` installed.

   You can install them with the following commands:

   * Ubuntu/Debian:

     ```
     $ sudo apt install zenity dnsutils
     ```

   * Archlinux: 

     ```
     $ sudo pacman -S zenity bind
     ```

2. Connect to your VPN.

3. Run the script:

   ```
   $ ./vpn-exclude.sh
   ```

   *You may want to assign a keyboard shortcut for this.*

3. A window will show up. Enter single IP's, IP ranges or domains that should be bypassed. You can also add comments starting with `#`. An example input would be like this:

   ![Example Image](https://raw.githubusercontent.com/m2-farzan/VPN-Exclude/master/example.png)
   
   What you enter here will be saved for the next time you run the code.
   
   *Note: VPN-Exclude doesn't support excluding by application. FWIW, you can use a monitoring tool like Wireshark to detect the IP's that the program is connecting to.*
   
4. If you're asked, enter your sudo password.

   *You can later automate this step by modifying your `sudoers` file.*

5. We're done. Should anything go wrong, the script will show a notification and print the details in terminal. If you want to make perfectly sure that the script works, use a tool like `traceroute` and inspect the first row of the output.

*To undo the exclusion rules, just run the script with `./vpn-exclude.sh del`*.

## Testing

VPN-Exclude has been reported to work correctly on these systems:

* OpenVPN on Archlinux

VPN-Exclude has been reported to fail on these systems:

* [No failures reported.]

*Please help us expand this section by sharing your experience with the code. It'll save time for future visitors. You can either make a PR or open an issue.*
