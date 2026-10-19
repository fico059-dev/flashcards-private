const { chromium } = require('/opt/node22/lib/node_modules/playwright');
(async () => {
  const [,, input, output, w, h] = process.argv;
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' , args:['--no-sandbox']});
  const p = await b.newPage({ viewport: { width: +w, height: +h } });
  await p.goto('file://' + require('path').resolve(input));
  await p.waitForTimeout(300);
  await p.screenshot({ path: output, omitBackground: process.env.TRANSPARENT === '1' });
  await b.close();
})();
