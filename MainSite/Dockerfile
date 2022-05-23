#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["MainSite/MainSite.csproj", "MainSite/"]
RUN dotnet restore "MainSite/MainSite.csproj"
COPY . .
WORKDIR "/src/MainSite"
RUN dotnet build "MainSite.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MainSite.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MainSite.dll"]