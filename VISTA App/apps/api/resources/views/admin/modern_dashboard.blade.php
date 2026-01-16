<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>لوحة التحكم - Vista</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Alexandria:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Alexandria', sans-serif; }
        
        /* Smooth Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes slideIn {
            from { transform: translateX(-20px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        
        .animate-fade-in {
            animation: fadeIn 0.5s ease-out;
        }
        
        .animate-slide-in {
            animation: slideIn 0.5s ease-out;
        }
        
        /* Hover Effects */
        .metric-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .metric-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
        
        /* Gradient Background */
        .gradient-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        /* Glassmorphism */
        .glass-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body class="bg-gradient-to-br from-gray-50 to-gray-100 min-h-screen">
    <!-- Header -->
    <header class="bg-white shadow-sm sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4 space-x-reverse">
                    <div class="w-10 h-10 rounded-lg gradient-bg flex items-center justify-center">
                        <span class="text-white font-bold text-xl">V</span>
                    </div>
                    <div>
                        <h1 class="text-xl font-bold text-gray-900">لوحة تحكم Vista</h1>
                        <p class="text-sm text-gray-500">نظام تحليل السوق المصرية</p>
                    </div>
                </div>
                <div class="flex items-center space-x-4 space-x-reverse">
                    <button class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors">
                        تحديث البيانات
                    </button>
                    <a href="{{ route('admin.logout') }}" class="text-gray-600 hover:text-gray-900">
                        تسجيل الخروج
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-6 py-8">
        <!-- Metrics Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <!-- Active Users -->
            <div class="metric-card bg-white rounded-xl shadow-md p-6 animate-fade-in" style="animation-delay: 0.1s">
                <div class="flex items-center justify-between mb-4">
                    <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                        <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
                        </svg>
                    </div>
                    <span class="text-xs font-semibold text-green-600 bg-green-100 px-2 py-1 rounded-full">+12%</span>
                </div>
                <h3 class="text-sm font-medium text-gray-500 mb-1">المستخدمون النشطون</h3>
                <p class="text-3xl font-bold text-gray-900">{{ number_format($activeUsers) }}</p>
                <p class="text-xs text-gray-400 mt-2">مع اشتراكات نشطة</p>
            </div>

            <!-- Trial Users -->
            <div class="metric-card bg-white rounded-xl shadow-md p-6 animate-fade-in" style="animation-delay: 0.2s">
                <div class="flex items-center justify-between mb-4">
                    <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                        <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-sm font-medium text-gray-500 mb-1">المستخدمون في التجربة</h3>
                <p class="text-3xl font-bold text-gray-900">{{ number_format($trialUsers) }}</p>
                <p class="text-xs text-gray-400 mt-2">فترة تجربة مجانية</p>
            </div>

            <!-- Signals Today -->
            <div class="metric-card bg-white rounded-xl shadow-md p-6 animate-fade-in" style="animation-delay: 0.3s">
                <div class="flex items-center justify-between mb-4">
                    <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                        <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-sm font-medium text-gray-500 mb-1">الإشارات اليوم</h3>
                <p class="text-3xl font-bold text-gray-900">{{ number_format($todaySignals) }}</p>
                <p class="text-xs text-gray-400 mt-2">إشارات تم توليدها اليوم</p>
            </div>

            <!-- Data Health -->
            <div class="metric-card bg-white rounded-xl shadow-md p-6 animate-fade-in" style="animation-delay: 0.4s">
                <div class="flex items-center justify-between mb-4">
                    <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                        <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-sm font-medium text-gray-500 mb-1">صحة البيانات</h3>
                <p class="text-3xl font-bold text-gray-900">{{ $dataHealth }}%</p>
                <div class="mt-2 bg-gray-200 rounded-full h-2">
                    <div class="bg-gradient-to-r from-green-400 to-green-600 h-2 rounded-full transition-all duration-500" style="width: {{ $dataHealth }}%"></div>
                </div>
            </div>
        </div>

        <!-- Charts Section -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <!-- User Growth Chart -->
            <div class="bg-white rounded-xl shadow-md p-6 animate-slide-in">
                <h3 class="text-lg font-bold text-gray-900 mb-4">نمو المستخدمين (آخر 30 يوم)</h3>
                <canvas id="userGrowthChart" height="200"></canvas>
            </div>

            <!-- Signals Trend Chart -->
            <div class="bg-white rounded-xl shadow-md p-6 animate-slide-in" style="animation-delay: 0.2s">
                <h3 class="text-lg font-bold text-gray-900 mb-4">اتجاه الإشارات (آخر 7 أيام)</h3>
                <canvas id="signalsTrendChart" height="200"></canvas>
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-4">النشاط الأخير</h3>
            <div class="space-y-4">
                @forelse($recentActivity as $activity)
                <div class="flex items-center space-x-4 space-x-reverse p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                    <div class="w-10 h-10 bg-indigo-100 rounded-full flex items-center justify-center">
                        <span class="text-indigo-600 font-semibold">{{ substr($activity->action, 0, 1) }}</span>
                    </div>
                    <div class="flex-1">
                        <p class="font-medium text-gray-900">{{ $activity->action }}</p>
                        <p class="text-sm text-gray-500">{{ $activity->user->name ?? 'System' }} • {{ $activity->created_at->diffForHumans() }}</p>
                    </div>
                </div>
                @empty
                <p class="text-center text-gray-500 py-8">لا توجد أنشطة حديثة</p>
                @endforelse
            </div>
        </div>
    </main>

    <script>
        // User Growth Chart
        const userCtx = document.getElementById('userGrowthChart');
        new Chart(userCtx, {
            type: 'line',
            data: {
                labels: {!! json_encode($userGrowth->pluck('date')->toArray()) !!},
                datasets: [{
                    label: 'المستخدمون',
                    data: {!! json_encode($userGrowth->pluck('count')->toArray()) !!},
                    borderColor: 'rgb(99, 102, 241)',
                    backgroundColor: 'rgba(99, 102, 241, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                }
            }
        });

        // Signals Trend Chart
        const signalsCtx = document.getElementById('signalsTrendChart');
        new Chart(signalsCtx, {
            type: 'bar',
            data: {
                labels: {!! json_encode($signalTrend->pluck('date')->toArray()) !!},
                datasets: [{
                    label: 'الإشارات',
                    data: {!! json_encode($signalTrend->pluck('count')->toArray()) !!},
                    backgroundColor: 'rgba(16, 185, 129, 0.8)',
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                }
            }
        });
    </script>
</body>
</html>
