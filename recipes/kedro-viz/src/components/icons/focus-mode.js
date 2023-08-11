import React from 'react';

const FocusModeIcon = ({ className, checked }) => (
  <svg
    className={className}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
  >
    <g>
      <path
        d="M5 0L5 2 2 2 2 5 0 5 0 0z"
        transform="translate(-258 -194) translate(258 194) translate(6 6)"
      />
      <path
        d="M12 0L12 2 9 2 9 5 7 5 7 0z"
        transform="translate(-258 -194) translate(258 194) translate(6 6) rotate(90 9.5 2.5)"
      />
      <path
        d="M12 7L12 9 9 9 9 12 7 12 7 7z"
        transform="translate(-258 -194) translate(258 194) translate(6 6) rotate(-180 9.5 9.5)"
      />
      <path
        d="M5 7L5 9 2 9 2 12 0 12 0 7z"
        transform="translate(-258 -194) translate(258 194) translate(6 6) rotate(-90 2.5 9.5)"
      />
    </g>
  </svg>
);

export default FocusModeIcon;
