import { useEffect, useRef } from 'react';

/**
 * Custom hook to obtain previous values before state changes. The value can be any data type.
 * @param {value} object
 */
export const usePrevious = (value) => {
  const ref = useRef();
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
};

/**
 * Custom hook to detect clicks outside of a specified element.
 * @param {Function} callback The function to fire on an outside click.
 * @returns A React ref of the element you want to click outside of.
 */
export const useOutsideClick = (callback) => {
  const ref = useRef();

  useEffect(() => {
    const handleClick = (event) => {
      if (ref.current && !ref.current.contains(event.target)) {
        callback();
      }
    };

    document.addEventListener('click', handleClick, true);

    return () => {
      document.removeEventListener('click', handleClick, true);
    };
  }, [callback, ref]);

  return ref;
};
