# Stage 1: Build the React App
FROM node:18 AS build

# Create and switch to an app directory in the container
WORKDIR /app

# Copy package.json and package-lock.json from the project root (one level up)
COPY ../../package*.json ./

# Install dependencies
RUN npm install

# Copy the React source code from src/main/js
COPY src/main/js ./

# Build the React app
RUN npm run build

# Stage 2: Serve the React build with Nginx
FROM nginx:alpine

# Copy the build output from Stage 1
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
