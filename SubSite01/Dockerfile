#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["SubSite01/SubSite01.csproj", "SubSite01/"]
RUN dotnet restore "SubSite01/SubSite01.csproj"
COPY . .
WORKDIR "/src/SubSite01"
RUN dotnet build "SubSite01.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SubSite01.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SubSite01.dll"]