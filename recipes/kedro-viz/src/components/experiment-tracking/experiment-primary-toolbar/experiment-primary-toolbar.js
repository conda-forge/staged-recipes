import React from 'react';
import { useUpdateRunDetails } from '../../../apollo/mutations';
import IconButton from '../../ui/icon-button';
import PencilIcon from '../../icons/pencil';
import BookmarkIcon from '../../icons/bookmark';
import ExportIcon from '../../icons/export';
import BookmarkStrokeIcon from '../../icons/bookmark-stroke';
import PrimaryToolbar from '../../primary-toolbar';
import ShowChangesIcon from '../../icons/show-changes';

import {
  SlideFromLeftToRight,
  SlideFromRightToLeft,
} from './sliding-animation';

const duration = 300;

export const ExperimentPrimaryToolbar = ({
  displaySidebar,
  enableComparisonView,
  enableShowChanges,
  selectedRunData,
  setEnableShowChanges,
  setSidebarVisible,
  showChangesIconDisabled,
  showRunDetailsModal,
  sidebarVisible,
  setShowRunExportModal,
}) => {
  const { updateRunDetails } = useUpdateRunDetails();

  const toggleBookmark = () => {
    updateRunDetails({
      runId: selectedRunData.id,
      runInput: { bookmark: !selectedRunData?.bookmark },
    });
  };

  return (
    <PrimaryToolbar
      displaySidebar={displaySidebar}
      onToggleSidebar={setSidebarVisible}
      visible={{ sidebar: sidebarVisible }}
    >
      <SlideFromLeftToRight state={enableComparisonView} duration={duration}>
        {enableComparisonView && (
          <>
            <IconButton
              active={enableShowChanges}
              ariaLabel="Toggle show changes"
              className={'pipeline-menu-button--labels'}
              dataTest={'btnToggleChange'}
              disabled={showChangesIconDisabled}
              icon={ShowChangesIcon}
              labelText={
                !showChangesIconDisabled
                  ? `${enableShowChanges ? 'Disable' : 'Enable'} show changes`
                  : null
              }
              onClick={() => setEnableShowChanges(!enableShowChanges)}
            />
            <IconButton
              ariaLabel="Export Run Data"
              className={'pipeline-menu-button--export-runs'}
              icon={ExportIcon}
              labelText="Export run data"
              onClick={() => setShowRunExportModal(true)}
            />
          </>
        )}
      </SlideFromLeftToRight>
      <SlideFromRightToLeft state={!enableComparisonView} duration={duration}>
        {!enableComparisonView && (
          <>
            <IconButton
              active={selectedRunData?.bookmark}
              ariaLabel="Toggle run bookmark"
              className={'pipeline-menu-button--labels'}
              dataTest="btnToggleBookmark"
              icon={
                selectedRunData?.bookmark ? BookmarkIcon : BookmarkStrokeIcon
              }
              labelText={`${
                selectedRunData?.bookmark ? 'Unbookmark' : 'Bookmark'
              }`}
              onClick={() => toggleBookmark()}
            />
            <IconButton
              ariaLabel="Edit run details"
              className={'pipeline-menu-button--labels'}
              dataTest="btnEditRunDetails"
              icon={PencilIcon}
              labelText={`Edit details`}
              onClick={() => showRunDetailsModal(true)}
            />
            <IconButton
              ariaLabel="Export Run Data"
              className={'pipeline-menu-button--export-runs'}
              dataTest="btnExportRunData"
              icon={ExportIcon}
              labelText="Export run data"
              onClick={() => setShowRunExportModal(true)}
            />
          </>
        )}
      </SlideFromRightToLeft>
    </PrimaryToolbar>
  );
};

export default ExperimentPrimaryToolbar;
