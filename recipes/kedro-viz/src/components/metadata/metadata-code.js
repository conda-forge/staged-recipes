import React, { useRef, useMemo } from 'react';
import { connect } from 'react-redux';
import hljs from 'highlight.js/lib/core';
import python from 'highlight.js/lib/languages/python';
import yaml from 'highlight.js/lib/languages/yaml';
import javascript from 'highlight.js/lib/languages/javascript';
import modifiers from '../../utils/modifiers';
import './styles/metadata-code.css';

hljs.registerLanguage('python', python);
hljs.registerLanguage('yaml', yaml);
hljs.registerLanguage('javascript', javascript);

/**
 * A highlighted code panel
 */
export const MetaDataCode = ({
  sidebarVisible,
  visible = true,
  value = '',
}) => {
  const codeRef = useRef();

  const highlighted = useMemo(() => {
    const detected = hljs.highlightAuto(value);
    const language = detected.language || detected.second_best.language;
    return language ? hljs.highlight(value, { language }).value : value;
  }, [value]);

  return (
    <div
      className={modifiers(
        'pipeline-metadata-code',
        { visible, sidebarVisible },
        'kedro'
      )}
    >
      <h2 className="pipeline-metadata-code__title">Code block</h2>
      <code className="pipeline-metadata-code__code">
        <pre ref={codeRef} dangerouslySetInnerHTML={{ __html: highlighted }} />
      </code>
    </div>
  );
};

const mapStateToProps = (state) => ({
  sidebarVisible: state.visible.sidebar,
});

export default connect(mapStateToProps)(MetaDataCode);
