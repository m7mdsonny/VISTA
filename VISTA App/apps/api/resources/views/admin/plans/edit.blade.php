@extends('admin.layout')

@section('content')
<h2 class="text-xl font-semibold mb-6">تعديل الخطة</h2>

<form method="POST" action="{{ route('admin.plans.update', $plan->id) }}" class="bg-white rounded-2xl shadow-sm p-6 space-y-4">
    @csrf
    @method('PUT')

    <div>
        <label class="block text-sm text-slate-600 mb-2">اسم الخطة (عربي)</label>
        <input name="name_ar" value="{{ $plan->name_ar }}" class="w-full border rounded-xl p-3" required>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">عرض السعر</label>
        <input name="price_display_ar" value="{{ $plan->price_display_ar }}" class="w-full border rounded-xl p-3">
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">خصائص الخطة (JSON)</label>
        <textarea name="features_json" class="w-full border rounded-xl p-3" rows="6">{{ json_encode($plan->features_json, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) }}</textarea>
    </div>

    <div class="flex items-center gap-2">
        <input type="checkbox" name="is_active" {{ $plan->is_active ? 'checked' : '' }}>
        <span>الخطة نشطة</span>
    </div>

    <div>
        <label class="block text-sm text-slate-600 mb-2">الترتيب</label>
        <input name="sort" value="{{ $plan->sort }}" type="number" class="w-full border rounded-xl p-3">
    </div>

    <button class="bg-blue-600 text-white px-6 py-3 rounded-xl">حفظ التعديلات</button>
</form>
@endsection
