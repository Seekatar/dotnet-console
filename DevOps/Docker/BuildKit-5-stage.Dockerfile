# docker build --file ../DevOps/Docker/BuildKit-5-stage.Dockerfile --target 'test-results' --output 'type=local,dest=../out' .
# docker build --file ../DevOps/Docker/BuildKit-5-stage.Dockerfile -t dotnet-console .


FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-test
WORKDIR /src
COPY ["dotnet-console/dotnet-console.csproj", "./dotnet-console/dotnet-console.csproj"]
COPY ["unit/unit.csproj", "./unit/unit.csproj"]
COPY ["dotnet-console.sln", "."]
RUN dotnet restore

COPY . .
RUN dotnet build "./dotnet-console/dotnet-console.csproj" -c Release /flp:logfile=/logs/Build.log --no-restore

WORKDIR /src/unit
RUN dotnet test --logger "trx;LogFileName=UnitTests.trx" --no-restore --results-directory /out/testresults /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=/out/testresults/coverage/

FROM scratch as test-results
COPY --from=build-test /out/testresults /out/testresults
COPY --from=build-test /logs /out/logs

FROM build-test as publish
WORKDIR /src
RUN dotnet publish "./dotnet-console/dotnet-console.csproj" -c Release -o /app/publish --no-build

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-console.dll"]