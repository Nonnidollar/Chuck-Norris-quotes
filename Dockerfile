FROM node:10-alpine

# Create app directory
RUN mkdir -p /app

WORKDIR /app

# Install app dependencies
COPY app/package.json app/package-lock.json ./

RUN npm install

# Bundle app source
COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]

