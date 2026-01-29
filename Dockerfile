++ Dockerfile
FROM nginx:alpine

# remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# copy static files
COPY public/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
