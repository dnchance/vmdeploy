# Deploy VMs from CSV File
## Much borrowed from http://communities.vmware.com/thread/315193?start=15&tstart=0  
$Script =  "c:\cne\sbx-deployments.csv"
$subnet = "255.255.255.0"
$GW = "10.22.102.1"
$DNS1 = "10.22.102.111"
$Cluster = "LAB"
$vcenter = "sss-lab-vc01.cnb-sslab.com"
#Import VCenter Snapins and connect to the VCenter Server

If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	{
	add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	}
Connect-VIServer -Server $vcenter -force | Out-Null

## Imports CSV file
Import-Csv $Script -UseCulture | %{
$servername = $_.Servername + ".cnent.com"
    if($_.Server2012R2Std -eq "x"){
### Server Deployment ###
    ## Gets Customization info to set NIC to Static and assign static IP address
        Get-OSCustomizationSpec $_.Customization | Get-OSCustomizationNicMapping | ` 
        Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $_.IpAddress -SubnetMask $subnet -DefaultGateway $GW -Dns $DNS1,$DNS2
    ## Sets the name of the VMs OS
        $cust = Get-OSCustomizationSpec -Name $_.Customization
        Set-OSCustomizationSpec -OSCustomizationSpec $cust -NamingScheme Fixed -NamingPrefix $_.HostName
    ## Creates the New VM from the template
         $vm=New-VM -Name $_.ServerName -Template $_.Template -ResourcePool $Cluster -Location SBX `
            -Datastore $_.DS -OSCustomizationSpec $_.Customization `
            -Notes $_.Description -Confirm:$false -RunAsync
    
### VWALL Deployment
    }elseif($_.Customization -eq "CatWin7Vwall"){
         Get-OSCustomizationSpec $_.Customization | Get-OSCustomizationNicMapping | ` 
        Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $_.IpAddress -SubnetMask $subnet -DefaultGateway $GW -Dns $DNS1,$DNS2
        $cust = Get-OSCustomizationSpec -Name CatWin7Vwall
        Set-OSCustomizationSpec -OSCustomizationSpec $cust -NamingScheme Fixed -NamingPrefix $_.HostName
        $vm=New-VM -Name $_.ServerName -Template $_.Template -ResourcePool $Cluster -VMHost $_.vHost `
            -Datastore $_.DS -OSCustomizationSpec $_.Customization `
            -Notes $_.Description -Confirm:$false -RunAsync
    
    }
}    