import React from 'react';

const OffIndicatorIcon = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24">
    {/* Note: some strokeWidth values fail when zoomed in Chrome e.g. 2 */}
    <rect x="8.5" y="9" width="5" height="5" rx="1" strokeWidth="1.9" />
  </svg>
);

export default OffIndicatorIcon;
