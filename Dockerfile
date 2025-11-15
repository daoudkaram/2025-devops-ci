# Build Stage

FROM node:20-alpine AS builder

# Enable corepack so pnpm works
RUN corepack enable

WORKDIR /app

# Copy only files needed to install deps
COPY package.json pnpm-lock.yaml ./

#Install all deps for build
RUN pnpm install --frozen-lockfile

# Copy the rest of the source code 
COPY . .

# Build the app
RUN pnpm build

# Runtime stage
FROM node:20-alpine AS runner

ENV NODE_ENV=production
RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --prod --frozen-lockfile

COPY --from=builder /app/.output ./.output

# Create a non root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

# Start the prod server
CMD ["pnpm","start"]
