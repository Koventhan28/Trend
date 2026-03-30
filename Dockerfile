FROM nginx:latest
WORKDIR /usr/share/nginx/html
RUN mkdir -p /var/cache/nginx /run && \
    chown -R nginx:nginx /var/cache/nginx /etc/nginx/conf.d /run
COPY default.conf /etc/nginx/conf.d/default.conf
COPY /dist .
USER nginx
EXPOSE 3000
CMD [ "nginx", "-g","daemon off;"  ]

