#  Webapp - Backend: Use the official DockerHub Node Alpine base image as the starting point
FROM node:14-alpine

# Install curl, git, npm and nginx on alpine image
RUN apk add curl && \
    apk add git && \
    apk add npm && \
    apk add nginx 

# create /home/webapp as the working directory
RUN mkdir -p /home/webapp
WORKDIR /home/webapp

# Install nvm, source nvm and use nvm version 16.20.2 and install angular/cli module
RUN curl -o install.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh && \
    sh /home/webapp/install.sh && \
    source ~/.nvm/nvm.sh && \
    nvm install 16.20.2 && \
    nvm use 16.20.2 && \
    npm install -g @angular/cli@16.2.10 && \
    npm install -g pm2

# Install and configure MySQL
RUN apk --no-cache add mysql mysql-client

# Clone your Node.js application repository
WORKDIR /home/webapp
RUN git clone https://github.com/techieinterest/web-app-deployment-on-cloud.git

# Install dependencies for your Node.js application
WORKDIR /home/webapp/web-app-deployment-on-cloud/backend
RUN npm install

# Create a directory for environment files
WORKDIR /home/webapp/web-app-deployment-on-cloud/backend/env

# Create a production environment file
RUN echo "PORT=5000" > production.env && \
    echo "DB_HOST='test-databaseq.caxdt0nmodrh.ap-south-1.rds.amazonaws.com'" >> production.env && \
    echo "DB_USER='admin'" >> production.env && \
    echo "DB_PASSWORD='Rakshit12*'" >> production.env && \
    echo "DB_NAME='webapp'" >> production.env

# Define the command to start your application
WORKDIR /home/webapp/web-app-deployment-on-cloud/backend
CMD ["pm2-runtime", "start", "npm", "--", "start", "--no-daemon"]
