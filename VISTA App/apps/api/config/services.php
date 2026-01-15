<?php

return [
    'fcm' => [
        'project_id' => env('FCM_PROJECT_ID'),
        'client_email' => env('FCM_CLIENT_EMAIL'),
        'private_key' => env('FCM_PRIVATE_KEY'),
    ],
    'apple_iap' => [
        'shared_secret' => env('APPLE_IAP_SHARED_SECRET'),
    ],
    'google_play' => [
        'service_account_json' => env('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'),
    ],
];
