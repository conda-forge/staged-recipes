import React, { useEffect } from 'react';
import classnames from 'classnames';
import './modal.css';

/**
 * Generic Kedro Modal
 */
const Modal = ({ title, closeModal, visible, message, children }) => {
  const handleKeyDown = (event) => {
    if (event.keyCode === 27) {
      closeModal(true);
    }
  };

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  });

  return (
    <div
      className={classnames('modal', {
        'modal--visible': visible,
      })}
      role="dialog"
    >
      <div
        onClick={closeModal}
        className={classnames('modal__bg', {
          'modal__bg--visible': visible,
        })}
      />
      <div
        className={classnames('modal__content', {
          'modal__content--visible': visible,
        })}
      >
        <div className="modal__wrapper">
          <div className="modal__title">{title}</div>
          {children}
          {!children && <div className="modal__description">{message}</div>}
        </div>
      </div>
    </div>
  );
};

export default Modal;
