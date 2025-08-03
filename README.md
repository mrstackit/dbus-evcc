# ⚡dbus-open-evcc
Integrate EVCC charger into Victron Venus OS

## 🎯 Purpose
This script supports reading EV charger values from EVCC. Writing values is not supported right now 

## 🚀 Install & Configuration
### 📥 Get the code
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

### ⚙️ Change config.ini
Within the project there is a file `/data/dbus-evcc/config.ini` - just change the values - most important is the deviceinstance under "DEFAULT" and host in section "ONPREMISE". More details below:

| Section  | Config value | Explanation |
| ------------- | ------------- | ------------- |
| DEFAULT  | AccessType | Fixed value 'OnPremise' |
| DEFAULT  | SignOfLifeLog  | Time in minutes how often a status is added to the log-file `current.log` with log-level INFO |
| DEFAULT  | Deviceinstance | Unique ID identifying the charger in Venus OS |
| DEFAULT  | LoadpointInstance | Read readme.md first! Default = 0. Count up for every additional loadpoint |
| DEFAULT  | AcPosition | Charger AC-Position: 0 = AC out, 1 = AC in |
| ONPREMISE  | Host | IP or hostname of EVCC |

### 🔄 Update.sh
The update.sh script allows you to safely and automatically update the project from the latest GitHub release or a specific version.

It performs the following actions:

    1. Fetches the latest release from GitHub (or a specified version)
    2. Compares it to your local version
    3. Stops the running service cleanly (svc -d, pkill)
    4. Downloads and unpacks the ZIP archive
    5. Backs up and restores your config.ini
    6. Copies the new files to /data/dbus-evcc
    7. Restarts the service (svc -u)
    8. Cleans up temporary files (e.g. update.zip, unpacked folders)
    9. Ensures all scripts are executable
    
🛠️ Usage:
```
cd /tmp
/data/dbus-evcc/update.sh
```

📦 Options:
| Option      | Description                                     | Example                             |
| ----------- | ----------------------------------------------- | ----------------------------------- |
| `--silent`  | Perform update without asking for confirmation  | `update.sh --silent`                |
| `--version` | Update (or downgrade) to a specific tag version | `update.sh --version v0.1`          |
| Combined    | Silent update to specific version               | `update.sh --version v0.1 --silent` |

⚠️ Important Notes
   - Do not run the script from within /data/dbus-evcc – it will refuse to run from inside the installation directory to avoid overwriting itself during the update.
   - If a newer version is already installed, the script will exit gracefully.

🧪 Example Output
📡 Checking GitHub for latest version...
🌐 Latest version on GitHub: v0.2

🔍 Local version     : v0.1
🎯 Target version    : v0.2

Möchtest du auf Version v0.2 aktualisieren? [y/N]
⬇️ Downloading v0.2...
📦 Copying files...
🚀 Restarting service...

✅ Update to version v0.2 complete.

## 🔁 If you have two or more load points in EVCC
1. Follow the installation instructions above, but change the commands as follows:
   ```
   wget https://github.com/mrstackit/dbus-evcc/archive/refs/heads/main.zip
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

## 📝 Changelog

### 🔖 v0.1.1 (03.08.2025)
   Modernization
   - Updated to use the modern D-Bus registration method
   - Updated to use new evcc REST API format with evcc v0.207
         
   New Shell Scripts
   - uninstall.sh: Clean removal of the service including rc.local cleanup
   - restart.sh: Graceful restart using svc -d / -u (compatible with supervise)
   - update.sh: Fully automated update process with:
      - GitHub tag version comparison via GitHub API
      - Optional silent mode: --silent
      - Version pinning support: --version vX.Y
      - Preserves config.ini across updates
      - Cleans up temporary files and .zip leftovers safely
    
     Remove img directory

## Useful links
Many thanks. @vikt0rm, @fabian-lauer, @trixing, @JuWorkshop, @SamuelBrucksch and @Naiki92 project:
- https://github.com/trixing/venus.dbus-twc3
- https://github.com/fabian-lauer/dbus-shelly-3em-smartmeter
- https://github.com/vikt0rm/dbus-goecharger
- https://github.com/JuWorkshop/dbus-evsecharger
- https://github.com/SamuelBrucksch/dbus-evcc
- https://github.com/Naiki92/dbus-evcc
