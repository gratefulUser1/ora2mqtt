FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

COPY libgwmapi/ ./libgwmapi/
COPY ora2mqtt/ ./ora2mqtt/
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    RID=linux-musl-x64 ; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    RID=linux-musl-arm64 ; \
    elif [ "$TARGETARCH" = "arm" ]; then \
    RID=linux-musl-arm ; \
    fi \
    && dotnet publish -c Release -o out -r $RID --sc ora2mqtt/ora2mqtt.csproj
COPY openssl.cnf ./out/

FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine
WORKDIR /app
COPY --from=build-env /app/out .

ENTRYPOINT ["/app/ora2mqtt"]