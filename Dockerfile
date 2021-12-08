FROM node:10-alpine
MAINTAINER Aaron Mueller <aaron.mueller@bylight.com>

# Set runtime environment
# The application populates process.env using dotenv.config - see server.js and logger.js for details.
ENV APP_ENV=production
ENV APP_NAME=slamr-api-gateway
ENV APP_LOCATION=/opt/slamr/slamr-api-gateway

# Setup envOverride config values using env_prefix
ENV SERVER_LOGGING_LEVEL=info
ENV SERVER_LOGFILE=${APP_NAME}-%DATE%.log
ENV SERVER_LOGPATH=/var/log/slamr/${APP_NAME}
ENV SERVER_LOGGING_DEBUG_MESSAGE_MAX_LENGTH=150
ENV SERVER_LOG_VERBOSE=false

ENV SERVER_PORT=5050
ENV SERVER_IP=ccr_api_gateway
ENV SERVER_USE_AUTHENTICATION=true
ENV SERVER_OPEN=true
ENV SERVER_REQ_TIMEOUT=10s

ENV AUTH_SERVER_HOST=ccr_auth_server
ENV AUTH_SERVER_PORT=8000
ENV AUTH_SERVER_ROUTE=/api/auth
ENV AUTH_SERVER_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBjeXN5c29uZS5uYXJyb3dndC5jb20iLCJpc3MiOiJodHRwczovL25hcnJvd2dhdGV0ZWNoLmNvbS8iLCJjeXN5c19yb2xlcyI6W10sImN5c3lzX2FkbWluIjp0cnVlLCJpYXQiOjE1NDUxMDkwMTUsImV4cCI6MTU1Mjg4NTAxNX0.hzXoy65hdV_BsTkK7eox0C6lhhGxjdMjkQ3qBpgCsz0

ENV JWT_SECRET=./cysys-ngt secret token

ENV RABBITMQ_USERNAME=radmin
ENV RABBITMQ_PASSWORD=radmin
ENV RABBITMQ_PORT=5672
ENV RABBITMQ_HOST=ccr_rabbitmq
ENV RABBITMQ_EXCH=SLAMREXCH
ENV RABBITMQ_HEARTBEAT=60
ENV RABBITMQ_RETRY_ATTEMPTS=20
ENV RABBITMQ_RETRY_INTERVAL=15000
ENV RABBITMQ_ORCH_SYNC_RESP_QUEUE=APIGW_OrchSync_Response_Queue
ENV RABBITMQ_ORCH_SYNC_RESP_ROUTE=apigateway.orchsync.response
ENV RABBITMQ_SYNC_RESP_QUEUE=APIGW_Sync_Response_Queue
ENV RABBITMQ_SYNC_RESP_ROUTE=apigateway.sync.response
ENV RABBITMQ_ASYNC_EVENT_LISTENER_QUEUE=APIGW_Async_Event_Listener_Queue
ENV RABBITMQ_ASYNC_EVENT_LISTENER_ROUTE=#.async.event
ENV RABBITMQ_MATRIX_RESP_QUEUE=APIGW_matrix_Response_Queue
ENV RABBITMQ_MATRIX_ROLE_RESP_QUEUE=APIGW_matrix_Role_Response_Queue
ENV RABBITMQ_MATRIX_RESP_ROUTE=apigateway.matrix.response
ENV RABBITMQ_LICENSE_LISTENER_QUEUE=APIGW_Licensing_Queue
ENV RABBITMQ_LICENSE_LISTENER_ROUTE=apigateway.licensing.role_response
ENV RABBITMQ_BLIND_QUEUE=APIGW_Blind_Queue
ENV RABBITMQ_MATRIX_ROLE_RESP_ROUTE=apigateway.matrix.role_response
ENV RABBITMQ_LOG_QUEUE=APIGW_Log_Queue
ENV RABBITMQ_LOG_ROUTE=#.log
ENV RABBITMQ_ATTACK_EVENT_QUEUE=APIGW_Attack_Event_Queue
ENV RABBITMQ_ATTACK_EVENT_ROUTE=*.attack_engine.*.message.event.emit
ENV RABBITMQ_STRUCTURED_EVENT_QUEUE=APIGW_Structured_Event_Queue
ENV RABBITMQ_STRUCTURED_EVENT_ROUTE=#.structured.event

