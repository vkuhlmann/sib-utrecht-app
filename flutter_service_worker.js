'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "64edb91684bdb3b879812ba2e48dd487",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "f87e541501c96012c252942b6b75d1ea",
"canvaskit/skwasm.wasm": "4124c42a73efa7eb886d3400a1ed7a06",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"main.dart.js": "d77b28fb1563a6c2a48bb16a6de3a138",
"favicon.png": "2215758d02e593b60b1ec633cf598465",
"favicon.ico": "bb7cb4742469658dc454dc7dff174e84",
"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"index.html": "065dab6bee1e691427c0987c90e67756",
"/": "065dab6bee1e691427c0987c90e67756",
"version.json": "b89606084ee61d141a00dbec198c2df1",
"assets/AssetManifest.bin.json": "e0a6a887b8400ce776cf8fdd7f2538ab",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "f2163b9d4e6f1ea52063f498c8878bb9",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/fonts/MaterialIcons-Regular.otf": "dce1798e15a86093b087d1eb3ec8040b",
"assets/AssetManifest.bin": "c2627858cf8e004cae9ebc18849873b5",
"assets/AssetManifest.json": "047db6066901a6ec8ee10d20bedad5e0",
"assets/FontManifest.json": "58b67160e3f62283221234dbbef38178",
"assets/NOTICES": "ac509b3996fef9654b54b361c0271140",
"assets/assets/dual_screen-LICENSE.txt": "d4a904ca135bb7bc912156fee12726f0",
"assets/assets/fonts/RobotoMono/static/RobotoMono-Regular.ttf": "7e173cf37bb8221ac504ceab2acfb195",
"assets/assets/fonts/RobotoMono/static/RobotoMono-Bold.ttf": "0339b745f10bb01da181af1cdc33c361",
"assets/assets/fonts/RobotoMono/LICENSE.txt": "d273d63619c9aeaf15cdaf76422c4f87",
"assets/assets/fonts/Roboto/Roboto-BoldItalic.ttf": "fd6e9700781c4aaae877999d09db9e09",
"assets/assets/fonts/Roboto/Roboto-Bold.ttf": "b8e42971dec8d49207a8c8e2b919a6ac",
"assets/assets/fonts/Roboto/Roboto-Italic.ttf": "cebd892d1acfcc455f5e52d4104f2719",
"assets/assets/fonts/Roboto/LICENSE.txt": "d273d63619c9aeaf15cdaf76422c4f87",
"assets/assets/fonts/Roboto/Roboto-Regular.ttf": "8a36205bd9b83e03af0591a004bc97f4",
"assets/assets/sib_logo_64.png": "07be6f30716bb2829113b607c5b8606d",
"assets/assets/LICENSE.txt": "b9fcccad43929ce3000ffc486a46333b",
"icons/Icon-512.png": "74ee3897be03a4bf4e3eaef6a60ca846",
"icons/maskable_icon_x72.png": "e26b8adbae25c6dc8b7914bb60a61d22",
"icons/maskable_icon_x192.png": "316e9ea049204d91e10b00e0138bf623",
"icons/maskable_icon.png": "1d6369787363e253bdd8764442c03046",
"icons/Icon-192.png": "5ebd4978fe2e913e1b9e7b1231332d9a",
"icons/Logo-highres-1536x1536.png": "8b18c7e1cda83a3626636aeb10d10b8c",
"icons/Icon-maskable-512.png": "180ec6a8526126afc86a6bd88b71db37",
"icons/Icon-maskable-192.png": "316e9ea049204d91e10b00e0138bf623",
"icons/old/maskable_icon_x72.png": "29ccb6339fd7831945d4f27131b5404a",
"icons/old/maskable_icon_x192.png": "a9569cee1b4de4130ecf837883e641f9",
"icons/old/maskable_icon.png": "b38fd29942936ad60780803042342b7f",
"icons/old/Icon-maskable-512.png": "07d8caa3677b92be9300c71177e0d238",
"icons/old/Icon-maskable-192.png": "6857e0ba7c63ebb0c3fb62d5f8c8b320",
"icons/old/maskable_icon_x48.png": "1c0b4203f1eb1cf072aba54faf9c5be8",
"icons/old/maskable_icon_x512.png": "d0b0debcdab003c93e0c7e3017385280",
"icons/maskable_icon_x512.png": "180ec6a8526126afc86a6bd88b71db37",
"manifest.json": "bcc6f6a8d87fc44665939e803399d98a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
