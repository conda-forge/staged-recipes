import React from 'react';
import ContentLoader from 'react-content-loader';
import {
  experimentTrackingLazyLoadingColours,
  experimentTrackingLazyLoadingGap,
} from '../../../config';

import './run-metadata.css';

const GAP = experimentTrackingLazyLoadingGap;

const TitleLoader = () => (
  <>
    <rect width="180" height="20" x="0" y="12" />
    <rect width="88" height="16" x="0" y={12 + GAP} />
    <rect width="88" height="16" x="0" y={12 + GAP * 2} />
    <rect width="88" height="16" x="0" y={12 + GAP * 3} />
    <rect width="88" height="16" x="0" y={12 + GAP * 4} />
    <rect width="88" height="16" x="0" y={12 + GAP * 5} />
    <rect width="88" height="16" x="0" y={12 + GAP * 6} />
  </>
);

const DetailsLoader = ({ x }) => (
  <>
    <rect width="0" height="0" x={x} y="12" />
    <rect width="30" height="16" x={x} y={12 + GAP} />
    <rect width="180" height="16" x={x} y={12 + GAP * 2} />
    <rect width="88" height="16" x={x} y={12 + GAP * 3} />
    <rect width="50" height="16" x={x} y={12 + GAP * 4} />
    <rect width="100" height="16" x={x} y={12 + GAP * 5} />
    <rect width="150" height="16" x={x} y={12 + GAP * 6} />
  </>
);

export const SingleRunMetadataLoader = ({ theme }) => (
  <div className="details-metadata">
    <ContentLoader
      viewBox="0 0 1000 300"
      width="1000px"
      height="100%"
      backgroundColor={
        theme === 'dark'
          ? experimentTrackingLazyLoadingColours.backgroundDarkTheme
          : experimentTrackingLazyLoadingColours.backgroundLightTheme
      }
      foregroundColor={
        theme === 'dark'
          ? experimentTrackingLazyLoadingColours.foregroundDarkTheme
          : experimentTrackingLazyLoadingColours.foregroundLightTheme
      }
    >
      <TitleLoader />
      <DetailsLoader x={380} />
    </ContentLoader>
  </div>
);

export const MetaDataLoader = ({ length, theme }) => {
  const x = length > 1 ? 75 : 0;

  return (
    <tbody className="details-metadata__run-lazy-loader">
      <tr>
        <td>
          <ContentLoader
            viewBox="0 0 200 300"
            width="200px"
            height="100%"
            backgroundColor={
              theme === 'dark'
                ? experimentTrackingLazyLoadingColours.backgroundDarkTheme
                : experimentTrackingLazyLoadingColours.backgroundLightTheme
            }
            foregroundColor={
              theme === 'dark'
                ? experimentTrackingLazyLoadingColours.foregroundDarkTheme
                : experimentTrackingLazyLoadingColours.foregroundLightTheme
            }
          >
            <DetailsLoader x={x} />
          </ContentLoader>
        </td>
      </tr>
    </tbody>
  );
};
