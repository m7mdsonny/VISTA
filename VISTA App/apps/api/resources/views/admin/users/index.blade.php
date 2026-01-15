@extends('admin.layout')

@section('content')
<h2 class="text-xl font-semibold mb-6">المستخدمون والاشتراكات</h2>

<div class="bg-white rounded-2xl shadow-sm overflow-hidden">
    <table class="w-full text-right">
        <thead class="bg-slate-50 text-slate-500">
            <tr>
                <th class="p-4">الاسم</th>
                <th class="p-4">البريد</th>
                <th class="p-4">الأدوار</th>
                <th class="p-4">الاشتراك</th>
            </tr>
        </thead>
        <tbody>
            @foreach($users as $user)
                <tr class="border-t">
                    <td class="p-4">{{ $user->name }}</td>
                    <td class="p-4">{{ $user->email }}</td>
                    <td class="p-4">
                        {{ $user->roles->pluck('label_ar')->join('، ') }}
                    </td>
                    <td class="p-4">
                        {{ optional($subscriptions->get($user->id)->first())->status ?? '—' }}
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
