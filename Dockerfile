FROM node:16-alpine AS frontend-build
WORKDIR /usr/src/app/frontend
COPY ./frontend/package*.json ./
COPY ./frontend/public/ ./public
COPY ./frontend/src/ ./src
RUN npm install && npm run build

EXPOSE 3000
CMD ["npm", "start"]

