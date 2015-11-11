# vmdeploy
Scripts used for deploying virtual machines from a CSV file.  
These scripts are ran in the following order when deploying:
**VM and Compute Resoruces**
######################################################################################################################################
I have this split into two scripts because I couldn't get the CPU and RAM parameters to work in the deployment script.
This needs to be fixed.
######################################################################################################################################
deploy-vm.ps1 (Initial deployment of the VMs)
set-resources.ps1 (Updates the CPU and RAM as per the specified ammounts in the CSV source)

**Storage Resources**
######################################################################################################################################
This part is very much a hack fo the time being.  VM's should be powered off initally to facilitate adding controllers.
I run the 'add-hd' script in phases depending on what is being deployed.  I run each set of disks as a phase and comment out the others.
After running the script to add the specific drive, power on the VM's and then run the 'diskpartitions' script.  
Then repeat the process for the remaining sets of drives.  This needs to be streamlined with either specific targeting or pulling all
raw disks into an array and then looping through each instance of the array.
#######################################################################################################################################
add-hd.ps1 (adds different types of disks depending on the csv columns)
diskpartitions.ps1 (Uses Invoke-VMScript command to tell windows to find RAW formatted drive and then initialize and format accordingly)

**Optional Scripts**
changevmnetwork.ps1 (This will change the network the NIC is assigned to if the template had it wrong and you didn't catch it)
remove-had.ps1 (This is handy to undo errant disk creations, or start over if you got something wrong)
set-resourceconfig (This will use the 'ReconfigVM_Task' method to check the box to reserve all RAM for guest)
