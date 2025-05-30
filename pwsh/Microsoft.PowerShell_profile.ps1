# Custom function to unlock a specific secret store.
function unlockss {
  Unlock-SecretStore -Password $((Import-Clixml -Path '$secretPath\secureStore.ps1.credential') | ConvertTo-SecureString -AsPlainText -Force) # Replace $secretPath as needed.
}

# custom function to get recent lockouts for an Active Directory user
function Get-ADUserLockouts {
  # Parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
    [string]$User
  )
  
  # Import the Active Directory module
  Import-Module ActiveDirectory
  
  # Get the domain controller that holds the PDC role
  $PDC = (Get-ADDomainController -Discover -Service PrimaryDC).HostName
  
  # Query the Security logs for 4740 events (account lockout)
  $lockouts = Get-WinEvent -ComputerName "$PDC" -FilterHashtable @{
    LogName='Security'; Id=4740
  } |
  Where-Object {$_.Properties[0].Value -eq $user} |
    Select-Object TimeCreated, @{
      Name='Account Name';
      Expression={$_.Properties[0].Value}
    },
    @{
      Name='Workstation';
      Expression={$_.Properties[1].Value}
    }

  if ($null -eq $lockouts) {
    Write-Output "The user has no recent lockouts to display."
  } 
  else {
    Write-Output "The user has the following recent lockouts:"
    Write-Output $lockouts
  }
}

# Aliases for terminal text editor
New-Alias -Name 'vi' -Value 'edit'
New-Alias -Name 'vim' -Value 'edit'

# OhMyPosh configuration
oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/stelbent.minimal.omp.json | Invoke-Expression
