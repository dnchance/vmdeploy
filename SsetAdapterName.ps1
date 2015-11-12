<#
 # Gets the default adapter's IP address and renames the adapter to standard "LAN--xxx.xxx.xxx" format
#>
$csv = "sbx-deployment.csv"
$vms = Import-csv $

# Adds VMware.VimAutomation.Core snap-in to current Windows PowerShell session.
"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Adding VMware.VimAutomation.Core snap-in to current Windows PowerShell session."
If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	{
	Add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	}

#Do the Needful
foreach ($vm in $vms)
{
    $scriptblock = "`$IP = Get-NetAdapter | Get-NetIPAddress
    $NewName = 'LAN--' + `$IP.ipaddress
    Set-NetAdapter -Name `$NewName -confirm:`$false"

    Invoke-VMScript -VM $vm.servername -ScriptText $sciptblock
}