FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY src/ ./src/

# Non-root user for security
RUN addgroup -S flowgate && adduser -S flowgate -G flowgate
USER flowgate

EXPOSE 3000

CMD ["node", "src/server.js"]
