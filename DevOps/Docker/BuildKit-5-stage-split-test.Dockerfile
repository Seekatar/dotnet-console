# in src folder
# docker build --file ../DevOps/Docker/BuildKit-5-stage-split-test.Dockerfile --target 'test-results' --output 'type=local,dest=../out'  .
# docker build --file ../DevOps/Docker/BuildKit-5-stage-split-test.Dockerfile --target 'build'  .
# docker build --file ../DevOps/Docker/BuildKit-5-stage-split-test.Dockerfile -t dotnet-console .


FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["dotnet-console/dotnet-console.csproj", "./dotnet-console/dotnet-console.csproj"]
COPY ["unit/unit.csproj", "./unit/unit.csproj"]
COPY ["dotnet-console.sln", "."]
RUN dotnet restore

COPY . .
RUN dotnet publish "./dotnet-console/dotnet-console.csproj" -c Release -o /app/publish /flp:logfile=/logs/Build.log --no-restore

FROM build AS test
WORKDIR /src/unit
RUN dotnet test --logger "trx;LogFileName=UnitTests.trx" --no-restore --results-directory /out/testresults /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=/out/testresults/coverage/; exit 0

WORKDIR /src

FROM scratch as test-results
COPY --from=test /out/testresults /testresults
COPY --from=test /logs /logs

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "dotnet-console.dll"]