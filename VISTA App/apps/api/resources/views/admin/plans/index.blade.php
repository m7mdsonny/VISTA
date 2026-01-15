@extends('admin.layout')

@section('content')
<div class="flex items-center justify-between mb-6">
    <h2 class="text-xl font-semibold">إدارة الخطط</h2>
</div>

@if(session('status'))
    <div class="bg-green-50 text-green-700 p-3 rounded-xl mb-4">{{ session('status') }}</div>
@endif

<div class="bg-white rounded-2xl shadow-sm overflow-hidden">
    <table class="w-full text-right">
        <thead class="bg-slate-50 text-slate-500">
            <tr>
                <th class="p-4">الكود</th>
                <th class="p-4">الاسم</th>
                <th class="p-4">السعر</th>
                <th class="p-4">نشط</th>
                <th class="p-4">الإجراءات</th>
            </tr>
        </thead>
        <tbody>
            @foreach($plans as $plan)
                <tr class="border-t">
                    <td class="p-4">{{ $plan->code }}</td>
                    <td class="p-4">{{ $plan->name_ar }}</td>
                    <td class="p-4">{{ $plan->price_display_ar }}</td>
                    <td class="p-4">{{ $plan->is_active ? 'نعم' : 'لا' }}</td>
                    <td class="p-4">
                        <a href="{{ route('admin.plans.edit', $plan->id) }}" class="text-blue-600">تعديل</a>
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
