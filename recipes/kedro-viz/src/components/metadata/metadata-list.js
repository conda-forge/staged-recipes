import React, { useState, useEffect } from 'react';
import modifiers from '../../utils/modifiers';
import MetaDataValue from './metadata-value';
import './styles/metadata.css';

/**
 * Shows a list of MetaDataValue
 */
const MetaDataList = ({
  property,
  values = [],
  kind = 'text',
  empty = '-',
  inline = true,
  commas = true,
  limit = false,
}) => {
  const [expanded, setExpanded] = useState(false);
  const showValues = !expanded && limit ? values.slice(0, limit) : values;
  const remainder = values.length - showValues.length;

  // Default to not expanded when values change
  useEffect(() => setExpanded(false), [values]);

  return values.length > 0 ? (
    <>
      <ul
        className={modifiers('pipeline-metadata__value-list', {
          inline,
          commas,
        })}
      >
        {showValues.map((item, index) => (
          <li key={index}>
            <MetaDataValue
              value={property ? item[property] : item}
              kind={kind}
              empty={empty}
            />
          </li>
        ))}
      </ul>
      {remainder > 0 ? (
        <button
          className="pipeline-metadata__value-list-expand"
          aria-expanded={expanded}
          onClick={() => setExpanded(true)}
        >
          + {remainder} more
        </button>
      ) : null}
    </>
  ) : (
    <MetaDataValue empty={empty} />
  );
};

export default MetaDataList;
