# دليل التشغيل المحلي

## المتطلبات
- PHP 8.2+
- Composer
- MySQL
- Redis

## إعداد التطبيق
```bash
cd "VISTA App/apps/api"
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate --seed
```

## تشغيل الخادم
```bash
php artisan serve
```

## Horizon
```bash
php artisan horizon
```

## Scheduler
```bash
php artisan schedule:work
```

## ملاحظات
- يمكن تعطيل إرسال الإشعارات من إعدادات الإدارة.
- بيانات EGX الحالية عبر المزود التجريبي فقط.
