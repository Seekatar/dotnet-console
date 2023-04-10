# docker build --file ../DevOps/Docker/BuildBase.Dockerfile -t buildbase .

# must add ARG _before_ FROM to allow a calling Dockerfile to override the value, otherwise only --build-arg will work since that sets the arg everywhere
ARG PROJECT_NAME

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-test
WORKDIR /src

# repeat ARG to get it into the build-test image
ONBUILD ARG PROJECT_NAME

ONBUILD COPY . .

ONBUILD RUN echo Building $PROJECT_NAME && dotnet build $PROJECT_NAME -c Release -o /app/publish /flp:logfile=/logs/Build.log

ONBUILD WORKDIR /src/unit
ONBUILD RUN dotnet test --logger "trx;LogFileName=UnitTests.trx" \
                        --results-directory /test \
                        /p:CollectCoverage=true \
                        /p:CoverletOutputFormat=cobertura \
                        /p:CoverletOutput=/test/coverage/
