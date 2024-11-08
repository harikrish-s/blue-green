FROM nginx:alpine
COPY html /usr/share/nginx/html
ENV DEPLOYMENT_TIME="unknown"
ENV ENVIRONMENT="unknown"
