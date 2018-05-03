#Becomes: ${REGISTRY_NAME}baseimages/microsoft/aspnetcore-runtime:linux-2.1 AS base
# digest: jengademos.azurecr.io/microsoft/dotnet@sha256:b1f3bf53ae60d00c059a8d5f15ede7fc69d5f20d3b417ceaacb5c5c2302b7d9e
ARG REGISTRY_NAME
FROM ${REGISTRY_NAME}microsoft/dotnet:2.1-aspnetcore-runtime
# switch the base image to simulate a valid docker build
#   but a broken runtime the cluster will catch
#FROM node:9-alpine
# Simulates minor differences - can be viewed on the about page
ARG A_IMAGE_BUILD_DATE
ENV IMAGE_BUILD_DATE=$A_IMAGE_BUILD_DATE
# Change to simulate an obvious change in the base image
# View on the about page
ENV BACKGROUND_COLOR=Azure
