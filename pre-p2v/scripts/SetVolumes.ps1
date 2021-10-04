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


$folder = split-path -parent $MyInvocation.MyCommand.Definition

# test if file is created
If((test-path "$folder\volumes.json"))
{
    # open Json File
    Write-Host -ForegroundColor Yellow "Openning $folder\volumes.json"
    # Get info from file
    $volumesJson = Get-Content $folder\volumes.json | ConvertFrom-Json
    Write-Host -ForegroundColor Yellow "Moving CDROM Drives to the last letters"
    $NewDrvLastLetter = "Z" # The last letter to be used by a CD rom. The next drives will de descending from this letter ( Z,Y,W,V,U... and so on)
    $NewDrvLastLetterInt = [int][char]$NewDrvLastLetter
    # Get Available CD/DVD Drive - Drive Type 5
    $DvdDrv = @()
    $DvdDrv += Get-WmiObject -Class Win32_Volume -Filter "DriveType=5"
    # Check if CD/DVD Drive is Available
    if ($DvdDrv -ne $null)
    {
        Write-Host -ForegroundColor White "Number of CD/DVD Drives found:" $DvdDrv.Count
        Write-Host ""
        $DvdDrv | ForEach-Object {
            # Get Current Drive Letter for CD/DVD Drive
            $DvdDrvLetter = $_ | Select-Object -ExpandProperty DriveLetter
            $NewDrvLetter = ([char]$NewDrvLastLetterInt)
            Write-Output "Current CD/DVD Drive Letter is $DvdDrvLetter"
            # Confirm New Drive Letter is NOT used
            #while (Test-Path -Path $NewDrvLetter)
            $BlackListedLetters = @()
            # Add drive letters from json
            $BlackListedLetters += ($volumesJson).DriveLetter
            # Add drive letters from system
            $BlackListedLetters += (Get-Volume).DriveLetter
            # Add drive letters from network mappings
            $BlackListedLetters += (Get-PSDrive | where{$_.DisplayRoot -match "\\"}).Name
            # Sort and cleanup
            $BlackListedLetters = $BlackListedLetters | Sort-Object -Unique | Where-Object { $_ -ne ($DvdDrvLetter.Split(":")[0])}
            while ($BlackListedLetters -contains $NewDrvLetter)
            {
                $NewDrvLastLetterInt--
                $NewDrvLetter = ([char]$NewDrvLastLetterInt)
            }
            # Change CD/DVD Drive Letter
            $NewDrvLetter = $NewDrvLetter+":"
            $SetDvdDrvLetter = $_ | Set-WmiInstance -Arguments @{DriveLetter="$NewDrvLetter"}
            Write-Output "Updated CD/DVD Drive Letter as $NewDrvLetter"
            Write-Host ""
        }
    }
    else
    {
        Write-Output "Error: No CD/DVD Drive Available!!"
    }
    # Make sure all disks are online
    Write-Host -NoNewline -ForegroundColor Yellow "Setting disks Online..."
    Get-Disk | Where-Object {($_.IsBoot -ne $true) -and ($_.IsSystem -ne $true)} | Set-Disk -IsOffline $false
    Get-Disk | Where-Object {($_.IsBoot -ne $true) -and ($_.IsSystem -ne $true)} | Set-Disk -IsReadOnly $false
    Start-Sleep -Seconds 2
    Write-Host -ForegroundColor Yellow " OK."
    Start-Sleep -Milliseconds 500
    # For each volume found
    $volumesJson | ForEach-Object {
        $volumeJson = $_
        # Get partition where volume belongs by path (id)
        $partition = Get-Volume | Where-Object { $_.Path -eq $volumeJson.Path } | Get-Partition
        # Remove Drive letter from all partitions that does not match to original layout (this prevents conflicts)
        if ( ($partition.DriveLetter -ne $volumeJson.DriveLetter) -and ($volumeJson.DriveLetter -ne $null) -and ($partition.DriveLetter.ToString() -ne "" )){
            Write-Host "Removing missplaced volume:" $partition.DriveLetter
            $partition | Remove-PartitionAccessPath -AccessPath (($partition.DriveLetter.ToString())+":")
        }
    }

    # For each volume found
    $volumesJson | ForEach-Object {
        $volumeJson = $_
        $partition = Get-Volume | Where-Object { $_.Path -eq $volumeJson.Path } | Get-Partition
        # Sets the drive letter according to json file
        if ( ($partition.DriveLetter -ne $volumeJson.DriveLetter) -and ($volumeJson.DriveLetter -ne $null ) ){
            Write-Host "Setting:" $volumeJson.DriveLetter
            $partition | Set-Partition -NewDriveLetter $volumeJson.DriveLetter   
        }
    }
    Write-Host -ForegroundColor Yellow "The volume configuration is done!"
	Write-Host -ForegroundColor White "Press ENTER key."
    Read-Host
}
else
{
    Write-Host -ForegroundColor Red "Something is wrong. Check 'volumes.json' file"
}
