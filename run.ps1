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
    [switch] $Wait,
    [string] $DockerTag = [DateTime]::Now.ToString("MMdd-HHmmss"),
    [switch] $Plain,
    [switch] $NoCache,
    [switch] $KeepDocker,
    [switch] $NoBuildKit,
    [bool] $DeleteDocker = $True
)

$currentTask = ""
$imageName = "dotnet-console"

# execute a script, checking lastexit code
function executeSB
{
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [scriptblock] $ScriptBlock,
    [string] $RelativeDirectory = "",
    [string] $TaskName = $currentTask
)
    Push-Location (Join-Path $PSScriptRoot $RelativeDirectory)

    try {
        $global:LASTEXITCODE = 0

        Invoke-Command -ScriptBlock $ScriptBlock

        if ($LASTEXITCODE -ne 0) {
            throw "Error executing command '$TaskName', last exit $LASTEXITCODE"
        }
    } finally {
        Pop-Location
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
                $extra = @()
                if ($Plain) {
                    $extra += "--progress","plain"
                }
                if ($DeleteDocker) {
                    $extra += "--rm"
                }
                if ($NoCache) {
                    $extra += "--no-cache"
                }
                Write-Verbose "Extra is $($extra | Out-String)"
                $dir = Join-Path $PSScriptRoot src
                Copy-Item (Join-Path $PSScriptRoot DevOps/Docker/*ocker*) $dir -Force
                if ($NoBuildKit) {
                    $env:DOCKER_BUILDKIT=0
                }
                executeSB -RelativeDir 'src' {
                    docker build  `
                                 --tag ${imageName}:$DockerTag `
                                 --file ../DevOps/Docker/Dockerfile `
                                 @extra `
                                 .
                }
                Remove-Item "$dir/*ocker*" -Fo -ErrorAction Ignore
                if ($NoBuildKit) {
                    $env:DOCKER_BUILDKIT=1 # default
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
