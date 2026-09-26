Debian 13 - i3 Window Manager
===================
This guide is detailed to enable Linux newcomers to get up and running quickly, with a minimum of headaches. How to use these scripts:

1. Install Debian 13 but do not install any desktop environment. Only 'Standard Utilities' and optionally 'SSH Server' should be selected during installation. 
2. Once your Debian 13 install is complete, login with your username and password.
3. Enter:

         sudo apt install -y git
   
   Enter your password when prompted. 
4. Then enter:

         git clone https://github.com/sathanas65/deb13-i3
   
5. Then enter:

         cd deb13-i3
   
6. Installing in a virtual machine? There's nothing to edit - the installer detects it:

   - Any VM (KVM/QEMU, VirtualBox, Xen, VMware, Hyper-V, ...): the i3 config is switched to the VM display setup
     (outputs Virtual-1, Virtual-2, Virtual-3). On real hardware it's switched to the bare-metal setup instead.
   - KVM/QEMU: the 'SPICE guest agent' is ticked in the app menu (clipboard sharing and other qemu features).
   - VirtualBox: 'VirtualBox Guest Additions' is ticked in the app menu (clipboard, shared folders, display resizing).
   - Xen: there's no guest-tools package to add from Debian, so only the i3 config is switched.

   If your hypervisor names its displays something other than Virtual-1/2/3, check with 'xrandr -q' after logging in and
   correct them in ~/.config/i3/config, ~/scripts/vm-single-display.sh and ~/scripts/vm-dual-display.sh.

7. Run the install script, saving everything it prints to install.log:

         bash install.sh 2>&1 | tee install.log

    Enter your password when prompted.

8. A menu opens so you can pick your optional apps. The base i3 desktop is always installed; the menu is only for extras.

    - Use the arrow keys to choose a category and press Enter.
    - In a category, press Space to tick or untick an app, then Enter to go back.
    - Nothing is ticked to start with, except the guest tools when installing in a VM. 'Reset to defaults' and
      'Untick everything' are at the bottom.
    - When you're happy, choose 'Install now' at the top and confirm.

    After that the script runs on its own. To skip the menu and install just the base system (plus VM guest tools in a VM),
    run 'bash install.sh --defaults' instead.

9. To add or remove apps from the menu itself, or change which ones are ticked by default, edit optional-apps.sh.
    Each app is one short block and the instructions are at the top of that file. You don't need to touch install.sh.

10. Now just let the script run and it will reboot when finished. If any optional app failed to install, it will show you which ones
    before rebooting. You can add apps (or retry failed ones) any time later with 'bash ~/deb13-i3/install-apps.sh'.
    You should end up at the gui login screen. Now you can login to i3.
11. To allow Gnome network manager to manage your network connections, you must  edit /etc/network/interfaces after install or the network manager applet will show your
    interface as unmanaged and you won't be able to connect to other networks, though the network you connected to during install will still work. These steps could be added to the install script
    if desired.
      
    a) Use keychord ALT + c (config), then n (network), then i (interfaces), and enter your password at the prompt. This will backup the network interfaces file and open it for edit.
      
    b) Below the row '# The primary network interface' you will see something like 'allow-hotplug w1p3s0'. Comment out this line and all below it by adding '#' before each line.
      
    c) Ctrl + s to save and ctrl + x to exit.
      
    d) Now enter:
   
            sudo systemctl restart networking
      
     e) Enter your password when prompted. Now you should be able to manage your network connections from the applet on the i3 taskbar. If not, try rebooting with Super + Shift + q, then
          click the power options button in the top right corner of the login screen and select 'Restart'.
      
12. If you installed on hardware or on a non-kvm/qemu vm and did not previously configure your display settings, you should do so now.

          xrandr -q

     Note the connected outputs, then

          nano ~/deb12-i3/display.sh

    Change "Virtual-1" to the primary output.
    Ctrl + s to save & Ctrl + x to exit.
    Then run

            sudo cp deb12-i3/display.sh /usr/share/display.sh
            sudo chown root:root /usr/share/display.sh
            sudo chmod 775 /usr/share/display.sh
            sudo cp deb12-i3/background.png /usr/share/background.png
            sudo chown root:root /usr/share/background.png
            sudo chmod 644 /usr/share/background.png
            sudo cp deb12-i3/01_debian.conf /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf
            sudo chown root:root /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf
            sudo chmod 644 /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf
            sudo cp deb12-i3/lightdm.conf /etc/lightdm/lightdm.conf
            sudo chown root:root /etc/lightdm/lightdm.conf
            sudo chmod 644 /etc/lightdm/lightdm.conf

    Then correct diaply outputs in the following:

             nano ~/scripts/right.sh

             nano ~/scripts/dual.sh

             nano ~/scripts/tv.sh
    
    Valid values are HMDI-0, VGA-0, DP-0, DVD-I-0, HDMI-1, HDMI-2, etc. If you aren't sure which is which just enter them in any position and sort it out later.
    Ctrl + s to save & Ctrl + x to exit.

    Finally,

          nano config/i3/config
   
    If installed on VM, 
   
    Uncomment line 'include ~/.config/i3/config.d/vmguest.conf' and correct 'Virtual-1', etc to match your hypervisor outputs, then
    Comment line '#include ~/.config/i3/config.d/baremetal.conf'

    If installed on hardware, 
   
    Change these lines to match your outputs:
   
    #set $display_output_left DP-0
   
    #set $display_output_right DVI-D-0
   
    #set $display_output_top HDMI-0
         
    If you only have a single display, set all 3 values to the same output.
   
    Now Ctrl + s to save & Ctrl + x to exit.

13. To use the weather API to output to the bar, follow these steps:
    
    Sign up for a free API key at https://home.openweathermap.org/users/sign_up

    Verify your email

    Login to https://home.openweathermap.org

    Go to https://home.openweathermap.org/api_keys and note your API key

    Go to google maps and choose a location close to you and click on it to get the GPS coordinates

    Then

             nano ~/.config/i3blocks/weather/weather.py

    After the line '# Replace with your latitude, longitude, and API key', replace the values with your API key and coordinates.
    
    Now Ctrl + s to save & Ctrl + x to exit.
    
    Super + Shift + r to restart i3.


15. Initial keybinds you need to remember are:
    
    Super + Shift + h to open a keybind map you can reference to get oriented. You can also access the keybind map with command:
     
             nano ~/scripts/keymap.txt

    Escape or Enter to exit an execute mode.

    Execute modes are keybind modes that are activated with a keybind. While in an exec mode, normal keybinds will stop working and a red on white mode indicator
    will appear in the bar. Pressing either Escape or Enter will return to default mode. 

    Other easy and useful keybinds to learn right away are Super + Enter to open a terminal and Super + Space to open Rofi app launcher.
    
    Good luck and have fun!!!

