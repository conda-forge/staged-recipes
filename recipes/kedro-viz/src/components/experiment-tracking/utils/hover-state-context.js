import React, { createContext, useState } from 'react';

export const HoverStateContext = createContext(null);

/**
 * Provides a way to manage state for hovered elements between
 * RunListCard and metrics plots components
 */
export const HoverStateContextProvider = ({ children }) => {
  const [hoveredElementId, setHoveredElementId] = useState(null);

  return (
    <HoverStateContext.Provider
      value={{
        hoveredElementId,
        setHoveredElementId,
      }}
    >
      {children}
    </HoverStateContext.Provider>
  );
};
