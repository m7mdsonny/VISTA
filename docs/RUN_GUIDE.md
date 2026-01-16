# Run Guide - Vista Egyptian AI Market Analysis App

## Prerequisites

### Backend Requirements

- **PHP**: 8.2 or higher
- **Composer**: Latest version
- **MySQL**: 8.0 or higher
- **Redis**: 7.0 or higher (optional but recommended for queues/cache)
- **Node.js & NPM**: Latest LTS (for frontend assets if needed)

### Mobile App Requirements

- **Flutter**: Latest stable version (3.x or higher)
- **Dart**: Included with Flutter
- **Xcode**: Latest version (for iOS development, macOS only)
- **Android Studio**: Latest version with Android SDK (for Android development)
- **CocoaPods**: Latest version (for iOS dependencies)

### Development Tools

- **Git**: For version control
- **Docker** (optional): For containerized development environment
- **Postman/Insomnia**: For API testing

## Initial Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd vista
```

### 2. Backend Setup

#### Install Dependencies

```bash
cd apps/api
composer install
```

#### Environment Configuration

```bash
cp .env.example .env
php artisan key:generate
```

#### Configure `.env` File

```env
APP_NAME="Vista"
APP_ENV=local
APP_KEY=base64:...
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vista
DB_USERNAME=root
DB_PASSWORD=

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Admin defaults (change after first login)
ADMIN_DEFAULT_EMAIL=admin@vista.app
ADMIN_DEFAULT_PASSWORD=ChangeThisPassword123!

# Apple App Store (for subscription verification)
APPLE_SHARED_SECRET=your-apple-shared-secret

# Google Play (for subscription verification)
GOOGLE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}

# FCM (for push notifications)
FCM_SERVER_KEY=your-fcm-server-key

QUEUE_CONNECTION=redis
CACHE_DRIVER=redis
SESSION_DRIVER=redis
```

#### Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE vista CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# Run migrations
php artisan migrate

# Seed database (creates default roles, plans, admin user)
php artisan db:seed
```

#### Storage Setup

```bash
php artisan storage:link
```

### 3. Mobile App Setup

#### Install Flutter Dependencies

```bash
cd apps/mobile
flutter pub get
```

#### iOS Setup (macOS only)

```bash
cd ios
pod install
cd ..
```

#### Configure API Base URL

Create/update `apps/mobile/lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000'; // Development
  // static const String baseUrl = 'https://api.vista.app'; // Production
}
```

## Running the Application

### Backend (Laravel API)

#### Development Server

```bash
cd apps/api
php artisan serve
```

Server runs on `http://localhost:8000`

#### Queue Worker (Horizon)

**Option 1: Horizon Dashboard (Recommended)**

```bash
cd apps/api
php artisan horizon
```

Horizon dashboard: `http://localhost:8000/horizon`

**Option 2: Queue Worker (Alternative)**

```bash
cd apps/api
php artisan queue:work redis --tries=3 --timeout=90
```

#### Scheduler

**Option 1: Schedule Work (Development)**

```bash
cd apps/api
php artisan schedule:work
```

**Option 2: Cron Job (Production)**

Add to crontab:
```bash
* * * * * cd /path/to/apps/api && php artisan schedule:run >> /dev/null 2>&1
```

#### Admin Dashboard

Access at: `http://localhost:8000/admin/login`

Default credentials (from `.env`):
- Email: `ADMIN_DEFAULT_EMAIL`
- Password: `ADMIN_DEFAULT_PASSWORD`

**⚠️ CHANGE DEFAULT PASSWORD AFTER FIRST LOGIN**

### Mobile App (Flutter)

#### Android

```bash
cd apps/mobile

# List available devices
flutter devices

# Run on Android device/emulator
flutter run -d <device-id>

# Or run on first available device
flutter run
```

#### iOS (macOS only)

```bash
cd apps/mobile

# Run on iOS simulator
flutter run -d iPhone

# Or run on connected iOS device
flutter run -d <device-id>
```

#### Run with Specific Configuration

```bash
# Debug mode (default)
flutter run --debug

# Release mode (performance optimized)
flutter run --release

# Profile mode (performance profiling)
flutter run --profile
```

## Services Overview

### Laravel Horizon

**Purpose**: Queue management dashboard and workers

**Access**: `http://localhost:8000/horizon`

**Features**:
- Monitor queue jobs
- View failed jobs
- Retry failed jobs
- Job statistics

**Configuration**: `apps/api/config/horizon.php`

### Redis

**Purpose**: Cache, session storage, queue backend

**Start Redis**:

```bash
# macOS (Homebrew)
brew services start redis

# Linux
sudo systemctl start redis

# Docker
docker run -d -p 6379:6379 redis:alpine
```

**Test Connection**:

```bash
redis-cli ping
# Should return: PONG
```

### MySQL

**Purpose**: Primary database

**Start MySQL**:

```bash
# macOS (Homebrew)
brew services start mysql

# Linux
sudo systemctl start mysql

# Docker
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mysql:8.0
```

**Test Connection**:

```bash
mysql -u root -p
```

## Common Development Tasks

### Run Migrations

```bash
cd apps/api
php artisan migrate

# Rollback last migration
php artisan migrate:rollback

# Rollback all migrations
php artisan migrate:reset

# Fresh migration (drop all tables and re-migrate)
php artisan migrate:fresh --seed
```

### Seed Database

```bash
cd apps/api

# Seed all seeders
php artisan db:seed

# Seed specific seeder
php artisan db:seed --class=SubscriptionPlanSeeder

# Fresh seed (migrate + seed)
php artisan migrate:fresh --seed
```

