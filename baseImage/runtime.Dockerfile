ARG BASE_IMAGE_VERSION
# switch the base image to simulate a valid docker build
#   but a broken runtime the cluster will catch
FROM microsoft/dotnet-nightly:${BASE_IMAGE_VERSION}-aspnetcore-runtime
#FROM node:9-alpine
# added a second time to ensure the arg is in scope in this stage
ARG BASE_IMAGE_VERSION 
ARG IMAGE_BUILD_DATE
# Simulates minor differences - can be viewed on the about page
ENV BASE_IMAGE_VERSION=${BASE_IMAGE_VERSION}
ENV IMAGE_BUILD_DATE=${IMAGE_BUILD_DATE}
# Change to simulate an obvious change in the base image
# View on the about page
ENV BACKGROUND_COLOR=White
