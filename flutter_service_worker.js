'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "cfeb16504315621e8965df3fe6f59a17",
"version.json": "b7528f207cd24d09f55f23b45b4672f8",
"index.html": "62a9fca9f5a713d1769b04706ae8abfe",
"/": "62a9fca9f5a713d1769b04706ae8abfe",
"main.dart.js": "295b46087b3802db34a37468cf12334c",
"404.html": "62a9fca9f5a713d1769b04706ae8abfe",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "b876c5554de228b762a4e2546df14758",
"icons/Icon-192.png": "fa577f3a512c340bd5b3f09fd7c5e3c0",
"icons/Icon-maskable-192.png": "fa577f3a512c340bd5b3f09fd7c5e3c0",
"icons/Icon-maskable-512.png": "95b997b14f79c91e6b0535d334c47f07",
"icons/Icon-512.png": "95b997b14f79c91e6b0535d334c47f07",
"manifest.json": "1b2323d70ce739ce03dfd1e8e397cdf2",
".git/config": "94d74568eb9499e17f5d70139d1f4e60",
".git/objects/0c/d5ce167bb980f3a61266b11f8364309eaa4758": "c47a1e024bde6c729cd40791d9a7ed55",
".git/objects/50/28a8304721d6ab6af1d73bfa5b1fdc9a3ff0c7": "cb45e16b2b089a6e37cf6b69365c212b",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/69/e4a79682bcee16ee2c0f495deb7acc5dc50b84": "27843da34e794363e5031063e8278c67",
".git/objects/51/3f7d201b94cb89ff0eefaad9ea5407f30e9b31": "4dcc6929b2ad50012b070a38ef652d78",
".git/objects/34/d6e6ab4d19c1446b815f7f7beb01f8cb0c91c1": "aa55d8b3e4e9d19d9bad8b32d52baed3",
".git/objects/5a/a5b321427f7098e822e2f89a0a7527b0ae4568": "831f8165f0e090c4aacae252f455a20b",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/ad/1c1788048ff84965e16f50d2291d83bd2aef2d": "da219482caa752d9d4d926f8415180d9",
".git/objects/ad/06629e7808836fa507eeb32771510a79dd1295": "d997ae62e9ce0265ab948ae7df2dafdc",
".git/objects/df/9cbd44a09aa1d722dc7bc6107d5fef1bf8f66f": "14ef1019ebf5ca4c1df55ceb42875b2e",
".git/objects/df/8d45db49b6ee39d0783b9323ecc00209632a30": "95f36ffc9eccd938e2feeef32da189fa",
".git/objects/a2/0197a9db9d721eb213c1de7daf314dfaa02af1": "df2e4191064aa9679906ea55522d2e23",
".git/objects/a5/43593d75601e52c9f56f404b14749ccff38c4e": "2541f603dcf6a368547a1d1d4fd4353a",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/cf/ffd059851f8eb8b0d74f130ebb9b1b5df69b73": "092a50473bc648091a579d3dc806e0f9",
".git/objects/ed/ce58a42e2d4af8a88bec9207494377a05e5a4c": "9ca652cf4d903620a2177311d91245da",
".git/objects/c6/eb4eb0792b222ac6efc0a9fa69fb60d784a804": "ba58a5fb9a498db36fa7757f3dd6cf3c",
".git/objects/4e/31335df34768e50d87c2c428f99efe95a53a37": "694f7fe62e1349286a2b30585ee1075b",
".git/objects/7d/bb3642f9a429f75a4cb53e84009c22dd90b2e3": "98ecb18680f7d0b5ddd208544c906595",
".git/objects/7c/3ff14033a826d41578028e44e0be8f0e2fed3b": "1855493f0b40427df10b0cdaa7c2172b",
".git/objects/45/d6ccc11635219c768d7c4be638238babe63e3b": "133e9c66593faaeda85e1feb15db800e",
".git/objects/45/fb23014fc1e50f37cc0293a77bc3ab9047516d": "da421640505bddd4e60f598aa14b55b1",
".git/objects/8f/c8be62f202c40e7d3e2e16242fb065cfc4e1a7": "6fda1b80da67a8d96186cf8ab8b24087",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/7e/461630099f1d1687b2b8666be11d4628397e08": "7dbdf6fb69f83260d5c10412af03e118",
".git/objects/19/8de09ee1f6f54da92d04b6b4d9761c799d3ee5": "b9edaaf7211b934f0ca3f19558eb00e2",
".git/objects/75/da28681c1b34faf3a0279d3ceda0c24ffd58c9": "a8c450fdc2339128427a64982b0d5bb2",
".git/objects/81/0d7371a6df397946a7f8dab9f3878c22097be3": "71b9653b82dad61e3f10d5fa87b3c71a",
".git/objects/72/74955172f58efc48bc1d3da82e1d2d73a443ab": "20070775bd58a0987fa01fe605ca588a",
".git/objects/07/d48718b624a45d4399b96d7145bb90c8fbd98c": "de4266fc0a810104a3816a283e40e45e",
".git/objects/91/75ccdc49bb3c348134aa6d08ea1730b5af1cfb": "3ba2ae8d602a1fb5ec0cff6d34fa1d33",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/98/001f8429113eeb6b474640d286fcdac3e6d09a": "b0cef4b6ce642b182032b96bf952b19e",
".git/objects/3f/e49997613054c6de5e1178eba7ca84df87b258": "25354f89b1b2590466835e6d38806909",
".git/objects/6d/d3f238e5baa5d6fc7a36662945d308ac575b36": "334ea4bfa9e9a5d0a0a411a4bf0704ac",
".git/objects/01/360198a990fc3d3af0ad23eb5fba9b934276b6": "f3a78d476e50eb960f4c32ff07a01117",
".git/objects/0f/01a756b369f13f3eeef758a6e82a765a2b680d": "bb486d7fd4f6c6b56db54c76e7bd9d26",
".git/objects/64/db5530fb076d9a122d0abde79e6b6f491fa3e3": "3107870ab3ff9176e8a3e77fea22a157",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/ba/badf9426502b6714170bd777fc2ab7f1b732a2": "6f81e1659110a4d67032e059f3a7a54f",
".git/objects/dd/2d5691c5d103c9449a6e324010ade0e253fee1": "95267835ca120efa20c90c17ef4c2a8d",
".git/objects/b6/3615e93dbaf683c9ba65bd0af0eae6a3053ef6": "fffcfdcccc9ebf4ceaa97c63a2eb9d15",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/b9/0e503c0944d8e26d2e8e73055448bc38411ac0": "b4db1eacc613bc1c7ae7828c65863d79",
".git/objects/a1/14eb1b85749983b2496bcddde387563da2e1db": "66851931f1d46f9c5d9c2b77d8a381ad",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/c4/c70d51537119071c31157bd38a06aa369daf36": "ae85f1ea106862371369364eb4bf4476",
".git/objects/cc/fd4362d16b2fa3a0dbcfb65ea63c97a8e30ab5": "b975d67eb0ef5993c35ac8f7430916a4",
".git/objects/e6/cc1238dbc0b7ccf7f9688c5ed49177fcfbf8c9": "9cc5a5efdd3c45e2b3243d052fb3b9f1",
".git/objects/e0/2329c1a2bb3648fdc1db738fbfb983b709b42c": "8c02a695cea07705d776929b1c81c5ec",
".git/objects/83/322043caddbdf358ed1d12895bd1005b2edbbb": "19254a8c9cea8f76ad4dc74fe9fb5fd8",
".git/objects/4f/e272059b6df694f40c5249aacaa2abc5b4b614": "ad5592d803d3f1096815e45f2271a29a",
".git/objects/12/7dc7aec194638732f081b03af0090eb5dead4d": "60e99ee2842772199040a6bd2a2e5bf4",
".git/objects/1d/63b035ef24b1ed10cffa7ac612475ba9eba0b2": "434f3ed6bae32e7e1674147bf605ad15",
".git/objects/1d/468b85698a60041b450286f31b3264b3bbd6f7": "5c8c497111befde32ac151f14cf92f85",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "5b017b8c1380b310cfb8850dc1ce2b53",
".git/logs/refs/heads/gh-pages": "5b017b8c1380b310cfb8850dc1ce2b53",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/gh-pages": "0ee2b647f548b5ecd34d3022e495c15e",
".git/index": "f3f46e8c23ee17ea1ee2256be5a93871",
".git/COMMIT_EDITMSG": "8439beb8b1732c0a2985d22d90c57484",
".git/FETCH_HEAD": "d41d8cd98f00b204e9800998ecf8427e",
"assets/AssetManifest.json": "06770345285a856c298e484640a93de2",
"assets/NOTICES": "83a9fa5f8853cb96998869f7d4bdb81b",
"assets/FontManifest.json": "1cf48e4d1572f959ba6cae0773a363e3",
"assets/AssetManifest.bin.json": "afaae737d80b519406d6908eae1295bd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "825b261bba795acf8284da4934e29bb1",
"assets/packages/iconsax_flutter/fonts/FlutterIconsax.ttf": "6ebc7bc5b74956596611c6774d8beb5b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "3480661c713462f5415f76eb5e81f55b",
"assets/fonts/MaterialIcons-Regular.otf": "fa5ab66e5d8364a5bef8c775c736cd65",
"assets/assets/icons/app_logo_transparent.png": "e3749fee451cee8c8d1949ed2e8b64dd",
"assets/assets/icons/trash.svg": "e815eee36c833cc406a0801356543229",
"assets/assets/icons/edit.svg": "851c4ec529f68bf6f3f5c688b299bc3f",
"assets/assets/icons/app_logo.png": "84d0f1c19e67588492fdcd33be257138",
"assets/assets/icons/eye.svg": "163ca10978fdbde0c17ca2f24c3e6dfd",
"assets/assets/icons/filter.svg": "6e930f5741e3fa0a1bd92be7512acdfc",
"assets/assets/icons/calendar.svg": "65ed2565fb0607d80389823e525d8fc6",
"assets/assets/fonts/SFProText-Medium.ttf": "a260cbc18870da144038776461d9df28",
"assets/assets/fonts/SFProText-Heavy.ttf": "6c498791e52ee77eedea219f291f638d",
"assets/assets/fonts/SFProText-Semibold.ttf": "1a131c948d598ecec700d37d168a15b5",
"assets/assets/fonts/SFProText-Regular.ttf": "85bd46c1cff02c1d8360cc714b8298fa",
"assets/assets/fonts/SFProText-Light.ttf": "359f126c743e77d113cdc1ddda32534b",
"assets/assets/fonts/SFProText-Bold.ttf": "d6079ef01292c4bc84dce33988641530",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
