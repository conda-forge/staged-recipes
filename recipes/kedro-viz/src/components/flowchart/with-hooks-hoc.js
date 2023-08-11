import React from 'react';
import { useGeneratePathname } from '../../utils/hooks/use-generate-pathname';

export const withHooksHOC = (Component) => {
  return (props) => {
    const { toSelectedPipeline, toSelectedNode, toFocusedModularPipeline } =
      useGeneratePathname();

    return (
      <Component
        toSelectedPipeline={toSelectedPipeline}
        toSelectedNode={toSelectedNode}
        toFocusedModularPipeline={toFocusedModularPipeline}
        {...props}
      />
    );
  };
};
