## CSV Location
$scriptsource = "c:\scripts\confighd.csv"
## Set Datastore Names for specific Data types if not specified in CSV 
$nvr_evenDS = "cata_nvr_livedb_evens"
$nvr_oddDS = "cata_nvr_livedb_odds"
$fnvr_evenDS = "cata_fonvr_livedb_evens"
$fnvr_oddDS = "cata_fonvr_livedb_odds"
$SQLDataDS = "cata_vm_1"
$SQLLogsDS = "cata_vm_1"
$SQLTempDBDS = "cata_vm_1"
$vicenter = "srv-cat-vc1.cnits.com"


#Import VCenter Snapins and connect to the VCenter Server

If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	{
	Add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	}
Connect-VIServer -Server $vicenter -force | Out-Null


## Imports CSV file and remove drives.
$vms = Import-Csv $scriptsource

foreach ($vm in $vms){
    get-vm $vm.ServerName | get-harddisk -name "Hard Disk 3" | remove-harddisk -DeletePermanently -Confirm:$false
}