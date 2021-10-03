
Clear-Host
Write-Host " "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "      "
Write-Host -NoNewline "  "
Write-Host -NoNewline -BackgroundColor Red "       "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "   "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline " "
Write-Host -BackgroundColor Red "        "

Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "   "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "      "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "   "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "    "
Write-Host -BackgroundColor Red "  "

Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "      "
Write-Host -NoNewline "  "
Write-Host -NoNewline -BackgroundColor Red "       "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "       "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "    "
Write-Host -BackgroundColor Red "  "

Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "   "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "      "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "      "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "    "
Write-Host -BackgroundColor Red "  "

Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "      "
Write-Host -NoNewline "  "
Write-Host -NoNewline -BackgroundColor Red "       "
Write-Host -NoNewline "      "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline " "
Write-Host -NoNewline -BackgroundColor Red "  "
Write-Host -NoNewline "    "
Write-Host -BackgroundColor Red "  "


# Write welcome and first instructions


Write-Host ""
Write-Host -ForegroundColor White "Welcome to P2VME Driver Injection Tool"
Write-Host ""
Write-Host -ForegroundColor Gray "This tool will assign a letter to each NTFS volume it founds, look for a Windows installation and inject VMWare drivers into it."
Write-Host -NoNewline -ForegroundColor White "Is it OK? (Y/N): "
$OK = Read-Host
# If answer is not Y the script will quit
if ($OK -ne "Y") {
    Write-Host -ForegroundColor Yellow "To run this wizard again type 'p2vme.cmd' ."
    Write-Host "Quitting. Bye."
    break
}
Write-Host -ForegroundColor Gray ""
Write-Host -NoNewline -ForegroundColor Gray "Looking for NTFS Volumes..."
# Get NTFS Volumes
$NTFSVolumes = Get-Volume | Where-Object { $_.DriveType -eq "Fixed" -and $_.FileSystemType -eq "NTFS" }
Write-Host -ForegroundColor Green " OK!"

# Assign a Drive Letter to each volume
Write-Host -NoNewline -ForegroundColor Gray "Assigning letters to all volumes..."
$NTFSVolumes | ForEach-Object {
    $_ | Get-Partition | Add-PartitionAccessPath -AssignDriveLetter -ErrorAction SilentlyContinue
}
Write-Host -ForegroundColor Green " OK!"

# Get NTFS Volumes again, now with all assigned letters
Write-Host -NoNewline -ForegroundColor Gray "Refreshing list of NTFS Volumes..."
$NTFSVolumes = Get-Volume | Where-Object { $_.DriveType -eq "Fixed" -and $_.FileSystemType -eq "NTFS" }
Write-Host -ForegroundColor Green " OK!"
#
# Look for a Registry file of a real Windows volume
$WindowsFound = @()
$counter = 1
Write-Host -ForegroundColor Gray "Looking for a Windows instalation..."
$NTFSVolumes | ForEach-Object {
    $Drive = $_.DriveLetter
    $WinDir = $_.DriveLetter + ":\Windows"
    $RegSYSTEMPath = $WinDir + "\System32\Config\SYSTEM"
    $RegSOFTWAREPath = $WinDir + "\System32\Config\SOFTWARE"
    if ((Test-Path $RegSYSTEMPath -PathType Leaf) -and (Test-Path $RegSOFTWAREPath -PathType Leaf)) {
        Write-Host "Windows Installation Found on" $WinDir", Looking deeper..."
        $regExec = Reg.exe load 'HKLM\TempSYSTEM' $RegSYSTEMPath
        $regExec = Reg.exe load 'HKLM\TempSOFTWARE' $RegSOFTWAREPath
        $HostName = Get-ItemProperty -Path "HKLM:\TempSYSTEM\ControlSet001\Control\ComputerName\ComputerName" -name ComputerName | Select-Object -ExpandProperty ComputerName
        $WinVersion = Get-ItemProperty -Path "HKLM:\TempSOFTWARE\Microsoft\Windows NT\CurrentVersion" -name ProductName | Select-Object -ExpandProperty ProductName
        $regExec = Reg.exe unload 'HKLM\TempSYSTEM'
        $regExec = Reg.exe unload 'HKLM\TempSOFTWARE'
        $WindowsFound += [pscustomobject]@{ID=$counter;Drive=$Drive;WinDir=$WinDir;WinVersion=$WinVersion;HostName=$HostName}
        $counter +=1
    }
}
Write-Host ""
# Check if any windows installation was found
if ($WindowsFound.Count -eq 0){
    Write-Host -ForegroundColor Red "Sorry, no Windows instalattion was found"
    break
}

Write-Host -ForegroundColor Yellow "The following Windows installations were found:"

$WindowsFound | Ft

do {
    Write-Host -ForegroundColor Green "Select an installation by the ID"
    Write-Host -ForegroundColor Red "$errmsg"
    $SelectedInstIndx = Read-Host -Prompt "Type the ID of desired installation"
    if (-Not ($SelectedInst -in 1..$vSphereHosts.Count)){$errmsg = "This value must be within the IDs!"}

} while (($SelectedInstIndx.Length -eq 0) -or -Not ($SelectedInstIndx -in 1..$WindowsFound.Count))

Write-Host ""
Write-Host -ForegroundColor Yellow "The Drivers will be applyed to the following Windows Instance:"
$SelectedInst = $WindowsFound[$SelectedInstIndx-1]
$SelectedInst | Ft
Write-Host -NoNewline -ForegroundColor White "Are you sure? (Y/N): "
$OK = Read-Host
# If answer is not Y the script will quit
if ($OK -ne "Y") {
    Write-Host -ForegroundColor Yellow "To run this wizard again type '.\p2vme\auto.ps1' ."
    Write-Host "Quitting. Bye."
    break
}

Write-Host -ForegroundColor White "Adding Drivers... "
$ImageRoot = ($SelectedInst.Drive) + ":\"
Dism /Image:$ImageRoot /Add-Driver /Driver:X:\p2vme\drivers /Recurse

Write-Host -ForegroundColor Yellow "Drivers Instalation Complete." 
Write-Host -NoNewline -ForegroundColor White "Rebooting in 5"
Start-Sleep -Seconds 1
Write-Host -NoNewline -ForegroundColor White ", 4"
Start-Sleep -Seconds 1
Write-Host -NoNewline -ForegroundColor White ", 3"
Start-Sleep -Seconds 1
Write-Host -NoNewline -ForegroundColor White ", 2"
Start-Sleep -Seconds 1
Write-Host -NoNewline -ForegroundColor White ", 1"
Start-Sleep -Seconds 1
Write-Host ""
Write-Host ""
Write-Host -ForegroundColor White "Bye!"
Start-Sleep -Seconds 1
wpeutil reboot