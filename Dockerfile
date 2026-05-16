# Get the iii-engine binary from the official iiidev/iii image
FROM iiidev/iii:0.11.2 AS iii-binary

# Final image: Debian bookworm (glibc) + node + iii-engine + node_modules
FROM debian:bookworm-slim

# Install tini and node from NodeSource
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    ca-certificates \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy iii-engine binary
COPY --from=iii-binary /app/iii /app/iii

# Copy built dist and node_modules
COPY dist/ ./dist/
COPY node_modules/ ./node_modules/

# Expose ports
EXPOSE 49134 3111 3112 3113 9464

# Run as non-root
RUN addgroup --gid 65532 appgroup && adduser --disabled-password --gecos "" --uid 65532 --gid 65532 appuser
USER appuser

ENTRYPOINT ["/usr/bin/tini", "--", "/app/iii", "--config", "/app/config.yaml"]
