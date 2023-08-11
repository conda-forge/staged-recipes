import React, { createContext, useState } from 'react';

export const ButtonTimeoutContext = createContext(null);

/**
 * Provides a way to pass different states to a button depending on whether
 * it's successful or not.
 * {@returns hasNotInteracted and setHasNotInteracted} these 2 are only used for modal with editable fields
 */
export const ButtonTimeoutContextProvider = ({ children }) => {
  const [isSuccessful, setIsSuccessful] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [hasNotInteracted, setHasNotInteracted] = useState(true);

  const handleClick = () => {
    setShowModal(true);

    const localStateTimeout = setTimeout(() => {
      setIsSuccessful(true);
    }, 500);

    // so user is able to see the success message on the button first before the modal goes away
    const modalTimeout = setTimeout(() => {
      setShowModal(false);
    }, 1500);

    // Delay the reset so the user can't see the button text change.
    const resetTimeout = setTimeout(() => {
      setIsSuccessful(false);
      setHasNotInteracted(true);
    }, 2000);

    return () => {
      clearTimeout(localStateTimeout);
      clearTimeout(modalTimeout);
      clearTimeout(resetTimeout);
    };
  };

  return (
    <ButtonTimeoutContext.Provider
      value={{
        handleClick,
        hasNotInteracted,
        isSuccessful,
        setHasNotInteracted: (state) => setHasNotInteracted(state),
        setIsSuccessful: (state) => setIsSuccessful(state),
        showModal,
      }}
    >
      {children}
    </ButtonTimeoutContext.Provider>
  );
};
