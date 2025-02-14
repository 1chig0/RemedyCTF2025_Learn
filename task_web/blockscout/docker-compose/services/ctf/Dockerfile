FROM node:lts
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm i
COPY . .
STOPSIGNAL 9
CMD ["node", "index.js"]