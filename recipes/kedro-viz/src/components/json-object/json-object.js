import React from 'react';
import modifiers from '../../utils/modifiers';
import './json-object.css';
import ReactJson from 'react-json-view';
import {
  darkjsonViewerTheme,
  lightjsonViewerTheme,
} from './json-theme';

/**
 * Shows a metadata object
 */
const JSONObject = ({ className, value, kind, theme, empty }) => (
  <div className={modifiers('pipeline-json__object', { kind }, className)}>
    {Object.keys(value).length === 0 ? (
      empty
    ) : (
      <ReactJson
        theme={theme === 'dark' ? darkjsonViewerTheme : lightjsonViewerTheme}
        name={false}
        indentWidth={1}
        collapsed={1}
        collapseStringsAfterLength={true}
        enableClipboard={true}
        displayDataTypes={false}
        src={value}
        style={{backgroundColor:'transparent'}}
      />
    )}
  </div>
);

export default JSONObject;
