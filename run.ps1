#! pwsh
param (
    [ArgumentCompleter({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $runFile = (Join-Path (Split-Path $commandAst -Parent) run.ps1)
        if (Test-Path $runFile) {
            Get-Content $runFile |
                    Where-Object { $_ -match "^\s+'([\w+-]+)' {" } |
                    ForEach-Object {
                        if ( !($fakeBoundParameters[$parameterName]) -or
                            (($matches[1] -notin $fakeBoundParameters.$parameterName) -and
                             ($matches[1] -like "$wordToComplete*"))
                            )
                        {
                            $matches[1]
                        }
                    }
        }
     })]
    [string[]] $Tasks,
    [switch] $DryRun
)

$currentTask = ""

# execute a script, checking lastexit code
function executeSB
{
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [scriptblock] $ScriptBlock,
    [string] $WorkingDirectory = $PSScriptRoot,
    [string] $TaskName = $currentTask
)
    if ($WorkingDirectory) {
        Push-Location $WorkingDirectory
    }
    try {
        Invoke-Command -ScriptBlock $ScriptBlock
        $LASTEXITCODE = 0

        if ($LASTEXITCODE -ne 0) {
            throw "Error executing command '$TaskName', last exit $LASTEXITCODE"
        }
    } finally {
        if ($WorkingDirectory) {
            Pop-Location
        }
    }
}

if ($Tasks -eq "ci") {
    $Tasks = @('CreateLocalNuget','Build','Test','Pack') # todo sample task expansion
}

foreach ($currentTask in $Tasks) {

    try {
        $prevPref = $ErrorActionPreference
        $ErrorActionPreference = "Stop"

        "-------------------------------"
        "Starting $currentTask"
        "-------------------------------"

        switch ($currentTask) {
            'runDocker' {
                executeSB {
                    docker run --rm dotnet-test
                }
              }
            'buildDocker' {
                executeSB {
                    docker build --rm --tag dotnet-test:latest .
                }
            }
            'pushDocker' {
                executeSB {
                    docker image tag dotnet-test k3s-server:5000/dotnet-test
                    docker push k3s-server:5000/dotnet-test
                }
            }
            'installHelm' {
                $valuesFile = Join-Path $PSScriptRoot DevOps/test/values.yaml
                $outputFile = Join-Path $env:Temp dry-run.yaml
                $name = 'test' # $PWD | Split-Path -Leaf
                if ($DryRun) {
                    executeSB -WorkingDirectory (Join-Path $PSScriptRoot DevOps/test) {
                        helm install DRY-RUN . --dry-run --values $valuesFile | ForEach-Object {
                            $_ -replace "LAST DEPLOYED: .*","LAST DEPLOYED: NEVER"
                        } | Out-File $outputFile -Append
                        "Output in now $outputFile"
                    }
                } else {
                    executeSB -WorkingDirectory (Join-Path $PSScriptRoot DevOps/test) {
                        "$PWD"
                        "helm install $name . --values $valuesFile"
                        helm install $name . --values $valuesFile
                    }
                }
            }
            'uninstallHelm' {
                executeSB {
                    helm uninstall test
                }
            }
            default {
                throw "Invalid task name $currentTask"
            }
        }

    } finally {
        $ErrorActionPreference = $prevPref
    }
}
