# docker build --file ../DevOps/Docker/TestOnBuild.Dockerfile --target testresults --output 'type=local,dest=../out' .
# docker build --file ../DevOps/Docker/TestOnBuild.Dockerfile .


ARG PROJECT_NAME="./dotnet-console.sln" # this is used

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base

# not used ARG PROJECT_NAME="./dotnet-console/dOtnet-console.csproj"

FROM buildbase AS build-test
# not used ARG PROJECT_NAME="./dotnet-console/Dotnet-console.csproj"

FROM base AS final
WORKDIR /app

COPY --from=build-test /src/cert.pfx .
RUN openssl pkcs12 -in cert.pfx -password pass:test123 -nokeys

COPY --from=build-test /app/publish .

ENTRYPOINT ["dotnet", "dotnet-console.dll"]