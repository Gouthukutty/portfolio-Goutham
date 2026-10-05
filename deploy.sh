#!/bin/bash
set -e

cd ~/goutham-portfolio

echo "Pulling latest portfolio image..."
docker compose pull

echo "Starting updated portfolio container..."
docker compose up -d

echo "Removing unused Docker images..."
docker image prune -f

echo "Deployment completed."
docker ps --filter "name=goutham-portfolio"
