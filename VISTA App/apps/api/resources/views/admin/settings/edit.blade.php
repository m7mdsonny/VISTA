@extends('admin.layout')

@section('content')
<h2 class="text-xl font-semibold mb-6">الإعدادات العامة</h2>

@if(session('status'))
    <div class="bg-green-50 text-green-700 p-3 rounded-xl mb-4">{{ session('status') }}</div>
@endif

<form method="POST" action="{{ route('admin.settings.update') }}" class="bg-white rounded-2xl shadow-sm p-6 space-y-4">
    @csrf
    @method('PUT')

    <div>
        <label class="block text-sm text-slate-600 mb-2">مدة التجربة المجانية (أيام)</label>
        <input name="trial_days" value="{{ $settings['trial_days']['days'] ?? 14 }}" type="number" class="w-full border rounded-xl p-3" required>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">Feature Flags (JSON)</label>
        <textarea name="feature_flags" class="w-full border rounded-xl p-3" rows="5">{{ json_encode($settings['feature_flags'] ?? [], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">أوزان التحليل (JSON)</label>
        <textarea name="analysis_weights" class="w-full border rounded-xl p-3" rows="5">{{ json_encode($settings['analysis_weights'] ?? [], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">حدود التحليل (JSON)</label>
        <textarea name="analysis_thresholds" class="w-full border rounded-xl p-3" rows="5">{{ json_encode($settings['analysis_thresholds'] ?? [], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">قواعد التنبيهات (JSON)</label>
        <textarea name="notification_rules" class="w-full border rounded-xl p-3" rows="5">{{ json_encode($settings['notification_rules'] ?? [], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">النصوص القانونية (JSON)</label>
        <textarea name="legal_texts" class="w-full border rounded-xl p-3" rows="4">{{ json_encode($settings['legal_texts'] ?? [], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">البنرات (JSON)</label>
        <textarea name="banners" class="w-full border rounded-xl p-3" rows="3">{{ json_encode($settings['banners'] ?? [], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">وضع الصيانة (JSON)</label>
        <textarea name="maintenance" class="w-full border rounded-xl p-3" rows="3">{{ json_encode($settings['maintenance'] ?? [], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <button class="bg-blue-600 text-white px-6 py-3 rounded-xl">حفظ الإعدادات</button>
</form>
@endsection
