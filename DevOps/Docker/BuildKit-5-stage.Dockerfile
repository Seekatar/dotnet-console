# docker build --file ../DevOps/Docker/BuildKit-5-stage.Dockerfile --target testresults --output 'type=local,dest=../out' .
# docker build --file ../DevOps/Docker/BuildKit-5-stage.Dockerfile .


FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-test
WORKDIR /src
COPY ["dotnet-console/dotnet-console.csproj", "./dotnet-console/dotnet-console.csproj"]
COPY ["unit/unit.csproj", "./unit/unit.csproj"]
COPY ["dotnet-console.sln", "."]
RUN dotnet restore

COPY . .
RUN dotnet build "./dotnet-console/dotnet-console.csproj" -c Release -o /app/publish /flp:logfile=/logs/Build.log --no-restore

WORKDIR /src/unit
RUN dotnet test --logger "trx;LogFileName=UnitTests.trx" --results-directory /out/testresults /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=/out/testresults/coverage/

FROM scratch as testresults
COPY --from=build-test /out/testresults /out/testresults
COPY --from=build-test /logs /out/logs

FROM build as publish
RUN dotnet publish "./dotnet-console/dotnet-console.csproj" -c Release -o /app/publish --no-build

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "dotnet-console.dll"]