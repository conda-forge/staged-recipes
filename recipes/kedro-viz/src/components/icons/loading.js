import React from 'react';
import classnames from 'classnames';
import './loading.css';

const d = 'M 50 50 100 100 50 150 0 100 Z';

const LoadingIcon = ({ className, visible }) => (
  <svg
    className={classnames(className, 'pipeline-loading-icon', {
      'pipeline-loading-icon--visible': visible,
    })}
    viewBox="-10 45 120 100"
  >
    <path d={d} />
    <path d={d} />
  </svg>
);

export default LoadingIcon;
