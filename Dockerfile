#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["dotnet-console.csproj", "."]
RUN dotnet restore "./dotnet-console.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "dotnet-console.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dotnet-console.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-console.dll"]