@extends('admin.layout')

@section('content')
<div class="grid gap-6">
    <div class="bg-white rounded-2xl shadow-sm p-6">
        <h2 class="text-lg font-semibold mb-2">نظرة عامة</h2>
        <p class="text-slate-600">هذه لوحة تحكم عربية بالكامل لإدارة الخطط والإعدادات بدون أي تدخل في إشارات الأسهم.</p>
    </div>
    <div class="grid md:grid-cols-3 gap-4">
        <div class="bg-white rounded-2xl shadow-sm p-5">
            <div class="text-sm text-slate-500">الإشارات اليوم</div>
            <div class="text-2xl font-bold">{{ $todaySignals }}</div>
        </div>
        <div class="bg-white rounded-2xl shadow-sm p-5">
            <div class="text-sm text-slate-500">المستخدمون النشطون</div>
            <div class="text-2xl font-bold">{{ $activeUsers }}</div>
        </div>
        <div class="bg-white rounded-2xl shadow-sm p-5">
            <div class="text-sm text-slate-500">الاشتراكات</div>
            <div class="text-2xl font-bold">{{ $subscriptions }}</div>
        </div>
    </div>
</div>
@endsection
