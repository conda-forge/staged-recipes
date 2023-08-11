import { useEffect, useRef } from 'react';
import * as d3 from 'd3';

/**
 * To incorporate D3 into React
 */
export const useD3 = (renderFunction, dependencies) => {
  const ref = useRef();

  useEffect(() => {
    renderFunction(d3.select(ref.current));

    return () => {};
  }, [renderFunction, dependencies]);

  return ref;
};
