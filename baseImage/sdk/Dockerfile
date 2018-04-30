ARG BASE_IMAGE_VERSION
FROM microsoft/dotnet-nightly:${BASE_IMAGE_VERSION}-sdk

ADD ./nugetcache.csproj /tmp/warmup/nugetcache.csproj
RUN dotnet restore /tmp/warmup/nugetcache.csproj \
        --source https://dotnet.myget.org/F/dotnet-core/api/v3/index.json \
        --source https://api.nuget.org/v3/index.json \
        --verbosity quiet

# added a second time to ensure the arg is in scope in this stage
ARG BASE_IMAGE_VERSION 
ARG IMAGE_BUILD_DATE
ENV BASE_IMAGE_VERSION=${BASE_IMAGE_VERSION}
ENV IMAGE_BUILD_DATE=${IMAGE_BUILD_DATE}
