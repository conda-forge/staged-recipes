import React from 'react';
import modifiers from '../../utils/modifiers';
import './styles/metadata.css';

/**
 * Shows a metadata value
 */
const MetaDataValue = ({
  className,
  container: Container = 'span',
  empty,
  kind,
  title,
  value,
}) => (
  <>
    <Container
      title={title}
      className={modifiers('pipeline-metadata__value', { kind }, className)}
    >
      {!value && value !== 0 ? empty : value}
    </Container>
  </>
);

export default MetaDataValue;
