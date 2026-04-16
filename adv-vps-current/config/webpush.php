<?php

return [
    'model' => NotificationChannels\WebPush\PushSubscription::class,

    'table_name' => env('WEBPUSH_DB_TABLE', 'push_subscriptions'),

    'vapid' => [
        'subject' => env('VAPID_SUBJECT'),
        'public_key' => env('VAPID_PUBLIC_KEY'),
        'private_key' => env('VAPID_PRIVATE_KEY'),
    ],

    'gcm' => [
        'key' => env('GCM_KEY'),
        'sender_id' => env('GCM_SENDER_ID'),
    ],

    'ttl' => env('WEBPUSH_TTL', 2419200),

    'urgency' => env('WEBPUSH_URGENCY', 'normal'),

    'topic' => env('WEBPUSH_TOPIC'),

    'batch_size' => env('WEBPUSH_BATCH_SIZE', 1000),

    'proxy' => env('WEBPUSH_PROXY'),

    'client_options' => [],
];
