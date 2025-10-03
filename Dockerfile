# Use the official .NET 8 runtime as a parent image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CicdPocApp.csproj", "./"]
RUN dotnet restore "CicdPocApp.csproj"
COPY . .
RUN dotnet build "CicdPocApp.csproj" -c Release -o /app/build

# Publish the app
FROM build AS publish
RUN dotnet publish "CicdPocApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create a non-root user
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

ENTRYPOINT ["dotnet", "CicdPocApp.dll"]
