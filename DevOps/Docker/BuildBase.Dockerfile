# docker build --file ../DevOps/Docker/BuildBase.Dockerfile -t buildbase --build-arg certPassword=test123 .

# must add ARG _before_ FROM to allow a calling Dockerfile to override the value, otherwise only --build-arg will work since that sets the arg everywhere
ARG PROJECT_NAME

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-test
ARG certPassword
WORKDIR /src

RUN openssl genrsa -des3 -passout pass:${certPassword} -out server.key 2048 && \
    openssl rsa -passin pass:${certPassword} -in server.key -out server.key && \
    openssl req -sha256 -new -key server.key -out server.csr -subj '/CN=loyal-health-service' && \
    openssl x509 -req -sha256 -days 3650 -in server.csr -signkey server.key -out server.crt && \
    openssl pkcs12 -export -out cert.pfx -inkey server.key -in server.crt -passout pass:${certPassword}


# repeat ARG to get it into the build-test image
ONBUILD ARG PROJECT_NAME

ONBUILD COPY . .

ONBUILD RUN dotnet build $PROJECT_NAME -c Release -o /app/publish /flp:logfile=/logs/Build.log

ONBUILD WORKDIR /src/unit
ONBUILD RUN dotnet test --logger "trx;LogFileName=UnitTests.trx" \
                        --results-directory /test \
                        /p:CollectCoverage=true \
                        /p:CoverletOutputFormat=cobertura \
                        /p:CoverletOutput=/test/coverage/
