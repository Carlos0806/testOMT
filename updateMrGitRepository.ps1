#Requires -Version 4.0 -Modules Posh-Git
. .\parameters.ps1
function Update-MrGitRepository {

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact='Medium')]
    param ()

    $Location = Get-Location

    $nameCurrentBranch = git -C "$Location" rev-parse --abbrev-ref HEAD

    Write-Host $nameCurrentBranch
    
    if (Get-GitDirectory) {
        $Repository = Split-Path -Path (git.exe rev-parse --show-toplevel) -Leaf
    }
    else {
        throw "$Location is not part of a Git repsoitory."
    }

    if ($nameCurrentBranch -contains 'testing') {        
        $currentBranch = git.exe symbolic-ref --short HEAD
        $localCommit = git.exe rev-list --all -n1
        $remoteCommit = (git.exe ls-remote origin $currentBranch) -replace '\s.*$'
        
        if ($localCommit -ne $remoteCommit){

            if ($PSCmdlet.ShouldProcess($currentBranch,'Fetch')) {

                . .\executeAdmin.ps1
                git.exe fetch --all
		git.exe pull
            }

        }
        else {
              "Local '$currentBranch' branch of the '$Repository' repository is already up-to-date with '$originURL'."
             if (((Get-Date -Format %H) -eq 7) -or ((Get-Date -Format %H) -eq 10) -or ((Get-Date -Format %H) -eq 14) -or ((Get-Date -Format %H) -eq 17) -or ((Get-Date -Format %H) -eq 21)  ){
              . .\alertTesting.ps1
              }
        }

    }
    else {
        throw "You need set up in Testing branch for continue, use the command 'git branch testing' for set up. '$Repository' repository"
    }    
       
}


Update-MrGitRepository