ENV SOCKET_SERVER_PORT=5051

ENV POLICIES_DOMAIN=525e8010-57b8-4bd5-9220-2c7082266c56
ENV POLICIES_DEVICE=72acb4d0-a971-4ab6-933a-3461b75e3151
ENV POLICIES_ATTACK=e149f3df-a73a-4bc8-99fb-ba73ed0598b7
ENV POLICIES_TRAFFIC=4b559890-9d55-4029-91a6-c9f920650a10
ENV POLICIES_NETWORK=58bddb38-0426-47d8-992e-839e0dca12ae

ENV MATRIX_RETRY_ATTEMPTS=30
ENV MATRIX_RETRY_INTERVAL=10000

ENV LICENSE_RETRY_INTERVAL=1000
ENV LICENSE_ENGINEERING=0fbf5289-8f79-414d-aca3-cd620c06e177
ENV LICENSE_TYPES_BASE=7a0d8013-db5f-4a0a-b8ab-cef8ac02aed4
ENV LICENSE_TYPES_PROJECT_DESIGNER=b84d457f-6715-443c-b6da-f90b54fd1524
ENV LICENSE_TYPES_IMAGE_DESIGNER=3537ba93-08b3-4264-a35c-c0c7eb14e8f0
ENV LICENSE_TYPES_API=273d9b3e-16b8-4cdd-b64d-164c9c3d4168
ENV LICENSE_TYPES_DOMAIN=838f74da-1fe7-40eb-8571-389d6d5f2fdd
ENV LICENSE_TYPES_DOMAIN_U=6ad0f3c1-a475-4ad0-a3bc-0d4828e57e27
ENV LICENSE_TYPES_NODE=ca10b784-d66b-4bdf-9ab2-593d231f9256

ENV PATHS_IMAGE_MANAGER_IMPORT=/usr/local/share/slamr/transfer/imports/slamr-image-manager/
ENV PATHS_IMAGE_MANAGER_EXPORT=/usr/local/share/slamr/transfer/exports/slamr-image-manager/
ENV PATHS_COMPONENT_LIBRARY=/usr/local/share/slamr/transfer/imports/slamr-component-template-manager/

ENV DOWNLOAD_SERVER_BASE_PATH=/usr/local/share/slamr
ENV DOWNLOAD_SERVER_PORT=3100
ENV DOWNLOAD_SERVER_TARGETS_PLAYBOOK=/usr/local/share/slamr/transfer/export/playbooks
ENV DOWNLOAD_SERVER_TARGETS_ATTACK_PLAN=/usr/local/share/slamr/transfer/export/attackplans
ENV DOWNLOAD_SERVER_TARGETS_TRAFFIC_PROFILE=/usr/local/share/slamr/transfer/exports/slamr-traffic-manager
ENV DOWNLOAD_SERVER_TARGETS_DEVICE=/usr/local/share/slamr/transfer/exports/slamr-virtual-device-agent
ENV DOWNLOAD_SERVER_TARGETS_PROJECT_DESIGNER=/usr/local/share/slamr/transfer/exports/slamr-project-manager

# Set working directory
WORKDIR /opt/slamr/temp
COPY . /opt/slamr/temp

# Install dependencies, move build output to final location, and clean-up
RUN npm install && \
    npm run build && \
    node --version && \
    npm --version && \
    mkdir -p ${APP_LOCATION} && \
    cp -R /opt/slamr/temp/build/. ${APP_LOCATION} && \
    rm -rf /opt/slamr/temp

## The following fails with:
##   ADD failed: stat /var/lib/docker/tmp/docker-builder770651755/opt/slamr/temp/build: no such file or directory
#ADD /opt/slamr/temp/build/. /opt/slamr/slamr-api-gateway

WORKDIR ${APP_LOCATION}
ENTRYPOINT /usr/bin/node ${APP_LOCATION}/bin/server.js