# Temp Files Murderer
Unstoppabled temp file killer for windows with some bad ideas mixed in.

![Temp Files Murderer Menu](https://github.com/whalelinguni/TempFilesMurderer/blob/main/TempFilesMurderedMenu.png?raw=true)

## Description
Temp Files Murderer is a PowerShell script designed to help clean up temporary files on your system. It provides various modes of operation, including normal mode, a mode to kill all running processes before cleaning, and a danger mode where it runs with elevated privileges. 

## Elevate to Admin
This script is designed to run with elevated privileges to ensure it can clean up files in protected locations. If the script is not run with sufficient permissions, it will prompt the user to elevate. Here's a summary of what happens:

1. The script checks if it's already running with administrator privileges.
2. If not, it relaunches itself with elevated permissions using PowerShell's `runas` verb.
3. Upon relaunch, it displays a warning indicating elevated status.

## Usage
Upon successful elevation, the script presents a menu with different options:

1. **Normal Mode**: Cleans temporary files in default locations.
2. **Kill All Processes Mode**: Ends all non-required processes before cleaning.
3. **Launch as System [Danger Mode]**: Runs under the System account, a dangerous operation.
4. **Display information about modes**: Provides information about each mode.
5. **Exit**: Terminates the script.

Choose an option by entering the corresponding number. After completion, it displays information about the cleaned files, including total size found, files unable to remove, and files removed.

## Warning
- **Danger Mode**: Running under the System account can be risky. Only use this mode if you understand the implications.
- Be cautious while using the "Kill All Processes Mode" as it forcefully ends all non-required processes.

## Configuration
You can define custom paths to clean by creating a `TempCleaner.cfg` file in the same directory as the script. Add one path per line.

## Compatibility
- **Architecture**: The script automatically detects whether the system is 32-bit or 64-bit and adapts accordingly.
- **Operating Systems**: Compatible with Windows operating systems.

## Author
- **Whale Linguini** - Creator and maintainer

## License
This project is licensed under the [MIT License](LICENSE).
