# Get Base Image (Full .NET Core SDK)
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

ARG TOKEN
RUN dotnet nuget add source https://daxeos-921881026300.d.codeartifact.us-west-2.amazonaws.com/nuget/dax-coreinfra-dev-codeartifact-uswest2-daxeos/v3/index.json --name dev --password $TOKEN --username aws --store-password-in-clear-text

# Copy csproj and restore
COPY ./weatherapi/*.csproj ./
RUN dotnet restore


# Copy everything else and build
COPY ./weatherapi ./
RUN dotnet pack
RUN dotnet nuget push bin/Debug/weatherapi.1.0.0.nupkg --source dev --skip-duplicate
RUN dotnet publish -c Release -o out

# Generate runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
EXPOSE 80
COPY --from=build-env /app/out .
#COPY ./weatherapi/out .
#CMD ["dotnet", "weatherapi.dll"]

