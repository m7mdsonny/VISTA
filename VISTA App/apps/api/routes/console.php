<?php

use Illuminate\Support\Facades\Artisan;

Artisan::command('vista:health', function () {
    $this->info('Vista API console is ready.');
});
