import downloadSvg, { downloadPng } from 'svg-crowbar';
import { globalToolbarWidth } from '../../config';

/**
 * Handle onClick for the SVG/PNG download button
 * @param {String} format Must be 'svg' or 'png'
 * @param {String} theme light/dark theme
 * @param {Object} graphSize Graph width/height/margin
 * @param {Function} mockFn Mock testing function stand-in for svg-crowbar
 * @return {Function} onClick handler
 */
const exportGraph = ({ format, theme, graphSize, mockFn }) => {
  const downloadFormats = {
    png: downloadPng,
    svg: downloadSvg,
  };
  const download = mockFn || downloadFormats[format];

  // Create clone of graph SVG to avoid breaking the original
  const svg = document.querySelector('#pipeline-graph');
  const clone = svg.parentNode.appendChild(svg.cloneNode(true));
  clone.classList.add('kedro', `kui-theme--${theme}`, 'pipeline-graph--export');

  // Reset zoom/translate
  let width, height;
  const hasGraph = isFinite(graphSize.width) && isFinite(graphSize.height);
  if (hasGraph) {
    width = graphSize.width + graphSize.marginx * 2;
    height = graphSize.height + graphSize.marginy * 2;
    clone.setAttribute('viewBox', `0 0 ${width} ${height}`);
  }
  clone.querySelector('#zoom-wrapper').removeAttribute('transform');
  clone
    .querySelector('#zoom-wrapper')
    .setAttribute('transform', `translate(${globalToolbarWidth}, 0)`);

  // Impose a maximum size on PNGs because otherwise they break when downloading
  if (format === 'png') {
    const maxWidth = 5000;
    width = Math.min(width, maxWidth);
    height = Math.min(height, maxWidth * (height / width));
  }
  if (hasGraph) {
    clone.setAttribute('width', width);
    clone.setAttribute('height', height);
  }

  const style = document.createElement('style');
  if (format === 'svg') {
    // Add webfont
    style.innerHTML =
      '@import url(https://fonts.googleapis.com/css?family=Inter:400);';
  } else {
    // Add websafe fallback font
    style.innerHTML = `.kedro {
      font-family: "Trebuchet MS", "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", Tahoma, sans-serif;
      letter-spacing: -0.4px;
    }`;
  }
  clone.prepend(style);

  // Download SVG/PNG
  const options = format === 'svg' ? { css: 'internal' } : undefined;
  download(clone, 'kedro-pipeline', options);

  // Delete cloned SVG
  svg.parentNode.removeChild(clone);
};

export default exportGraph;
