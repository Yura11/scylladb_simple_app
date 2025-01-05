FROM node:20-alpine AS builder

WORKDIR /client

COPY package.json package-lock.json ./

RUN npm install

COPY . .

RUN npm run build

# Use the official nginx image
FROM nginx:stable-alpine

# Copy the build files from the builder stage
COPY --from=builder /client/dist /usr/share/nginx/html

# Copy the custom nginx.conf into the container
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the port Nginx will listen on
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
