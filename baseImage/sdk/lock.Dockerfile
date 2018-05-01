#Becomes: ${REGISTRY_NAME}microsoft/dotnet:2.1-sdk
FROM microsoft/dotnet-nightly:2.1-sdk
ADD ./nugetcache.csproj /tmp/warmup/nugetcache.csproj
RUN dotnet restore /tmp/warmup/nugetcache.csproj \
        --source https://dotnet.myget.org/F/dotnet-core/api/v3/index.json \
        --source https://api.nuget.org/v3/index.json \
        --verbosity quiet
