##elevate to admin
Write-Host "*************************************************************************************"
Write-Host "                     Checking for Administrator Elevation..."
Write-Host "*************************************************************************************"

Write-Host "Prompting user to elevate if needed."
Write-Host " "

Start-Sleep -Milliseconds 1500

# Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

 # Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
    {
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = "Temp Files Murderer - WhaleLinguini - (Elevated)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.UI.RawUI.ForegroundColor = "Green"
    clear-host
    }
 else
    {
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    exit
    }

$scriptDir = $PWD
$logFile = Join-Path -Path $scriptDir -ChildPath "\CleanerLog.log"
Remove-Item $logFile -ErrorAction SilentlyContinue
New-Item -ItemType "file" -Path $logFile | out-null
Add-Content -Path $logFile "[Skipping]"
$userName = $Env:UserName

function getArch {	
	$Arch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture;
		if ($Arch -eq '32-bit') {
			$userArch = "x86"
		}
			elseif ($Arch -eq '64-bit') {
				$userArch = "x64"
			}
	return $userArch
}

function Type-Text {
    param(
        [string]$Text,
        [int]$DelayMilliseconds = 80
    )

    foreach ($char in $Text.ToCharArray()) {
        Write-Host -NoNewline $char
        Start-Sleep -Milliseconds $DelayMilliseconds
    }
    Write-Host ""
}

function Write-DashedLine {
    $consoleWidth = $host.UI.RawUI.WindowSize.Width
    $dashCount = $consoleWidth - 1
    $dashes = "-" * $dashCount
    Write-Host $dashes
}

function wLog {
	param(
	[string]$Message
	)
	Add-Content -Path $logFile "$Message" 
}

function Write-Message {
    param(
        [string]$Symbol,
        [string]$Message
    )

    switch ($Symbol) {
        "Cleaning" {
            Write-Host -ForegroundColor Black -BackgroundColor Green -NoNewline "[_Cleaning_]"
        }
        "Skipping" {
            Write-Host -ForegroundColor Black -BackgroundColor Yellow -NoNewline "[_Skipping_]"
			#Write-Host ""
        }
        "Empty" {
            Write-Host -ForegroundColor Black -BackgroundColor Red -NoNewline "[__Empty__] "
			#Write-Host ""
        }
        "Size" {
            Write-Host -ForegroundColor Black -BackgroundColor Cyan -NoNewline "[Found_Size]"
			#Write-Host ""
        }
		"Analyzing" {
            Write-Host -ForegroundColor Black -BackgroundColor Cyan -NoNewline "[Analyzing] "
			#Write-Host ""
        }
        default {
            Write-Host -ForegroundColor White -NoNewline "[ $Symbol ]"
        }
		
		"[DEBUG]" {
				   If ($DEBUG -gt 0) {
					   Write-Host -ForegroundColor Black -BackgroundColor Magenta "[DEBUG]"
					}
		}
    }			
	
    $Delay = 350
    Write-Host -ForegroundColor White " $Message"
    Start-Sleep -Milliseconds $Delay
}

$compName = [System.Net.Dns]::GetHostName()
$userArch = getArch


function killemall {
	Write-Host "Killin em all!"
	Start-Process -FilePath "$scriptDir\bin\killemall.exe" -Wait -ArgumentList "/?"
	Write-Host "Killed em all!"
}

function dangerMode {
	
	Write-Host "Relaunching in Danger Mode..."
	Start-Sleep -Seconds 3
	
	if ($userArch -eq "x64") {
	Start-Process -filePath "$scriptDir\bin\NSudoLC _x64.exe" -ArgumentList " -U:T -P:E powershell.exe $scriptDir\TempFilesMurderedMenu.ps1"
	exit
	}
	
	if ($userArch -eq "x86") {
	Start-Process -filePath "$scriptDir\bin\NSudoLC _x32.exe" -ArgumentList " -U:T -P:E powershell.exe $scriptDir\TempFilesMurderedMenu.ps1"
	exit
	}
}

