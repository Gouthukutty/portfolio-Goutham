# Goutham D Portfolio — Docker + GitHub Actions + Docker Hub + EC2 + Nginx

## Architecture

Developer
   |
   v
GitHub main
   |
   v
GitHub Actions
   |
   +--> Validate files
   |
   +--> Build Docker image
   |
   +--> Push image to Docker Hub
   |
   v
SSH to EC2
   |
   +--> docker compose pull
   +--> docker compose up -d
   |
   v
127.0.0.1:8080
   |
   v
EC2 Nginx reverse proxy :80
   |
   v
Internet

## Repository files

- index.html
- style.css
- script.js
- Dockerfile
- docker-compose.yml
- .github/workflows/ci-cd.yml
- deploy.sh
- nginx/goutham-portfolio.conf

## IMPORTANT: change the Docker Hub username

In:
- .github/workflows/ci-cd.yml
- docker-compose.yml

the image is:
DOCKERHUB_USERNAME/goutham-portfolio:latest

GitHub Actions reads the username from the GitHub secret. On EC2, create a .env file:

DOCKERHUB_USERNAME=your_dockerhub_username

## EC2 first-time setup

Ubuntu example:

sudo apt update
sudo apt install -y docker.io docker-compose-plugin nginx
sudo systemctl enable --now docker
sudo systemctl enable --now nginx

Then:

mkdir -p ~/goutham-portfolio
cd ~/goutham-portfolio

Copy docker-compose.yml here.

Create .env:

nano .env

DOCKERHUB_USERNAME=your_dockerhub_username

Test:

docker compose pull
docker compose up -d

The portfolio container listens only on:
127.0.0.1:8080

This is intentional. Internet traffic should enter through host Nginx.

## Host Nginx

Copy nginx/goutham-portfolio.conf to:

/etc/nginx/sites-available/goutham-portfolio

Then:

sudo ln -s /etc/nginx/sites-available/goutham-portfolio /etc/nginx/sites-enabled/goutham-portfolio

Remove the default site if needed:

sudo rm -f /etc/nginx/sites-enabled/default

Edit server_name in the config:
- use your domain, OR
- use your EC2 public IP for initial testing.

Check:

sudo nginx -t
sudo systemctl reload nginx

## GitHub Secrets

Repository -> Settings -> Secrets and variables -> Actions

Create:

DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
EC2_HOST
EC2_USERNAME
EC2_SSH_KEY

EC2_SSH_KEY is the private SSH key used to connect to the instance.

Do NOT commit the private key, Docker Hub token, .env, or other credentials.

## EC2 SSH user

For Ubuntu AMI:
EC2_USERNAME=ubuntu

For Amazon Linux:
EC2_USERNAME=ec2-user

Use the username appropriate for your EC2 AMI.

## Security Group

For the Nginx reverse proxy:
- TCP 80 -> 0.0.0.0/0
- TCP 443 -> 0.0.0.0/0 if HTTPS is configured
- TCP 22 -> preferably your IP only

Do NOT expose port 8080 publicly. The compose mapping binds it to 127.0.0.1.

## HTTPS

After the HTTP deployment works, add HTTPS with Certbot:

sudo apt install -y certbot python3-certbot-nginx

Then:

sudo certbot --nginx -d yourdomain.com

Only do this after DNS points your domain to the EC2 public IP.

## How updates work

1. Change portfolio code locally.
2. git add .
3. git commit -m "Update portfolio"
4. git push origin main.
5. GitHub Actions validates the repository.
6. GitHub Actions builds the Docker image.
7. GitHub Actions pushes goutham-portfolio:latest to Docker Hub.
8. GitHub Actions SSHs into EC2.
9. EC2 runs docker compose pull.
10. EC2 recreates/updates the container.
11. Nginx continues reverse-proxying traffic to 127.0.0.1:8080.

This follows the deployment pattern of the supplied TaskFlow CI/CD workflow.
