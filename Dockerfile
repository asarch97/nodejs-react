FROM node:18-apline AS frontend-build
WORKDIR /usr/src/app
COPY frontend/ ./frontend/
RUN cd frontend && npm install && npm run build

FROM node:18-alpine AS backend-build
WORKDIR /root/
COPY --from=frontend-build /usr/src/app/frontend/build ./frontend/build
COPY backend/package*.json ./backend/
RUN cd backend && npm install
COPY backend/index.js ./backend/

EXPOSE 3080
CMD ["node", "./backend/index.js"]
