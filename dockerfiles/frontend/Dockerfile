# Webapp - Frontend Use the official dockerhub node aplpne base image as the starting point
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
    npm install -g @angular/cli@16.2.10
	
# Create a directory for your Node.js application
WORKDIR /home/webapp
RUN git clone https://github.com/techieinterest/web-app-deployment-on-cloud.git

#Install node modules as mentioned in package.json in the client folder
WORKDIR /home/webapp/web-app-deployment-on-cloud/client
RUN npm install


WORKDIR /home/webapp/web-app-deployment-on-cloud/client/src/environments
RUN echo "export const environment = {" > environment.prod.ts && \
    echo "production: true," >> environment.prod.ts && \
    echo "apiUrl: 'http://back.devopsify.co.in:5000/api/v1/'," >> environment.prod.ts && \
    echo "};" >> environment.prod.ts

# Copy nginx.conf file from /home/webapp/web-app-deployment-on-cloud/nginx.conf
RUN cp /home/webapp/web-app-deployment-on-cloud/nginx.conf /etc/nginx/nginx.conf

WORKDIR /home/webapp/web-app-deployment-on-cloud/client/
RUN ng build --prod

CMD ["nginx", "-g", "daemon off;"]
