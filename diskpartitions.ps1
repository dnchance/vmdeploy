#Set Global Variables
$CSV = "$PSScriptRoot\confighd.csv"
$VIServer = "srv-cat-vc1.cnits.com"
$Servers = Import-Csv $CSV 

# Adds VMware.VimAutomation.Core snap-in to current Windows PowerShell session.
"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Adding VMware.VimAutomation.Core snap-in to current Windows PowerShell session."
If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	{
	Add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	}

#function format-hdpartions {
#Define Parameters (For future Function)
#Param ([Parameter(Mandatory=$true)][String] $VIServer,
#[Parameter(Mandatory=$true)][String] $VM,[Parameter(Mandatory=$true)][String] $DrvLtr,[Parameter(Mandatory=$true)][String] $SCSIPort,[Parameter(Mandatory=$true)][String] $SCSITargetID,[Parameter(Mandatory=$true)][String] $BlockSize,[Parameter(Mandatory=$true)][String] $Label)

#Connect to VCenter
Connect-VIServer -Server $VIServer

#Define the script to be invoked on each VM
$scriptblock = "(Get-WmiObject Win32_cdromdrive).drive | %{`$a = mountvol `$_ /l;mountvol `$_ /d;`$a = `$a.Trim();mountvol h: `$a};
`$Disk = Get-Disk -Number (Get-Disk | where {`$_.partitionstyle -eq 'raw'}).number;
Initialize-Disk -Number `$Disk.Number -PartitionStyle GPT -PassThru;
New-Partition -DiskNumber `$Disk.Number -UseMaximumSize -DriveLetter G | Format-volume -Filesystem NTFS -NewFileSystemLabel 'ArchiveDB' -allocationUnitSize 65536 -Force -Confirm:`$false"
foreach ($srv in $Servers){

    Invoke-VMScript -VM $srv.ServerName -ScriptText $scriptblock 
}
