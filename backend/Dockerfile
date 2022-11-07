FROM node:16-alpine AS backend-build
WORKDIR /usr/src/app/backend
COPY ./package*.json ./
RUN npm install
COPY ./config.js ./
COPY ./index.js ./

EXPOSE 8080
CMD ["npm", "start"]
