
# Filename		: DisablePlanner.ps1 
# Description 	: Disable Planner from User license without enabling or disabling other plans.
# Author		: Mike Platvoet
# Date			: 04-08-2016 (dd-mm-yyyy)
##############################################################################################################################################	
Import-Module MSOnline 
Connect-MsolService -Credential $Office365credentials 
 
write-host "Connecting to Office 365..." 

# Uncomment the below line if you want the script to run through all License SKUs 
#$licensetype = Get-MsolAccountSku | Where {$_.ConsumedUnits -ge 1} 
# or...
# use this line for just one SKU, fill out the SKUid that can be retrieved via get-msolaccountsku
$licensetype = Get-MsolAccountSku | Where {$_.AccountSkuid -eq "MHE505950:STANDARDWOFFPACK_FACULTY"} 
 
foreach ($license in $licensetype)  
{     
    write-host ("Gathering users with the following subscription: " + $license.accountskuid) 
 
    # Gather users for this particular AccountSku 
    $users = Get-MsolUser -all | where {$_.isLicensed -eq "True" -and $_.licenses[0].accountskuid.tostring() -eq $license.accountskuid} 
 
    foreach ($user in $users) { 
         
        write-host ("Processing: " + $user.displayname) 
     
        $disabledPlans = @()
        #if you want to disable PROJECYWORKMANAGEMENT (Planner) then (change PROJECTWORKMANAGEMENT if you need to disable a different Plan)
        $disabledPlans += "PROJECTWORKMANAGEMENT"
        # add more line if you want to disable more services

         
        foreach ($row in $($user.licenses[0].servicestatus)) { 
            if ($row.provisioningstatus -eq "Disabled")
				{ 
            		$disabledPlans += $($row.serviceplan.servicename) 
            	} 
		}
        #This is just for checking purposes, disable if you don't want to see what it does...
		Write-Host $disabledPlans
        #Below lines will do the actual change for you.
        $NewSkU = New-MsolLicenseOptions -AccountSkuId $license.accountskuid -DisabledPlans $disabledPlans 
		Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -LicenseOptions $NewSkU     
    } 
} 