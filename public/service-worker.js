const CACHE_NAME = 'ptc-v1';
const ASSETS = [
    '/',
    '/index.html',
    '/manifest.json',
    '/img/icons/icon-192-maskable.png',
    '/img/icons/icon-512-maskable.png'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(ASSETS))
    );
});

self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => response || fetch(event.request))
    );
});
