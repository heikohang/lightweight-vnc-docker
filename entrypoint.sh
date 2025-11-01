#!/bin/bash
set -e

# 1. Set VNC Password
# Create the .vnc directory if it doesn't exist
mkdir -p /home/$VNC_USER/.vnc
# Store the password
echo "$VNC_PW" | vncpasswd -f > /home/$VNC_USER/.vnc/passwd
# Set correct permissions
chmod 600 /home/$VNC_USER/.vnc/passwd

# 2. Configure VNC Server
# Create the xstartup file to launch Fluxbox and a terminal
mkdir -p /home/$VNC_USER/.vnc
cat << EOF > /home/$VNC_USER/.vnc/xstartup
#!/bin/bash
# Load Xresources if the file exists
if [ -f \$HOME/.Xresources ]; then
    xrdb \$HOME/.Xresources
fi
# Start a terminal in the background
xterm &
# Start Fluxbox in the foreground (this keeps the session alive)
fluxbox
EOF
# Make the xstartup script executable
chmod +x /home/$VNC_USER/.vnc/xstartup

# 3. Start VNC Server
# -localhost: Only allows connections from localhost (inside the container)
#             This is safer, as we'll expose it via the noVNC web proxy.
# -geometry:  Uses the resolution from the environment variable.
# :1:         Starts the VNC server on display :1 (port 5901).
vncserver :1 -localhost yes -geometry $VNC_RESOLUTION -depth 24

# 4. Start noVNC Web Client
# This is the main process that will keep the container running.
# It proxies the web port (6901) to the VNC port (5901).
/usr/bin/websockify --web /usr/share/novnc/ 6901 localhost:5901