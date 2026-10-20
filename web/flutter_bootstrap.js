{{flutter_js}}
{{flutter_build_config}}

// Flutter's service worker is deprecated and can keep a broken old build cached
// (mainly in Safari), so we remove any old registration and load without it.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations()
    .then((regs) => regs.forEach((r) => r.unregister()))
    .catch(() => {});
}

_flutter.loader.load({
  config: {
    // Load CanvasKit from our own site instead of www.gstatic.com, which Safari
    // content blockers and privacy settings sometimes block.
    canvasKitBaseUrl: 'canvaskit/',
  },
}).catch((e) => window.taqdirShowError && window.taqdirShowError(e));
