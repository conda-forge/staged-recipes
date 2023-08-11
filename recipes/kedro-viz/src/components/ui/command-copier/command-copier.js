import React, { useState } from 'react';
import modifiers from '../../../utils/modifiers';
import MetaDataValue from '../../metadata/metadata-value';
import IconButton from '../../ui/icon-button';
import CopyIcon from '../../icons/copy';
import './command-copier.css';

const CommandCopier = ({ command, isCommand }) => {
  const [showCopied, setShowCopied] = useState(false);

  const onCopyClick = () => {
    window.navigator.clipboard.writeText(command);
    setShowCopied(true);
    setTimeout(() => setShowCopied(false), 1500);
  };

  return (
    <div className="container">
      <MetaDataValue
        container={'code'}
        className={modifiers('command-value', {
          visible: !showCopied,
        })}
        value={command}
      />
      {window.navigator.clipboard && isCommand && (
        <>
          <span
            className={modifiers('copy-message', {
              visible: showCopied,
            })}
          >
            Copied to clipboard.
          </span>
          <ul className="toolbox">
            <IconButton
              ariaLabel="Copy run command to clipboard."
              className="copy-button"
              dataHeapEvent={`clicked.run_command`}
              icon={CopyIcon}
              onClick={onCopyClick}
            />
          </ul>
        </>
      )}
    </div>
  );
};

export default CommandCopier;
