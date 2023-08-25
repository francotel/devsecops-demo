FROM public.ecr.aws/docker/library/node:18.17

# Variables
ENV SOURCE_FOLDER=./node-app

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY ${SOURCE_FOLDER}/package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --omit=dev

# Bundle app source
COPY ${SOURCE_FOLDER} .

EXPOSE 8080
CMD [ "node", "server.js" ]