function Get-Paths {
    $configFile = "TempCleaner.cfg"
    if (Test-Path $configFile) {
        $paths = Get-Content $configFile
		Write-Host "Configuration file loaded. Using paths from config file."
    } else {
		Write-Host "No configuration file found. Using script default paths."
		#Write-Host "Tip: You can define your own paths to clean by creating a TempCleaner.cfg file in the same directory as this script. Add one path to clean per line"
		Start-Sleep -Seconds 1
        $paths = @(
			    "C:\Temp",
				"C:\Intel",
				"C:\AMD",
				"C:\Nvidia",
				"C:\Log",
				"C:\Windows\Temp",
				"C:\Windows\Logs",
				"C:\Windows\System32\WDI\Logfiles",
				"C:\Users\Administrator\AppData\Local\Microsoft\OneDrive\Logs",
				"C:\OnedriveTemp",
				"C:\Users\Administrator\AppData\Local\Microsoft\Windows\WebCache",
				"C:\Windows\Prefetch",
				"C:\Users\Administrator\AppData\Local\Temp",
				"C:\Windows\SoftwareDistribution",
				"C:\Windows\Downloaded Program Files",
				"C:\Windows.old",
				"C:\Windows\Installer",
				"C:\Users\Administrator\AppData\Local\Microsoft\Windows\PriCache",
				"C:\MSOCache",
				"C:\CONFIG.MSI",
				"C:\Windows\TempInst",
				"C:\WINDOWS.~BT",
				"C:\WINDOWS.~WS",
				"C:\Windows\LiveKernelReports",
				"C:\DRIVERS",
				"C:\ESD",
				"C:\Users\Administrator\AppData\Local\CrashDumps"
            # Add other default paths here
        )
    }
    return $paths
}

function guiPretty {
	$lineCheck = Get-Content -Path $logFile -Tail 1
	#Write-Host "LINe CHECK"$lineCheck
	$lineFlag = $lineCheck.Substring(0, 10) 
	#Write-Host "LINE FLAG: "$lineFlag
	#Start-Sleep -Seconds 5
	if ($lineFlag -eq "[Skipping]") {
		Write-Host ""
	}
}

function startMurder {
	
Write-DashedLine
Write-Host ""

Write-Host "  _______                          _______ __ __                 ___ ___               __                       "
Write-Host " |       .-----.--------.-----.   |   _   |__|  .-----.-----.   |   Y   .--.--.----.--|  .-----.----.-----.----."
Write-Host " |.|   | |  -__|        |  _  |   |.  1___|  |  |  -__|__ --|   |.      |  |  |   _|  _  |  -__|   _|  -__|   _|"
Write-Host "  `-|.  |-|_____|__|__|__|   __|   |.  __) |__|__|_____|_____|   |. \_/  |_____|__| |_____|_____|__| |_____|__|  "
Write-Host "   |:  |                |__|      |:  |                         |:  |   |                                       "
Write-Host "   |::.|                          |::.|                         |::.|:. |                                       "
Write-Host "    `---'                           `---'                          `--- ---'                                       "

Write-Host ""
Write-Host ""
Type-Text ")xxxxx[;;;;;;;;;>"
Write-Host ""
Type-Text "								  				--Whale Linguini"
Write-Host ""
Write-DashedLine
Write-Host ""


$murder = Read-Host "Ready to murder some temp files? [Y/notY]"
If ($murder -eq 'Y' -or $murder -eq 'y') {
	Write-Host "Ok!"
	Write-Host ""
  } else {
	 Write-Host "kthxbye"
	 Pause
	 exit 
}


$tempPaths = Get-Paths

$totalSize = 0
$totalRemoved = 0
foreach ($tempPath in $tempPaths) {
        if([System.IO.Directory]::Exists($tempPath)){
			guiPretty
        Write-Message "Analyzing" ": $tempPath"
		Wlog "[Analyzing]: $tempPath" 
        $files = Get-ChildItem $tempPath | Where-Object { $_.PSIsContainer -eq $false }
        if ($files.Count -gt 0) {
            $size = ($files | Measure-Object -Property Length -Sum).Sum / 1Mb
            $totalSize += $size
            Write-Message "Size" ": $size MB"
			WLog "[Size]: $size MB" 
			Write-Message "Cleaning" ": $tempPath"
			Write-Host ""
            # code to remove temporary files here
			#Get-ChildItem -Path $tempPath -Include * -File -Recurse | foreach { $_.Delete()}
			Remove-Item -Path "$tempPath\*" -Force -Recurse -ErrorAction SilentlyContinue
			$size = ($files | Measure-Object -Property Length -Sum).Sum / 1Mb
			$totalNotRemoved += $size

        } else {
            Write-Message "Empty" ": $tempPath (No files found in directory.)"
			WLog "[Empty]: $tempPath (No files found in directory.)"
			Write-Host ""
        }
    } else {
        Write-Message "Skipping" ": $tempPath (Directory does not exist.)"
		WLog "[Skipping]: $tempPath (Directory does not exist.)"
    }
}


#Write-Host "Total size cleaned: $totalSize MB"

$rTotalSize = [Math]::Round($totalSize, 2)
$rTotalSizeString = "{0:N2}" -f $rTotalSize

$rTotalNotRemoved = [Math]::Round($totalNotRemoved, 2)
$rTotalNotRemovedString = "{0:N2}" -f $rTotalNotRemoved

$totalRemoved = ($rTotalSize - $rTotalNotRemoved)
$totalRemovedString = "{0:N2}" -f $totalRemoved

Write-DashedLine
Write-Host ""
Write-Host ""
Write-Host ".----------------------------------."
Write-Host "| Finished! All Murders Murdereded |"
Write-Host "'----------------------------------'"
Write-Host ""
#Write-Message "Total size found: $rTotalSizeString"
#Write-Message "Total size unable to be removed: $rTotalNotRemovedString"
#Write-Message "Total size removed: $totalRemovedString"
# Create an array of objects to hold your data
$output = @()

# Add data to the array
$output += [PSCustomObject]@{
    "Totals" = "Files Found:"
    "Size MB" = $rTotalSizeString
}
$output += [PSCustomObject]@{
    "Totals" = "Files Unable To Remove:"
    "Size MB" = $rTotalNotRemovedString
}
$output += [PSCustomObject]@{
    "Totals" = "Files Removed:"
    "Size MB" = $totalRemovedString
}

# Output the formatted table
$output | Format-Table -AutoSize
Write-Host ""
Write-DashedLine
Write-Host ""
pause
Type-Text "	  	  	  Be kind to oceans...."
exit
	
}


