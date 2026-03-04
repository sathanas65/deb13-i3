Whonix - i3 Window Manager
===================
This guide is detailed to enable Whonix users to use i3 instead of xfce, while preserving security and function. How to use these scripts:
 
1. Login to a fresh XFCE Whonix Workstation KVM image (qcow2)

2. Open terminal and enter:

         sudo apt install -y git
   
   Enter your password when prompted. 
   
3. Then enter:

         git clone https://github.com/sathanas65/whonix-i3
   
4. Then enter:

         cd whonix-i3

5. Now you can review and edit the main install script.

         nano install.sh

    You can comment out lines by putting a hash(#) before them, and then they will not run. Or uncomment any you want to run.
    
6. Once you are done selecting or deselecting packages to you liking, or adding some of your own, Ctrl + s to save & Ctrl + x to exit. 
   
7. Finally, to run the install script, outputting to a txt file for logging, enter:

         bash install.sh >> output.txt

    Enter your password if prompted.
8. Now just let the script run and it will reboot when finished. You should end up at the gui login screen. Now you can login to i3.

9. Initial keybinds you need to remember are:
    
    Super + Shift + h to open a keybind map you can reference to get oriented. You can also access the keybind map with command:
     
             nano ~/scripts/keymap.txt

    Escape or Enter to exit an execute mode.

    Execute modes are keybind modes that are activated with a keybind. While in an exec mode, normal keybinds will stop working and a red on white mode indicator
    will appear in the bar. Pressing either Escape or Enter will return to default mode. 

    Other easy and useful keybinds to learn right away are Super + Enter to open a terminal and Super + Space to open Rofi app launcher.
    
    Good luck and have fun!!!

