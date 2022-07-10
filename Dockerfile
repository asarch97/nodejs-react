FROM node:16-alpine AS frontend-build
WORKDIR /usr/src/app
COPY frontend/ ./frontend/
RUN cd frontend && npm install && npm run build

FROM node:16-alpine AS backend-build
WORKDIR /root/
COPY --from=frontend-build /usr/src/app/frontend/build ./frontend/build
COPY backend/package*.json ./backend/
RUN cd backend && npm install
COPY backend/index.js ./backend/

CMD ["node", "./backend/index.js"]
