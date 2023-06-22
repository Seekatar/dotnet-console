# in src folder
# docker build --file ../DevOps/Docker/BuildKit-4-stage.Dockerfile --target 'test-results' --output 'type=local,dest=../out' --progress plain .
# docker build --file ../DevOps/Docker/BuildKit-4-stage.Dockerfile -t dotnet-console .


FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-test
WORKDIR /src
COPY ["dotnet-console/dotnet-console.csproj", "./dotnet-console/dotnet-console.csproj"]
COPY ["unit/unit.csproj", "./unit/unit.csproj"]
COPY ["dotnet-console.sln", "."]
RUN dotnet restore

COPY . .
RUN dotnet publish "./dotnet-console/dotnet-console.csproj" -c Release -o /app/publish /flp:logfile=/logs/Build.log --no-restore

WORKDIR /src/unit
RUN dotnet test --logger "trx;LogFileName=UnitTests.trx" --no-restore --results-directory /out/testresults /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=/out/testresults/coverage/; exit 0

WORKDIR /src

FROM scratch as test-results
COPY --from=build-test /out/testresults /testresults
COPY --from=build-test /logs /logs

FROM base AS final
WORKDIR /app
COPY --from=build-test /app/publish .
ENTRYPOINT ["dotnet", "dotnet-console.dll"]