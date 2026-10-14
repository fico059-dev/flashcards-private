{{flutter_js}}
{{flutter_build_config}}

// Safari, and every browser on iPhone and iPad (they all use Safari's
// engine), gets the CanvasKit renderer: the newer WebAssembly one (skwasm)
// can leave a blank page there. Other browsers keep the faster default.
// "?renderer=canvaskit" or "?renderer=skwasm" in the address overrides it.
(function () {
  var config = {};
  try {
    var asked = new URLSearchParams(location.search).get('renderer');
    var apple = navigator.vendor === 'Apple Computer, Inc.';
    if (asked === 'canvaskit' || asked === 'skwasm') {
      config.renderer = asked;
    } else if (apple) {
      config.renderer = 'canvaskit';
    }
    // The renderer files come with the website instead of from Google's
    // servers, one connection less to wait for.
    config.canvasKitBaseUrl = 'canvaskit/';
  } catch (e) {
    console.warn('Could not choose the renderer', e);
  }
  // No service worker: the website is always used online, and the offline
  // cache kept serving old versions after updates.
  _flutter.loader.load({ config: config });
})();
