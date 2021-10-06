param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

#'running with full privileges'


# get current folder
$folder = split-path -parent $MyInvocation.MyCommand.Definition


Write-Host -ForegroundColor Yellow "Removing old hardware..."
Invoke-Expression "$folder\scripts\DeviceCleanupCmd.exe -s *"
Write-Host -ForegroundColor Yellow "Restore Volumes Settings..."
Invoke-Expression "$folder\scripts\SetVolumes.ps1"
Write-Host -ForegroundColor Yellow "Restore Network Interfaces Settings..."
Invoke-Expression "$folder\scripts\SetNetConfig.ps1"

Write-Host -ForegroundColor Green "Tasks complete, closing window in 3 seconds"
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Green "Tasks complete, closing window in 2 seconds"
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Green "Tasks complete, closing window in 1 second"
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Green "Tasks complete, closing window in 0 second"
Start-Sleep -Milliseconds 500
stop-process -Id $PID

