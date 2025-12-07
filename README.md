# WordPress Docker Environment

Production-ready WordPress development environment with Docker. Single command setup.

## Quick Start

```bash
git clone <repository-url>
cd wp-my-project
./start.sh
```

The script will:
- Extract WordPress from included archive
- Prompt for ports configuration
- Generate `.env` with credentials
- Start Docker containers

Access WordPress at the configured port and follow installation wizard.

## Project Structure

```
.
├── docker-compose.yml         # Docker configuration
├── upload.ini                # PHP settings (256MB upload limit)
├── start.sh                  # Setup and start script
├── stop.sh                   # Stop and cleanup script
├── wordpress-6.9-ru_RU.zip   # WordPress archive (tracked in git)
└── wordpress/                # WordPress files (not tracked)
    ├── wp-content/
    ├── wp-admin/
    └── wp-includes/
```

## Configuration

All settings are managed through `.env` file (auto-generated on first run):

- `WORDPRESS_PORT` - WordPress port (default: 8082)
- `PHPMYADMIN_PORT` - phpMyAdmin port (default: 8083)
- `MYSQL_PORT` - MySQL external port (default: 3337)
- `PROJECT_NAME` - Docker containers prefix
- `MYSQL_ROOT_PASSWORD` - Auto-generated
- `MYSQL_PASSWORD` - Auto-generated

## Management

**Start/Restart:**
```bash
./start.sh
```

**Stop:**
```bash
./stop.sh
```

Options:
1. Stop containers (preserve data)
2. Stop and remove all data
3. Reset configuration (for port changes)

**Direct Docker commands:**
```bash
docker-compose down              # Stop
docker-compose down -v           # Stop and remove data
docker-compose logs -f wordpress # View logs
docker-compose restart           # Restart
```

## PHP Configuration

Current settings:
- PHP Memory limit: 512MB (`upload.ini`)
- WordPress Memory limit: 512MB (`WP_MEMORY_LIMIT`)
- Max upload: 256MB
- POST max: 256MB
- Max execution time: 600s

Edit `upload.ini` and restart:
```bash
docker-compose restart wordpress
```

WordPress memory limits are configured via `WORDPRESS_CONFIG_EXTRA` in `docker-compose.yml`.

## Database Access

**phpMyAdmin:**
- URL: `http://localhost:{PHPMYADMIN_PORT}`
- User: `root`
- Password: Check `.env` → `MYSQL_ROOT_PASSWORD`

**External connection:**
```
Host: localhost
Port: {MYSQL_PORT from .env}
Database: wordpress
User: wordpress
Password: {MYSQL_PASSWORD from .env}
```

## New Project Setup

**Method 1: Clone existing project**
```bash
git clone <repo-url> my-new-project
cd my-new-project
./start.sh
```

**Method 2: Copy directory**
```bash
cp -r wp-my-project my-new-project
cd my-new-project
rm -f .env .env.configured
rm -rf wordpress
./start.sh
```

## Theme Development

WordPress files are in `wordpress/` directory (not tracked in git).

**Development workflow:**
1. Create theme in `wordpress/wp-content/themes/my-theme/`
2. Edit files directly (changes apply immediately via volume mount)
3. For git tracking, maintain theme in separate repository

## WordPress Updates

To use different WordPress version:
1. Download archive from https://wordpress.org/download/
2. Name it `wordpress-*.zip`
3. Place in project root
4. Run `./start.sh`

## Troubleshooting

**WordPress not found:**
```bash
ls -la wordpress-*.zip
```
Download from https://wordpress.org/download/ if missing.

**Port conflicts:**
Script automatically detects and prompts for alternative ports.

**Permission issues:**
```bash
sudo chown -R $(whoami):$(whoami) wordpress/
```

**Complete reset:**
```bash
./stop.sh  # Select option 2
rm -rf wordpress
rm -f .env .env.configured
./start.sh
```

## Git Configuration

**Tracked in git:**
- `docker-compose.yml`
- `upload.ini`
- `start.sh`, `stop.sh`
- `wordpress-*.zip` (WordPress archive)

**Not tracked:**
- `.env` (credentials)
- `.env.configured` (setup flag)
- `wordpress/` (generated from archive)

## Requirements

- Docker Desktop
- Docker Compose
- Bash
- unzip

## Workflow

1. Clone repository
2. Run `./start.sh`
3. Install WordPress via browser
4. Develop theme in `wordpress/wp-content/themes/`
5. Stop with `./stop.sh`