### Clear Caches

```bash
cd apps/api

# Clear all caches
php artisan optimize:clear

# Clear specific caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Generate Test Data

```bash
cd apps/api

# Generate test stocks (if factory exists)
php artisan tinker
>>> Stock::factory()->count(50)->create();

# Generate test signals (if factory exists)
>>> Signal::factory()->count(100)->create();
```

### Run Tests

```bash
cd apps/api

# Run all tests
php artisan test

# Run specific test
php artisan test --filter SignalEngineTest

# Run with coverage
php artisan test --coverage
```

### Flutter Tests

```bash
cd apps/mobile

# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Docker Development (Optional)

### Docker Compose Setup

```yaml
# docker-compose.yml (example)
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: vista
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

volumes:
  mysql_data:
```

### Run with Docker

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f
```

## Production Deployment

### Backend Deployment

#### Server Requirements

- PHP 8.2+ with extensions (mbstring, openssl, pdo_mysql, redis, etc.)
- Nginx or Apache
- MySQL 8.0+
- Redis 7.0+
- Supervisor (for queue workers)
- Cron (for scheduler)

#### Deployment Steps

1. **Clone Repository**

```bash
git clone <repository-url>
cd vista/apps/api
```

2. **Install Dependencies**

```bash
composer install --optimize-autoloader --no-dev
```

3. **Configure Environment**

```bash
cp .env.example .env
# Edit .env with production values
php artisan key:generate
```

4. **Run Migrations**

```bash
php artisan migrate --force
php artisan db:seed --class=SubscriptionPlanSeeder
```

5. **Optimize**

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

6. **Setup Supervisor** (for Horizon)

```ini
# /etc/supervisor/conf.d/vista-horizon.conf
[program:vista-horizon]
process_name=%(program_name)s
command=php /path/to/apps/api/artisan horizon
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/path/to/logs/horizon.log
```

7. **Setup Cron**

```bash
* * * * * cd /path/to/apps/api && php artisan schedule:run >> /dev/null 2>&1
```

#### Nginx Configuration

```nginx
server {
    listen 80;
    server_name api.vista.app;
    root /path/to/apps/api/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### Mobile App Deployment

#### Android

```bash
cd apps/mobile

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS

```bash
cd apps/mobile

# Build iOS app
flutter build ios --release

# Archive in Xcode
# Product → Archive → Upload to App Store
```

## CI/CD Pipeline (GitHub Actions)

### Backend CI

**File**: `.github/workflows/backend-ci.yml`

```yaml
name: Backend CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: vista
        ports:
          - 3306:3306
      redis:
        image: redis:alpine
        ports:
          - 6379:6379
    steps:
      - uses: actions/checkout@v3
      - uses: php-actions/composer@v6
      - name: Run tests
        run: php artisan test
```

### Mobile CI

**File**: `.github/workflows/mobile-ci.yml`

```yaml
name: Mobile CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - name: Run tests
        run: flutter test
      - name: Build APK
        run: flutter build apk --release
```

## Troubleshooting

### Backend Issues

**Queue Jobs Not Processing**:
- Check Redis connection: `redis-cli ping`
- Restart Horizon: `php artisan horizon:terminate`
- Check queue connection in `.env`: `QUEUE_CONNECTION=redis`

**Migrations Failing**:
- Check database credentials in `.env`
- Ensure database exists: `mysql -u root -p -e "SHOW DATABASES;"`
- Drop and re-migrate: `php artisan migrate:fresh --seed`

**Admin Dashboard Not Loading**:
- Clear caches: `php artisan optimize:clear`
- Check session driver: `SESSION_DRIVER=redis` or `file`
- Verify admin user exists: `php artisan tinker` → `User::whereHas('roles', fn($q) => $q->where('name', 'admin'))->count()`

### Mobile Issues

**API Connection Errors**:
- Check API base URL in `api_config.dart`
- Verify backend is running: `curl http://localhost:8000/api/v1/market/summary`
- Check CORS configuration in `config/cors.php`

**Build Errors**:
- Clean build: `flutter clean && flutter pub get`
- Check Flutter version: `flutter --version`
- Update dependencies: `flutter pub upgrade`

**iOS Build Issues**:
- Update CocoaPods: `cd ios && pod repo update && pod install`
- Check Xcode version: `xcodebuild -version`
- Clean Xcode build folder: Product → Clean Build Folder

## Environment Variables Reference

### Backend (.env)

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_KEY` | Laravel encryption key | `base64:...` |
| `DB_DATABASE` | Database name | `vista` |
| `DB_USERNAME` | Database user | `root` |
| `DB_PASSWORD` | Database password | `password` |
| `REDIS_HOST` | Redis host | `127.0.0.1` |
| `ADMIN_DEFAULT_EMAIL` | Default admin email | `admin@vista.app` |
| `ADMIN_DEFAULT_PASSWORD` | Default admin password | `ChangeThis123!` |
| `APPLE_SHARED_SECRET` | Apple App Store shared secret | `abc123...` |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | Google Play service account JSON | `{"type":...}` |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging server key | `AAAA...` |

### Mobile (api_config.dart)

| Variable | Description | Example |
|----------|-------------|---------|
| `baseUrl` | API base URL | `http://localhost:8000` |

## Additional Resources

- **Laravel Documentation**: https://laravel.com/docs
- **Flutter Documentation**: https://flutter.dev/docs
- **Horizon Documentation**: https://laravel.com/docs/horizon
- **Redis Documentation**: https://redis.io/docs
- **MySQL Documentation**: https://dev.mysql.com/doc
