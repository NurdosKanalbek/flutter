import { createServer } from 'node:http';
import { spawn } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve, extname, join } from 'node:path';

const delay = (ms) => new Promise((done) => setTimeout(done, ms));
const root = resolve('build/web');
const candidates = [
  process.env.CHROME_EXECUTABLE,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  join(process.env.LOCALAPPDATA ?? '', 'Google/Chrome/Application/chrome.exe'),
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
];
const executable = candidates.find((path) => path && existsSync(path));
if (executable === undefined) throw new Error('Chrome or Edge is required.');
if (existsSync(join(root, 'flutter_bootstrap.js')) === false) {
  throw new Error('Run flutter build web first.');
}
const mime = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.css': 'text/css',
  '.png': 'image/png',
  '.ttf': 'font/ttf',
};
const server = createServer((request, response) => {
  const relative = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
  const path = resolve(root, '.' + (relative === '/' ? '/index.html' : relative));
  if (path.startsWith(root + '/') === false && path.startsWith(root + '\\') === false) {
    response.writeHead(403).end();
    return;
  }
  try {
    response.writeHead(200, { 'Content-Type': mime[extname(path)] ?? 'application/octet-stream' });
    response.end(readFileSync(path));
  } catch {
    response.writeHead(404).end();
  }
});
await new Promise((done) => server.listen(8765, '127.0.0.1', done));
const browser = spawn(executable, [
  '--headless=new', '--disable-gpu', '--no-first-run',
  '--remote-debugging-port=9223',
  '--user-data-dir=' + resolve('.dart_tool/tablet-browser'),
  '--window-size=1024,1000',
  'http://127.0.0.1:8765',
], { windowsHide: true, stdio: 'ignore' });

let socket;
try {
  let targets;
  for (let attempt = 0; attempt < 120; attempt++) {
    try {
      targets = await (await fetch('http://127.0.0.1:9223/json')).json();
      if (targets.some((target) => target.type === 'page')) break;
    } catch {}
    await delay(500);
  }
  const target = targets?.find((item) => item.type === 'page');
  if (target === undefined) throw new Error('Browser debugging endpoint did not start.');
  socket = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((done, reject) => {
    socket.addEventListener('open', done, { once: true });
    socket.addEventListener('error', reject, { once: true });
  });
  let nextId = 0;
  const pending = new Map();
  socket.addEventListener('message', ({ data }) => {
    const message = JSON.parse(data);
    const callback = pending.get(message.id);
    if (callback) {
      pending.delete(message.id);
      if (message.error) callback.reject(new Error(JSON.stringify(message.error)));
      else callback.resolve(message.result);
    }
  });
  const cdp = (method, params = {}) => new Promise((resolveResult, reject) => {
    const id = ++nextId;
    const timeout = setTimeout(() => {
      pending.delete(id);
      reject(new Error('Timed out: ' + method));
    }, 20000);
    pending.set(id, {
      resolve: (result) => { clearTimeout(timeout); resolveResult(result); },
      reject: (error) => { clearTimeout(timeout); reject(error); },
    });
    socket.send(JSON.stringify({ id, method, params }));
  });
  const evaluate = async (expression) => {
    const result = await cdp('Runtime.evaluate', { expression, returnByValue: true });
    if (result.exceptionDetails) throw new Error(JSON.stringify(result.exceptionDetails));
    return result.result.value;
  };
  await cdp('Page.enable');
  await cdp('Accessibility.enable');
  await cdp('Emulation.setDeviceMetricsOverride', {
    width: 1024, height: 900, deviceScaleFactor: 1, mobile: false,
  });
  let ready = false;
  for (let attempt = 0; attempt < 180; attempt++) {
    ready = await evaluate(`(() => {
      const placeholder = document.querySelector('flt-semantics-placeholder');
      if (placeholder) { placeholder.click(); return true; }
      return document.querySelector('[role="textbox"]') !== null;
    })()`);
    if (ready) break;
    await delay(500);
  }
  if (ready === false) throw new Error('Flutter did not render accessibility controls.');
  await delay(1000);
  const tree = async () => (await cdp('Accessibility.getFullAXTree')).nodes;
  const click = async (label, roles = []) => {
    let node;
    for (let attempt = 0; attempt < 30; attempt++) {
      const nodes = await tree();
      node = nodes.find((item) =>
        item.ignored === false &&
        (roles.length === 0 || roles.includes(item.role?.value)) &&
        (item.name?.value === label || item.name?.value?.startsWith(label + ' '))
      );
      if (node?.backendDOMNodeId) break;
      await delay(200);
    }
    if (node?.backendDOMNodeId === undefined) {
      const nodes = await tree();
      throw new Error('Missing control ' + label + ': ' +
        JSON.stringify(nodes.filter((item) => item.ignored === false)
          .map((item) => [item.role?.value, item.name?.value])));
    }
    await cdp('DOM.scrollIntoViewIfNeeded', { backendNodeId: node.backendDOMNodeId });
    await delay(200);
    const { model } = await cdp('DOM.getBoxModel', { backendNodeId: node.backendDOMNodeId });
    const x = (model.content[0] + model.content[2]) / 2;
    const y = (model.content[1] + model.content[5]) / 2;
    await cdp('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1 });
    await cdp('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
    await delay(250);
  };
  for (const [label, value] of [
    ['Name', 'Nurdos Kanalbek'],
    ['Email', 'nurdos@kbtu.kz'],
    ['Password', 'student123'],
    ['Confirm password', 'student123'],
  ]) {
    await click(label, ['textbox']);
    await cdp('Input.insertText', { text: value });
    await delay(200);
  }
  await click('Group');
  await click('IT-2302');
  await click('Date of birth', ['textbox']);
  await click('OK', ['button']);
  await click('I agree to the rules', ['checkbox']);
  await click('Sign up', ['button']);
  await delay(1000);
  const nodes = await tree();
  if (nodes.some((node) => node.name?.value === 'Start over') === false) {
    throw new Error('Submission did not show the summary.');
  }
  const { data } = await cdp('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  writeFileSync('tablet.png', Buffer.from(data, 'base64'));
  console.log('Saved tablet.png from the running Flutter app at 1024 x 900.');
  socket.send(JSON.stringify({ id: ++nextId, method: 'Browser.close' }));
  await delay(200);
} finally {
  socket?.close();
  browser.kill();
  server.closeAllConnections();
  await new Promise((done) => server.close(done));
}
