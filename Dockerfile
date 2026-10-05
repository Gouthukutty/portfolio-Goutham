FROM nginx:alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy portfolio files
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# Optional JavaScript is embedded in index.html in the current portfolio,
# but copy it if present so the image remains compatible with future edits.
COPY script.js /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
