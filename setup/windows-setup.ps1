function Start-WindowsSetup {
    <#
    .SYNOPSIS
        Performs operating system and application setup for Windows workstation.
    .DESCRIPTION
        This function enables my desired Windows Optional Features and uses Winget to install my desired software.
    .EXAMPLE
        # Set up workstation
        . windows-setup.ps1
        Start-WindowsSetup
    .NOTES
        Requirements:
        - Operating System(s):
            - "Windows"
        - Package(s):
            - "PowerShell"
        - Permission(s):
            - "Administrator"
    #>

    #Requires -RunAsAdministrator

    begin {
        $wingetApps = @(
            'Microsoft.PowerShell',
            'Microsoft.WindowsTerminal',
            'Microsoft.Edit',
            'Microsoft.VisualStudioCode',
            'Git.Git',
            'OpenWhisperSystems.Signal',
            'Discord.Discord',
            'Obsidian.Obsidian',
            'Devolutions.RemoteDesktopManager',
            'Zen-Team.Zen-Browser',
            'Valve.Steam',
            'Blizzard.BattleNet',
            'Overwolf.CurseForge',
            'RuneLite.RuneLite',
            'Balena.Etcher',
            'Spotify.Spotify'
        )

        $optionalFeatures = @(
            'Containers-DisposableClientVM',
            'Microsoft-Hyper-V'
        )
    }

    process {
        foreach ($app in $wingetApps) {
            Invoke-Expression -Command { winget install $app --exact --silent --accept-source-agreements --accept-package-agreements }
        }

        foreach ($feature in $optionalFeatures) {
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
        }

        Start-Service -Name 'ssh-agent'
        Set-Service -Name 'ssh-agent' -StartupType 'Automatic'
        if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
            New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (ssh-agent)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        } else {
            continue
        }

        if (Test-Path -Path "$($env:USERPROFILE)\.gitconfig") {
            Rename-Item -Path "$($env:USERPROFILE)\.gitconfig" -NewName ".gitconfig.default" -Confirm:$false -Force
        }
        Copy-Item -Path "$($env:USERPROFILE)\Repositories\dotfiles\git\.gitconfig" -Destination "$($env:USERPROFILE)\.gitconfig" -Confirm:$false -Force

        New-Item -Path $env:USERPROFILE\Repositories -ItemType Directory -Force
        Set-Location -Path $env:USERPROFILE\Repositories
        Invoke-Expression -Command { git clone https://github.com/griffeth-barker/dotfiles.git }

        if (Test-Path -Path "$($env:LOCALAPPDATA)\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json") {
            Get-Item -Path "$($env:LOCALAPPDATA)\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json" | ForEach-Object {
                Rename-Item -Path $_.FullName -NewName "settings.json.default" -Confirm:$false -Force
                Copy-Item -Path "$($env:USERPROFILE)\Repositories\dotfiles\pwsh\settings.json" -Destination $_.FullName -Confirm:$false -Force
            }
        }

        if (Test-Path -Path $profile) {
            Rename-Item -Path $profile -NewName "$($profile.Replace('.ps1', '.ps1.default'))" -Confirm:$false -Force
        }
        Copy-Item -Path "$($env:USERPROFILE)\Repositories\dotfiles\pwsh\Microsoft.PowerShell_profile.ps1" -Destination "$profile" -Confirm:$false -Force

        if (Test-Path -Path "$($env:APPDATA)\Code\User\settings.json") {
            Rename-Item -Path "$($env:APPDATA)\Code\User\settings.json" -NewName "settings.json.default" -Confirm:$false -Force
            Copy-Item -Path "$($env:USERPROFILE)\Repositories\dotfiles\vscode\settings.json" -Destination "$($env:APPDATA)\Code\User\settings.json" -Confirm:$false -Force
        }
    }

    end {}
}