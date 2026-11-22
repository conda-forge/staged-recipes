import os
import subprocess
import tempfile
from pathlib import Path

with tempfile.TemporaryDirectory() as directory:
    env = dict(os.environ, LETTA_CONFIG_DIR=directory, DO_NOT_TRACK='1', SCARF_ANALYTICS='false')
    root = Path(os.environ['PREFIX'])
    root /= 'node_modules/@letta-ai/letta-code' if os.name == 'nt' else 'lib/node_modules/@letta-ai/letta-code'
    cli = ['node', str(root / 'letta.js')]
    print('Checking CLI version and launcher', flush=True)
    version = subprocess.check_output(cli + ['--version'], env=env, text=True, timeout=60)
    if os.name == 'nt':
        wrapper = subprocess.check_output(['cmd.exe', '/d', '/c', 'letta --version'], env=env, text=True, timeout=60)
        assert '0.34.68' in wrapper, wrapper
    else:
        subprocess.run(['letta', '--version'], env=env, check=True, timeout=90)
    assert '0.34.68' in version, version
    print('Checking CLI help and info', flush=True)
    subprocess.run(cli + ['--help'], env=env, check=True, timeout=90)
    info = subprocess.check_output(cli + ['--info'], env=env, text=True, timeout=60)
    assert 'Pinned agents: (none)' in info, info
    print('Checking image conversion and PTY', flush=True)
    subprocess.run(['node', '--input-type=commonjs', '-e', r'''
const assert = require('node:assert/strict');
const { createRequire } = require('node:module');
const requireApp = createRequire(process.argv[1] + '/package.json');
(async () => {
  const sharp = requireApp('sharp');
  const png = await sharp({create: {width: 8, height: 8, channels: 3, background: 'red'}}).resize(4, 4).png().toBuffer();
  assert.equal((await sharp(png).metadata()).width, 4);
  console.log('Direct sharp conversion passed');
  const { pathToFileURL } = require('node:url');
  const imageResize = await import(pathToFileURL(process.argv[1] + '/image-resize.js'));
  const largePng = await sharp({create: {width: 3000, height: 3000, channels: 3, background: 'red'}}).png().toBuffer();
  const resized = await imageResize.resizeImageIfNeeded(largePng, 'image/png');
  assert.equal(resized.resized, true);
  assert.ok(resized.width <= imageResize.MAX_IMAGE_WIDTH);
  assert.ok(resized.height <= imageResize.MAX_IMAGE_HEIGHT);
  console.log('Letta image worker passed');
  const pty = requireApp('node-pty');
  await new Promise((resolve, reject) => {
    const windows = process.platform === 'win32';
    const shell = windows ? (process.env.ComSpec || 'cmd.exe') : '/bin/sh';
    const args = windows ? ['/d', '/c', 'echo conda-pty-ok'] : ['-c', 'printf conda-pty-ok'];
    const terminal = pty.spawn(shell, args, {env: process.env, useConpty: true, useConptyDll: false});
    let output = '';
    const timer = setTimeout(() => { terminal.kill(); reject(new Error('PTY timeout')); }, 10000);
    terminal.onData(data => { output += data; });
    terminal.onExit(({exitCode}) => {
      clearTimeout(timer);
      try { assert.equal(exitCode, 0); assert.match(output, /conda-pty-ok/); resolve(); }
      catch (error) { reject(error); }
    });
  });
  console.log('PTY passed');
})().catch(error => { console.error(error); process.exit(1); });
''', str(root)], env=env, check=True, timeout=90)
