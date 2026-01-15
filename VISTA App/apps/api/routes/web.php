<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json(['message' => 'Vista API']);
});

Route::get('/admin', function () {
    return view('admin.dashboard');
});
