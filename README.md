# dbus-open-evcc
Integrate EVCC charger into Victron Venus OS

## Purpose
This script supports reading EV charger values from EVCC. Writing values is not supported right now 

## Install & Configuration
### Get the code
Just grab a copy of the main branche and copy them to a folder under `/data/` e.g. `/data/dbus-evcc`.
After that call the install.sh script.

The following script should do everything for you:
```
wget https://github.com/mrstackit/dbus-evcc/archive/refs/heads/main.zip
unzip main.zip "dbus-evcc-main/*" -d /data
mv /data/dbus-evcc-main /data/dbus-evcc
chmod a+x /data/dbus-evcc/install.sh /data/dbus-evcc/uninstall.sh /data/dbus-evcc/restart.sh
/data/dbus-evcc/install.sh
rm main.zip
```
⚠️ Check configuration after that - because service is already installed and running and with wrong connection data (host) you will spam the log-file

### Change config.ini
Within the project there is a file `/data/dbus-evcc/config.ini` - just change the values - most important is the deviceinstance under "DEFAULT" and host in section "ONPREMISE". More details below:

| Section  | Config value | Explanation |
| ------------- | ------------- | ------------- |
| DEFAULT  | AccessType | Fixed value 'OnPremise' |
| DEFAULT  | SignOfLifeLog  | Time in minutes how often a status is added to the log-file `current.log` with log-level INFO |
| DEFAULT  | Deviceinstance | Unique ID identifying the charger in Venus OS |
| DEFAULT  | LoadpointInstance | Read readme.md first! Default = 0. Count up for every additional loadpoint |
| DEFAULT  | AcPosition | Charger AC-Position: 0 = AC out, 1 = AC in |
| ONPREMISE  | Host | IP or hostname of EVCC |

## If you have two or more load points in EVCC
1. Follow the installation instructions above, but change the commands as follows:
   ```
   wget https://github.com/tm-107/dbus-evcc/archive/refs/heads/main.zip
   unzip main.zip "dbus-evcc-main/*" -d /data
   mv /data/dbus-evcc-main /data/dbus-evcc-1
   chmod a+x /data/dbus-evcc-1/install.sh
   /data/dbus-evcc-1/install.sh
   rm main.zip
   ```
   (Count up `dbus-evcc-1` for each loadpoint)
2. Update the `dbus-evcc-1/config.ini`:
   - The `deviceinstance` should be different for each loadpoint: Use `43` for the first. Use `44` for the second loadpoint...
   - Change `LoadpointInstance` according to your evcc-configuration

If you have more than two loadpoints, the procedure is the same, but the index should be counted up.

## Useful links
Many thanks. @vikt0rm, @fabian-lauer, @trixing, @JuWorkshop, @SamuelBrucksch and @Naiki92 project:
- https://github.com/trixing/venus.dbus-twc3
- https://github.com/fabian-lauer/dbus-shelly-3em-smartmeter
- https://github.com/vikt0rm/dbus-goecharger
- https://github.com/JuWorkshop/dbus-evsecharger
- https://github.com/SamuelBrucksch/dbus-evcc
- https://github.com/Naiki92/dbus-evcc
