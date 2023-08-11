import React from 'react';

export const paths = {
  upArrow:
    'm10 4.167 4.583 4.583-1.146 1.146-2.604-2.604v9.375H9.167V7.292L6.563 9.896 5.417 8.75z',
  downArrow:
    'M10 15.833 5.417 11.25l1.145-1.146 2.605 2.604V3.333h1.666v9.375l2.604-2.604 1.146 1.146z',
};

const PinArrowIcon = ({ className, icon }) => {
  return paths[icon] ? (
    <svg className="dataset-arrow-icon" viewBox="0 0 24 24">
      <path d={paths[icon]} />
    </svg>
  ) : null;
};

export default PinArrowIcon;
