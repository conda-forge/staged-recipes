// elkjs is engine-agnostic JavaScript with no dependencies, which is why this package needs no
// runtime of its own. QuickJS is the smallest thing that proves it: no Node, no browser, just a
// few globals elkjs expects — a window-ish object, a console with `err`, and timers, which
// QuickJS keeps in `os` rather than exposing globally.
import * as std from 'std';
import * as os from 'os';

globalThis.window = globalThis;
globalThis.$wnd = globalThis;
globalThis.setTimeout = (fn, ms) => os.setTimeout(fn, ms || 0);
globalThis.clearTimeout = (id) => os.clearTimeout(id);
globalThis.console.err = globalThis.console.error || globalThis.console.log;

const prefix = std.getenv('CONDA_PREFIX') || std.getenv('PREFIX');
if (!prefix) throw new Error('neither CONDA_PREFIX nor PREFIX is set');

const fail = (what) => {
  console.log(`FAILED: ${what}`);
  std.exit(1);
};

globalThis.module = { exports: {} };
globalThis.exports = globalThis.module.exports;

import(`${prefix}/lib/node_modules/elkjs/lib/elk.bundled.js`)
  .then(() => {
    const ELK = globalThis.module.exports;
    if (typeof ELK !== 'function') fail('elk.bundled.js did not export a constructor');
    return new ELK().layout({
      id: 'root',
      layoutOptions: { 'elk.algorithm': 'layered', 'elk.edgeRouting': 'ORTHOGONAL' },
      children: [
        { id: 'a', width: 40, height: 20 },
        { id: 'b', width: 40, height: 20 },
      ],
      edges: [{ id: 'e', sources: ['a'], targets: ['b'] }],
    });
  })
  .then((graph) => {
    if (!graph.children || graph.children.length !== 2) fail('the nodes were not placed');
    if (!graph.edges || !graph.edges[0].sections) fail('the edge was not routed');
    console.log(`elkjs laid out ${graph.children.length} nodes in ${Math.round(graph.width)}x${Math.round(graph.height)}`);
  })
  .catch((err) => fail(err));
