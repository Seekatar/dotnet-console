# Dotnet 6 Console Test App

This has the source code, Dockerfiles, and build yaml for the blog post [Running .NET Unit tests in Docker](https://seekatar.github.io/2022/04/17/docker-dotnet-unittest.html)

## Running Locally

A helper script runs most of the commands. Here's a typical command to build and get the test output.

```powershell
.\run.ps1 buildDocker, getDockerTest -DockerFile Dockerfile-3stage -NoBuildKit`
```

Then to run the little app.

```powershell
.\run.ps1 runDocker
```

## Creating the Console App

```powershell
mkdir dotnet-console/src
cd dotnet-console/src
dotnet new console -o dotnet-console
```

Then to allow for something to unit test, I added a little waiter class in `program.cs`

## Adding Unit Test and Code Coverage

These commands add the unit test and code coverage to the scaffold code.

```powershell
# add the xunit project
cd src
dotnet new xunit -o unit

# add package and project references to it
cd unit
dotnet add unit.csproj package shouldly
dotnet add unit.csproj package coverlet.msbuild
dotnet add unit.csproj reference ../dotnet-console/dotnet-console.csproj
```

In program.cs allow the unit test to get `internal` classes

```csharp
using System.Runtime.CompilerServices;
[assembly: InternalsVisibleTo("unit")]
```
