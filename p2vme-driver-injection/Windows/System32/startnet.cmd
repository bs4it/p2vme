@echo off
echo Initializing system...
wpeinit
echo Initializing interfaces...
wpeutil InitializeNetwork /NoWait >nul
netsh interface ipv4 set address "Ethernet" static 12.34.56.78 255.255.255.252 >nul
echo Loading...
ping 127.0.0.1 -n 12 >nul
echo Ready
p2vme.cmd