# make pester tests to call ./run.ps1 to build docker

Describe "Run Docker Tests" {
    It "Should Run 2-stage BUILDKIT=0" {

        ./run.ps1 -Tasks buildDocker,getDockerTest -NoBuildKit -Plain
        $LASTEXITCODE | Should -Be 0
    }
    It "Should Run 2-stage BUILDKIT=1" {

        ./run.ps1 -Tasks buildDocker,getDockerTest -BuildKit -Plain
        $LASTEXITCODE | Should -Be 99
    }
}


