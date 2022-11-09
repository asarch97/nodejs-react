FROM node:16-alpine AS frontend-build
WORKDIR /usr/src/app/frontend
COPY ./frontend/package*.json ./frontend/
COPY ./frontend/public/ ./frontend/public
COPY ./frontend/src/ ./frontend/src
RUN npm install && npm run build

EXPOSE 3000
CMD ["npm", "start"]
