import React, { useEffect, useCallback } from 'react';

import './circle-progress.bar.css';

const FULL_DASH_ARRAY = 283;
const TIME_LIMIT = 60;

const CircleProgressBar = ({ children: counter }) => {
  const calculateTimeFraction = useCallback(() => {
    return counter / TIME_LIMIT;
  }, [counter]);

  const setCircleDasharray = useCallback(() => {
    const circleDasharray = `${(
      calculateTimeFraction() * FULL_DASH_ARRAY
    ).toFixed(0)} 283`;

    document
      .getElementById('base-timer-path-remaining')
      .setAttribute('stroke-dasharray', circleDasharray);
  }, [calculateTimeFraction]);

  const startTimer = useCallback(() => {
    const timerInterval = setInterval(() => {
      setCircleDasharray();
    }, 1000);

    return () => clearInterval(timerInterval);
  }, [setCircleDasharray]);

  useEffect(() => startTimer(), [startTimer]);

  return (
    <div className="base-timer">
      <svg
        className="base-timer__svg"
        viewBox="0 0 100 100"
        xmlns="http://www.w3.org/2000/svg"
      >
        <g className="base-timer__circle">
          <circle className="base-timer__path-elapsed" cx="50" cy="50" r="45" />
          <path
            id="base-timer-path-remaining"
            strokeDasharray="283"
            className="base-timer__path-remaining"
            d="
          M 50, 50
          m -45, 0
          a 45,45 0 1,0 90,0
          a 45,45 0 1,0 -90,0
        "
          ></path>
        </g>
      </svg>
      <span id="base-timer-label" className="base-timer__label">
        {counter}
      </span>
    </div>
  );
};

export default CircleProgressBar;
