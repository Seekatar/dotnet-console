FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["src/dotnet-console/dotnet-console.csproj", "src/dotnet-console/"]
RUN dotnet restore "src/dotnet-console/dotnet-console.csproj"
COPY . .
WORKDIR "/src/src/dotnet-console"
RUN dotnet build "dotnet-console.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dotnet-console.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-console.dll"]
