import React, { useContext, useState, useEffect, useMemo } from 'react';
import classnames from 'classnames';
import * as d3 from 'd3';
import { HoverStateContext } from '../utils/hover-state-context';
import { v4 as uuidv4 } from 'uuid';
import {
  ExperimentTrackingTooltip,
  tooltipDefaultProps,
} from '../tooltip/tooltip';
import { getTooltipPosition } from '../tooltip/get-tooltip-position';
import { formatTimestamp } from '../../../utils/date-utils';

import './parallel-coordinates.css';

export const getUniqueValues = (values) => {
  return values
    .filter((value, i, self) => self.indexOf(value) === i)
    .filter((value) => value !== null)
    .sort((a, b) => a - b);
};

const paddingTopBottom = 38;
const paddingLeftRight = 80;
const axisGapBuffer = 3;
const selectedMarkerRotate = [45, 0, 0];

const yAxis = {};
const yScales = {};

export const ParallelCoordinates = ({
  chartHeight,
  chartWidth,
  metricsData,
  selectedRuns,
  sidebarVisible,
}) => {
  const [hoveredMetricLabel, setHoveredMetricLabel] = useState(null);
  const [showTooltip, setShowTooltip] = useState(tooltipDefaultProps);

  const { hoveredElementId, setHoveredElementId } =
    useContext(HoverStateContext);

  const selectedMarkerShape = [
    d3.symbolSquare,
    d3.symbolCircle,
    d3.symbolTriangle,
  ];

  const graph = Object.entries(metricsData.metrics);
  const graphKeys = useMemo(
    () => Object.keys(metricsData.metrics),
    [metricsData.metrics]
  );

  const data = Object.entries(metricsData.runs);
  const selectedData = data
    .filter(([key]) => selectedRuns.includes(key))
    .sort((a, b) => {
      // We need to sort the selected data to match the order of selectedRuns.
      // If we didn't, the highlighted runs would switch colors unnecessarily.
      return selectedRuns.indexOf(a[0]) - selectedRuns.indexOf(b[0]);
    });

  const hoveredValues = hoveredElementId && metricsData.runs[hoveredElementId];

  const xScale = d3
    .scalePoint()
    .domain(graphKeys)
    .range([paddingLeftRight, chartWidth - paddingLeftRight]);

  // For each metric, draw a y-scale
  graph.forEach(([key, value]) => {
    yScales[key] = d3
      .scaleLinear()
      .domain([d3.min(value), d3.max(value)])
      .range([
        chartHeight - paddingTopBottom * 2.15,
        paddingTopBottom + paddingTopBottom / axisGapBuffer,
      ]);
  });

  Object.entries(yScales).forEach(([key, value]) => {
    yAxis[key] = d3.axisLeft(value).ticks(0).tickSizeOuter(0);
  });

  const lineGenerator = d3.line().defined(function (d) {
    return d !== null;
  });

  const linePath = function (d) {
    const points = d.map((x, i) => {
      if (x !== null) {
        return [xScale(graphKeys[i]), yScales[graphKeys[i]](x)];
      } else {
        return null;
      }
    });

    return lineGenerator(points);
  };

  const handleMouseOverMetric = (e, key) => {
    const runsCount = graph.find((each) => each[0] === key)[1].length;
    const { x, y, direction } = getTooltipPosition(e, sidebarVisible);

    setHoveredMetricLabel(key);

    setShowTooltip({
      content: {
        label1: 'Metric name',
        value1: key,
        label2: 'Run count',
        value2: runsCount,
      },
      direction,
      position: { x, y },
      visible: true,
    });
  };

  const handleMouseOutMetric = () => {
    setHoveredMetricLabel(null);
    setShowTooltip(tooltipDefaultProps);
  };

  const handleMouseOverLine = (e, key) => {
    setHoveredElementId(key);

    if (e) {
      const parsedDate = new Date(formatTimestamp(key));
      const { x, y, direction } = getTooltipPosition(e, sidebarVisible);

      setShowTooltip({
        content: {
          label1: 'Run name',
          value1: key,
          label2: 'Date',
          value2: parsedDate.toLocaleDateString('default', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
          }),
        },
        direction,
        position: { x, y },
        visible: true,
      });
    }
  };

  const handleMouseOutLine = () => {
    setHoveredElementId(null);
    setShowTooltip(tooltipDefaultProps);
  };

  useEffect(() => {
    d3.select(`.run-line[id="${hoveredElementId}"]`).raise();
  }, [hoveredElementId]);

  useEffect(() => {
    d3.select(`.metric-axis[id="${hoveredMetricLabel}"]`).raise();
    d3.selectAll(`.selected-runs`).raise();
    d3.selectAll(`.selected-runs > path`).raise();
  }, [hoveredMetricLabel]);

  return (
    <div className="parallel-coordinates">
      <ExperimentTrackingTooltip
        content={showTooltip.content}
        direction={showTooltip.direction}
        position={showTooltip.position}
        visible={showTooltip.visible}
      />

      <svg
        preserveAspectRatio="xMinYMin meet"
        viewBox={`0 0 ${chartWidth} ${chartHeight}`}
        width="100%"
      >
        {graphKeys.map((metricName) => {
          const getYAxis = (ref) => {
            d3.select(ref).call(yAxis[metricName]).attr('id', metricName);
          };

          return (
            <g
              className={classnames('metric-axis', {
                'metric-axis--hovered': hoveredMetricLabel === metricName,
                'metric-axis--faded':
                  hoveredMetricLabel && hoveredMetricLabel !== metricName,
              })}
              key={`metric-axis--${metricName}`}
              ref={getYAxis}
              transform={`translate(${xScale(metricName)}, 0)`}
              y={paddingTopBottom / 2}
            >
              <text
                className="headers"
                key={`metric-axis-text--${metricName}`}
                onMouseOut={handleMouseOutMetric}
                onMouseOver={(e) => handleMouseOverMetric(e, metricName)}
                textAnchor="middle"
                y={paddingTopBottom / 2}
              >
                {metricName.length > 20
                  ? '...' + metricName.slice(-20)
                  : metricName}
              </text>
            </g>
          );
        })}

        <g className="run-lines">
          {data.map(([runId, value], i) => {
            return (
              <path
                className={classnames('run-line', {
                  'run-line--hovered': hoveredElementId === runId,
                  'run-line--faded':
                    (hoveredElementId && hoveredElementId !== runId) ||
                    hoveredMetricLabel,
                })}
                d={linePath(value, i)}
                id={runId}
                key={runId}
                onMouseLeave={handleMouseOutLine}
                onMouseOver={(e) => handleMouseOverLine(e, runId)}
              />
            );
          })}
        </g>

        {graph.map(([metricName, values], metricIndex) => {
          // To avoid rendering a tick more than once
          const uniqueValues = getUniqueValues(values);

          return (
            <g className="tick-values" id={metricName} key={uuidv4()}>
              {uniqueValues.map((value) => {
                // To ensure the hoveredValues are highlighted once per axis
                const highlightedValue =
                  hoveredValues &&
                  hoveredValues.find(
                    (value, index) => index === metricIndex && value
                  );

                const xScaleTickValue = isNaN(xScale(metricName))
                  ? 0
                  : xScale(metricName);

                const yScaleTickValue = isNaN(yScales[metricName](value))
                  ? 0
                  : yScales[metricName](value);

                return (
                  <text
                    className={classnames('text', {
                      'text--hovered':
                        hoveredMetricLabel === metricName ||
                        (highlightedValue && highlightedValue === value),
                      'text--faded':
                        (hoveredMetricLabel &&
                          hoveredMetricLabel !== metricName) ||
                        (highlightedValue && highlightedValue !== value),
                    })}
                    key={uuidv4()}
                    x={xScaleTickValue - 8}
                    y={yScaleTickValue + 3}
                    style={{
                      textAnchor: 'end',
                      transform: 'translate(-10,4)',
                    }}
                  >
                    {value?.toFixed(3)}
                  </text>
                );
              })}
            </g>
          );
        })}

        {graph.map(([metricName, values], metricIndex) => {
          const sortedValues = getUniqueValues(values);

          return (
            <g
              className="tick-lines"
              id={metricName}
              key={`tick-lines--${metricName}`}
            >
              {sortedValues.map((value) => {
                // To ensure the hoveredValues are highlighted once per axis
                const highlightedValue =
                  hoveredValues &&
                  hoveredValues.find(
                    (value, index) => index === metricIndex && value
                  );

                const xScaleMetricName = isNaN(xScale(metricName))
                  ? 0
                  : xScale(metricName);

                const yScaleMetricName = isNaN(yScales[metricName](value))
                  ? 0
                  : yScales[metricName](value);

                if (value) {
                  return (
                    <line
                      className={classnames('line', {
                        'line--hovered':
                          hoveredMetricLabel === metricName ||
                          (highlightedValue && highlightedValue === value),
                        'line--faded':
                          (hoveredMetricLabel &&
                            hoveredMetricLabel !== metricName) ||
                          (highlightedValue && highlightedValue !== value),
                      })}
                      key={uuidv4()}
                      x1={xScaleMetricName}
                      x2={xScaleMetricName - 4}
                      y1={yScaleMetricName}
                      y2={yScaleMetricName}
                    />
                  );
                } else {
                  return null;
                }
              })}
            </g>
          );
        })}

        <g className="selected-runs">
          {selectedData.map(([id, value], i) => (
            <path
              className={classnames({
                'run-line--selected-first': i === 0,
                'run-line--selected-second': i === 1,
                'run-line--selected-third': i === 2,
              })}
              d={linePath(value, i)}
              id={id}
              key={id}
            />
          ))}

          {selectedData.map(([, values], i) =>
            values.map((value, index) => {
              const transformX = xScale(graphKeys[index]);
              const transformY = yScales[graphKeys[index]](value);
              const rotate = selectedMarkerRotate[i];
              const xScaleGraphKey = isNaN(xScale(graphKeys[index]))
                ? 0
                : xScale(graphKeys[index]);

              const yScaleGraphKey = isNaN(yScales[graphKeys[index]](value))
                ? 0
                : yScales[graphKeys[index]](value);

              return (
                <React.Fragment key={uuidv4()}>
                  <path
                    className={`marker-path--selected-${i}`}
                    d={`${d3.symbol(selectedMarkerShape[i], 20)()}`}
                    key={`marker-path--${index}`}
                    transform={`translate(${transformX}, ${transformY}) rotate(${rotate})`}
                  />
                  <text
                    className="text"
                    key={`marker-text--${index}`}
                    x={xScaleGraphKey - 8}
                    y={yScaleGraphKey + 3}
                    style={{
                      textAnchor: 'end',
                      transform: 'translate(-10,4)',
                    }}
                  >
                    {value?.toFixed(3)}
                  </text>
                </React.Fragment>
              );
            })
          )}
        </g>
      </svg>
    </div>
  );
};
