FROM nginx:alpine
COPY html /usr/share/nginx/html
COPY health.html /usr/share/nginx/html
ENV DEPLOYMENT_TIME="unknown"
ENV ENVIRONMENT="unknown"
RUN echo "Server is running" > /usr/share/nginx/html/health.html