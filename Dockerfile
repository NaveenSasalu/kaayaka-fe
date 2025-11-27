### Stage 1 - Build
FROM node:18-alpine as builder
WORKDIR /app

# 1. Copy dependency files first (for caching)
COPY package.json package-lock.json ./

# 2. Install dependencies 
RUN npm install 

# 3. Copy rest of the code
COPY . .

# 4. Build Next.js
RUN npm run build

### Stage 2 - Runtime
FROM node:18-alpine as runner

WORKDIR /app

# 1. Copy dependency files first (for caching)
COPY package.json package-lock.json ./

# 2. Install dependencies 
RUN npm install --production

# 3. Copy the .next production build output from builder stage
COPY --from=builder /app/.next .next
COPY --from=builder /app/public public
COPY --from=builder /app/node_modules node_modules

# 4. Set environment to production
ENV NODE_ENV=production

# 5. Expose port 3000
EXPOSE 3000

# 6. Start the Next.js server
CMD ["npm", "start"]

