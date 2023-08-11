import React from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import './button.css';

/**
 * Generic Kedro Button
 */
const Button = ({ children, dataTest, disabled, onClick, size, mode }) => (
  <span className="kedro button">
    <button
      className={classnames(
        'button__btn',
        `button__btn--${size}`,
        `button__btn--${mode}`
      )}
      data-test={dataTest}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  </span>
);

Button.defaultProps = {
  dataTest: 'TestDefaultDataValue',
  disabled: false,
  mode: 'primary',
  onClick: null,
  size: 'regular',
};

Button.propTypes = {
  dataTest: PropTypes.string,
  disabled: PropTypes.bool,
  mode: PropTypes.oneOf(['primary', 'secondary', 'success']),
  onClick: PropTypes.func,
  size: PropTypes.oneOf(['regular', 'small']),
};

export default Button;
