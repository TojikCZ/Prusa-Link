# Forward the port 80 to 8080 even on the loopback, so we van ping ourselves
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -I OUTPUT -p tcp -o lo -d localhost --dport 80 -j REDIRECT --to-ports 8080

set_up_port () {
   # Sets the baudrate and cancels the hangup at the end of a connection
   stty -F "$1" 115200 -hupcl;
}

message() {
   printf "M117 $2\n" > "$1"
}

username=$(id -nu 1000)
user_site=$(su $username -c "python -m site --user-site")

set_up_port "/dev/ttyAMA0"
message "/dev/ttyAMA0" "Starting PrusaLink";

/home/$username/.local/bin/prusalink-boot
rm -f /run/prusalink/manager.pid
export PYTHONOPTIMIZE=2
PYTHONPATH=$user_site /home/$username/.local/bin/prusalink-manager -p "PYTHONPATH=$user_site /home/jo/.local/bin/" start
