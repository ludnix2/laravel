<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'Hello, Laravel! This is a custom response.',
        'status' => 'success'
    ]);
});
