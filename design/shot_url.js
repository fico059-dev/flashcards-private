const { chromium } = require('/opt/node22/lib/node_modules/playwright');
(async () => {
  const [,, url, out, w, h, wait] = process.argv;
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args:['--no-sandbox'] });
  const p = await b.newPage({ viewport: { width: +w, height: +h } });
  p.on('console', m => { const t=m.text(); if (m.type()==='error') console.log('ERR', t.slice(0,300)); });
  p.on('pageerror', e => console.log('PAGEERR', String(e).slice(0,300)));
  await p.goto(url);
  await p.waitForTimeout(+wait);
  await p.screenshot({ path: out });
  await b.close();
})();
