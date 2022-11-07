FROM node:16-alpine AS frontend-build
WORKDIR /usr/src/app/frontend
COPY ./package*.json ./
COPY ./public/ ./public
COPY ./src/ ./src
RUN npm install && npm run build

EXPOSE 3000
CMD ["npm", "start"]
