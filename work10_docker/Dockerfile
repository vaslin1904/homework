#Dockerfile
FROM nginx:alpine
LABEL author="Ekaterina Galkina"
RUN apk update && apk add nginx;
COPY index.html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]