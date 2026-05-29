FROM node:lts-alpine3.23 AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:1.31.1-alpine-slim

RUN apk update && apk upgrade --no-cache curl libxml2 freetype

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
