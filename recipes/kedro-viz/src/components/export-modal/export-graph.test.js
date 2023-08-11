import exportGraph from './export-graph';

describe('exportGraph', () => {
  const theme = 'dark';
  const graphSize = {
    width: 1000,
    height: 500,
    marginx: 40,
    marginy: 40,
  };

  beforeEach(() => {
    document.body.innerHTML = `
        <svg id="pipeline-graph">
          <g id="zoom-wrapper" />
        </svg>
      `;
  });

  it('downloads an SVG', () => {
    const mockFn = jest.fn();
    exportGraph({ format: 'svg', mockFn, theme, graphSize });
    expect(mockFn.mock.calls.length).toBe(1);
  });

  it('downloads a PNG', () => {
    const mockFn = jest.fn();
    exportGraph({ format: 'png', mockFn, theme, graphSize });
    expect(mockFn.mock.calls.length).toBe(1);
  });

  it('erases the cloned SVG node', () => {
    expect(document.querySelectorAll('svg').length).toBe(1);
  });
});
