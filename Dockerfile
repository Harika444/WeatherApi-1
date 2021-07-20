FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
EXPOSE 80
#COPY --from=build-env /app/out .
COPY ./weatherapi/out .
ENTRYPOINT ["dotnet", "weatherapi.dll"]
