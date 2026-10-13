# Stage 1: Build & Dependencies
FROM node:18-alpine AS builder

WORKDIR /app

# Tận dụng Layer Caching: Copy package files trước
COPY package*.json ./
RUN npm install --only=production

COPY . .

# Stage 2: Minimal Runtime Environment
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Chỉ copy artifact và dependencies cần thiết từ builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/server.js ./server.js

EXPOSE 3000

USER node

CMD ["node", "server.js"]
