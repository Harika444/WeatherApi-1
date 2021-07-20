# Get Base Image (Full .NET Core SDK)
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

# Copy csproj and restore
COPY ./weatherapi/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY ./weatherapi ./
RUN dotnet publish -c Release -o out

# Generate runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
EXPOSE 80
COPY --from=build-env /app/out .
#COPY ./weatherapi/out .
ENTRYPOINT ["dotnet", "weatherapi.dll"]