function Show-Menu {
	$compName = [System.Net.Dns]::GetHostName()
	$userArch = getArch
	
	
    Clear-Host
	Write-DashedLine
	

	
	Write-Host ""
	Write-Host "[Running as $userName]"
	Write-Host "[Detected Arch: $userArch]"
	Write-Host "[Computer Name: $compName]"
	Write-Host ""
	Write-DashedLine
	Write-Host ""
	#Write-Host "=== Temp Files Murderer Run Modes ===`n"
	If ($compName + "$" -eq $UserName) {
		Write-Host "####---    RUNNING IN DANGER MODE    ---####"
		Type-Text "WARNING. Powershell running as Trusted Installer with all privileges enabled!"
		Write-Host ""
	}
	
	Write-Host "    .-------------------------------."
	Write-Host "    | Temp Files Murderer Run Modes |"
	Write-Host "#---'-------------------------------'---#"
	Write-Host "|                                       |"
    Write-Host "| 1. Normal Mode                        |"
    Write-Host "| 2. Kill All Processes Mode            |"
    Write-Host "| 3. Launch as System [Danger Mode]     |"
	Write-Host "| 4. Display information about modes.   |"
    Write-Host "| 5. Exit                               |"
	Write-Host "#_______________________________________#"
	Write-Host ""
}

function Option1 {
    # Insert your code for Option 1 here
	cls
    Write-Host "Starting in Normal Mode."
	startMurder
}

function Option2 {
    # Insert your code for Option 2 here
    Write-Host "You selected Option 2"
	cls
	killemall
	startMurder
}

function Option3 {
    # Insert your code for Option 3 here
    Write-Host "You selected Option 3"
	cls
	dangerMode
}

function Option4 {
    # Insert your code for Option 4 here
	Write-Host ""
    Write-Host "-- Run Modes Informations --"
	Write-Host "1. Just the normal mode. You should use this."
	Write-Host "2. All non-required processes will be ended before running. `n   This can help if processes are locking some temp files and you know you they are ok to remove."
	Write-Host "3. Run under the System account. Elevating to the System  account can be dangerous. `n   Use only if you understand what you are doing."
	Write-Host "5. This will exit everything. You will not pass go."
	Write-Host "----------------------------"
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "1" { Option1 }
        "2" { Option2 }
        "3" { Option3 }
		"4" { Option4 }
        "5" { exit }
        default { Write-Host "Please select a valid option" }
    }
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} while ($choice -ne "5")

