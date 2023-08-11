import React, { useEffect, useState } from 'react';
import { generatePath, useLocation } from 'react-router-dom';
import classnames from 'classnames';
import { routes } from '../../../config';
import { saveLocalStorage } from '../../../store/helpers';
import { localStorageFlowchartLink } from '../../../config';

import './accordion.css';

/**
 * A collapsable container component.
 * @param {Object} children React children
 * @param {String|null} className A top-level class name for the component.
 * @param {String} heading Text to display on the top-level.
 * @param {String|null} headingClassName A class name for the accordion header.
 * @param {String|null} headingDetail Text to display on the top-level.
 * @param {Boolean} isCollapsed Control to collapse or expand the content.
 * @param {Boolean} isHyperlink Whether the button has an anchor link to a different page or not
 * @param {String|null} layout A secondary text string for additional context
 * @param {String|null} linkTitle A tag defines the title of the element
 * @param {Function} onCallback Fire a function on click from a parent.
 * @param {String} size Set the header font size.
 */
const Accordion = ({
  children,
  className = null,
  heading = '',
  headingClassName = null,
  headingDetail = null,
  isCollapsed = false,
  isHyperlink = false,
  layout = 'right',
  linkTitle = null,
  onCallback,
  size = 'small',
}) => {
  const [collapsed, setCollapsed] = useState(isCollapsed);
  const [flowchartUrl, setFlowchartUrl] = useState(null);
  const { pathname, search } = useLocation();

  useEffect(() => {
    setCollapsed(isCollapsed);
  }, [isCollapsed]);

  useEffect(() => {
    if (heading.length > 0) {
      const url = generatePath(routes.flowchart.selectedName, {
        pipelineId: '__default__',
        fullName: heading,
      });

      setFlowchartUrl(url);
    }
  }, [heading]);

  const onClick = () => {
    setCollapsed(!collapsed);
    onCallback && onCallback();
  };

  const onLinkToFlowChart = () => {
    saveLocalStorage(localStorageFlowchartLink, {
      fromURL: pathname + search,
      showGoBackBtn: true,
    });
  };

  return (
    <div
      className={classnames('accordion', {
        'accordion--left': layout === 'left',
        [`${className}`]: className,
      })}
    >
      <div
        className={classnames('accordion__heading', {
          [`${headingClassName}`]: headingClassName,
        })}
      >
        {layout === 'left' && (
          <button
            aria-label={`${
              collapsed ? 'Show' : 'Hide'
            } ${heading.toLowerCase()}`}
            onClick={onClick}
            className={classnames('accordion__toggle', {
              'accordion__toggle--alt': collapsed,
            })}
          />
        )}
        <div
          className={classnames('accordion__title', {
            'accordion__title--medium': size === 'medium',
            'accordion__title--large': size === 'large',
          })}
        >
          {isHyperlink ? (
            <a
              className="accordion__title--hyperlink"
              href={flowchartUrl}
              onClick={onLinkToFlowChart}
              title={linkTitle}
            >
              {heading}
            </a>
          ) : (
            heading
          )}
          {headingDetail && (
            <span className="accordion__title__detail">{headingDetail}</span>
          )}
        </div>
        {layout === 'right' && (
          <button
            aria-label={`${
              collapsed ? 'Show' : 'Hide'
            } ${heading.toLowerCase()}`}
            onClick={onClick}
            className={classnames('accordion__toggle', {
              'accordion__toggle--alt': collapsed,
            })}
          />
        )}
      </div>
      <div className={collapsed ? 'accordion__content--hide' : null}>
        {children}
      </div>
    </div>
  );
};

export default Accordion;
