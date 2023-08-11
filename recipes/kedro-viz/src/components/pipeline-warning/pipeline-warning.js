import React, { useEffect, useState } from 'react';
import classnames from 'classnames';
import { connect } from 'react-redux';
import { changeFlag, toggleIgnoreLargeWarning } from '../../actions';
import { getVisibleNodes } from '../../selectors/nodes';
import { getTriggerLargeGraphWarning } from '../../selectors/layout';
import { useGeneratePathname } from '../../utils/hooks/use-generate-pathname';
import Button from '../ui/button';
import './pipeline-warning.css';

const PipelineWarningContent = ({
  isVisible,
  title,
  subtitle,
  buttons = [],
  sidebarVisible,
}) => {
  if (!isVisible) {
    return null;
  }
  return (
    <div
      className={classnames('kedro', 'pipeline-warning', {
        'pipeline-warning--sidebar-visible': sidebarVisible,
      })}
    >
      <h2 className="pipeline-warning__title">{title}</h2>
      <p className="pipeline-warning__subtitle">{subtitle}</p>
      <div className="pipeline-warning__button-wrapper">
        {buttons.map((buttonProps, index) => (
          <Button key={index} {...buttonProps} />
        ))}
      </div>
    </div>
  );
};

export const PipelineWarning = ({
  errorMessage,
  invalidUrl,
  nodes,
  onDisable,
  onHide,
  sidebarVisible,
  visible,
  onResetClick,
}) => {
  const [componentLoaded, setComponentLoaded] = useState(false);
  const isEmptyPipeline = nodes.length === 0;

  const { toFlowchartPage } = useGeneratePathname();

  // Only run this once, when the component mounts.
  useEffect(() => {
    const timer = setTimeout(() => {
      setComponentLoaded(true);
    }, 1500);

    return () => clearTimeout(timer);
  }, []);

  return (
    <>
      <PipelineWarningContent
        isVisible={visible}
        title="Whoa, that’s a chonky pipeline!"
        subtitle={
          <>
            This graph contains <b>{nodes.length}</b> elements, which will take
            a while to render. You can use the sidebar controls to select a
            smaller graph.
          </>
        }
        buttons={[
          { onClick: onHide, children: 'Render it anyway' },
          {
            mode: 'secondary',
            onClick: onDisable,
            size: 'small',
            children: "Don't show this again",
          },
        ]}
        sidebarVisible={sidebarVisible}
      />

      <PipelineWarningContent
        isVisible={isEmptyPipeline && componentLoaded}
        title="Oops, there's nothing to see here"
        subtitle="This selection has nothing. Please unselect your filters or modular pipeline selection to see pipeline elements."
        sidebarVisible={sidebarVisible}
      />

      <PipelineWarningContent
        isVisible={invalidUrl && componentLoaded}
        title="Oops, this URL isn't valid"
        subtitle={`${errorMessage}. Perhaps you've deleted the entity 🙈 or it may be a typo 😇`}
        buttons={[
          {
            onClick: () => {
              toFlowchartPage();
              onResetClick();
            },
            children: 'Reset view',
          },
        ]}
        sidebarVisible={sidebarVisible}
      />
    </>
  );
};

export const mapStateToProps = (state) => ({
  nodes: getVisibleNodes(state),
  sidebarVisible: state.visible.sidebar,
  theme: state.theme,
  visible: getTriggerLargeGraphWarning(state),
});

export const mapDispatchToProps = (dispatch) => ({
  onDisable: () => {
    dispatch(changeFlag('sizewarning', false));
  },
  onHide: () => {
    dispatch(toggleIgnoreLargeWarning(true));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(PipelineWarning);
