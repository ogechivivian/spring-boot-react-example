#Build with Node
FROM node:18 AS build

#needed for Node+OpenSSL issues
ENV NODE_OPTIONS=--openssl-legacy-provider

WORKDIR /app

#Copying the package.json + lock files
COPY package*.json ./
RUN npm install


# Copying the source (including webpack.config.js)
COPY src ./src
COPY webpack.config.js ./

#Run the build
RUN npm run build

#Serving with Nginx
FROM nginx:alpine

# Copy final compiled files from build stage
COPY --from=build /app/target/classes/static/built /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]





