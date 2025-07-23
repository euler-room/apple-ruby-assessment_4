# Weather Info Application

A Ruby on Rails application that provides weather information, containerized with Docker for easy deployment.

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- Git (to clone the repository)

### Running the Application

This project includes a `weather-app` management script that simplifies all Docker operations. Here's how to get started:

1. **Clone the repository:**
```bash
git clone https://github.com/euler-room/apple-ruby-assessment_4.git
cd apple-ruby-assessment_4
```

2. **Generate a master key (first time only):**
```bash
openssl rand -hex 32 > config/master.key
chmod 600 config/master.key
```

3. **Start the application:**
```bash
./weather-app start
```

The application will automatically:
- Pull the latest Docker image from Docker Hub
- Start the container with proper configuration
- Be available at http://localhost:3000

### Managing the Application

The `weather-app` script provides all the commands you need:

```bash
# Check if the application is running
./weather-app status

# View application logs (real-time)
./weather-app logs

# Stop the application
./weather-app stop

# Restart the application
./weather-app destroy
./weather-app start

# Build from source (if you made code changes)
./weather-app build
```

### Complete Command Reference

| Command | Description |
|---------|-------------|
| `./weather-app start` | Pull latest image and start the container |
| `./weather-app stop` | Stop the running container |
| `./weather-app status` | Check container status |
| `./weather-app logs` | View and follow container logs |
| `./weather-app destroy` | Stop and remove the container |
| `./weather-app cleanup` | Remove container and all images (requires re-download) |
| `./weather-app build` | Build the Docker image locally from source |

## Docker Hub

The application is available as a pre-built Docker image on Docker Hub:

```bash
docker pull gbuchanan/weather_info:latest
```

### Running with Docker Directly

If you prefer to run the container directly without the management script:

```bash
# Create a master key file if you don't have one
echo "your-secret-key-here" > config/master.key

# Run the container
docker run -d \
  -p 3000:3000 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e SECRET_KEY_BASE=$(cat config/master.key) \
  --name weather_info \
  gbuchanan/weather_info:latest
```

## Building from Source

### Prerequisites

- Docker
- Docker Compose (optional)
- Git

### Build Steps

1. Clone the repository:
```bash
git clone https://github.com/euler-room/apple-ruby-assessment_4.git
cd apple-ruby-assessment_4
```

2. Build the Docker image:
```bash
./weather-app build
# OR
docker build -t weather_info .
```

3. Run the application:
```bash
./weather-app start
```

## Configuration

### Master Key

The application requires a Rails master key for production. The management script will look for this in `config/master.key`. 

To generate a new master key:
```bash
openssl rand -hex 32 > config/master.key
chmod 600 config/master.key
```

**Important**: Never commit the master key to version control!

### Environment Variables

The Docker container accepts the following environment variables:

- `RAILS_MASTER_KEY` - Required: The Rails master key for decrypting credentials
- `SECRET_KEY_BASE` - Required: Secret key base for the application (can be the same as RAILS_MASTER_KEY)
- `PORT` - Optional: Port to run the application on (default: 3000)

## Development

### Local Development

For local development without Docker:

1. Install Ruby 3.4.2
2. Install dependencies:
```bash
bundle install
yarn install
```

3. Set up the database:
```bash
rails db:create db:migrate
```

4. Run the server:
```bash
rails server
```

### Docker Development

The Dockerfile is optimized for production use. For development, you can:

1. Build a local image:
```bash
./weather-app build
```

2. Run with volume mounts for live code updates:
```bash
docker run -d \
  -p 3000:3000 \
  -v $(pwd):/rails \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e SECRET_KEY_BASE=$(cat config/master.key) \
  --name weather_info_dev \
  weather_info:latest
```

## Deployment

The application is configured for production deployment with:

- Optimized multi-stage Docker build
- Minimal final image size
- Non-root user for security
- Pre-compiled assets
- Database migrations run during build

### Deploy to Production

1. Pull the latest image:
```bash
docker pull gbuchanan/weather_info:latest
```

2. Run with production configuration:
```bash
docker run -d \
  -p 80:3000 \
  -e RAILS_MASTER_KEY=your-production-master-key \
  -e SECRET_KEY_BASE=your-production-secret-key \
  --name weather_info_prod \
  --restart unless-stopped \
  gbuchanan/weather_info:latest
```

## Troubleshooting

### Common Issues with weather-app Script

#### Docker not running
If you see "Cannot connect to Docker daemon":
```bash
# Make sure Docker Desktop is running
# On Windows/Mac: Start Docker Desktop from your applications
# On Linux: sudo systemctl start docker
```

#### Permission denied
If you get "Permission denied" when running `./weather-app`:
```bash
# Make the script executable
chmod +x weather-app
```

#### Container won't start
Check what's happening:
```bash
# View the logs
./weather-app logs

# Check container status
./weather-app status

# Try destroying and restarting
./weather-app destroy
./weather-app start
```

### Master key issues

If you see errors about missing or invalid master key:
```bash
# Check if master.key exists
ls -la config/master.key

# If not, create it
openssl rand -hex 32 > config/master.key
chmod 600 config/master.key

# Restart the application
./weather-app destroy
./weather-app start
```

### Port already in use

If port 3000 is already in use:
```bash
# Find what's using port 3000
lsof -i :3000
# OR on Windows
netstat -ano | findstr :3000

# Option 1: Stop the conflicting service
# Option 2: Modify the weather-app script to use a different port
# Option 3: Stop all containers and restart
./weather-app destroy
./weather-app start
```

### Updating to Latest Version

To get the latest version of the application:
```bash
# Pull latest code
git pull origin main

# Clean up old images
./weather-app cleanup

# Start fresh
./weather-app start
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is part of an assessment and may have specific licensing terms.
