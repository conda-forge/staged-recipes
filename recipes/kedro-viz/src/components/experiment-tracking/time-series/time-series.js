import React, { useContext, useEffect, useState } from 'react';
import classnames from 'classnames';
import { formatTimestamp } from '../../../utils/date-utils';
import { usePrevious } from '../../../utils/hooks';
import { HoverStateContext } from '../utils/hover-state-context';
import {
  ExperimentTrackingTooltip,
  tooltipDefaultProps,
} from '../tooltip/tooltip';
import { getTooltipPosition } from '../tooltip/get-tooltip-position';
import * as d3 from 'd3';

import './time-series.css';

export const getSelectedOrderedData = (runData, selectedRuns) => {
  return runData
    .filter(([key, _]) => selectedRuns.includes(key))
    .sort((a, b) => {
      // We need to sort the selected data to match the order of selectedRuns.
      // If we didn't, the highlighted runs would switch colors unnecessarily.
      return selectedRuns.indexOf(a[0]) - selectedRuns.indexOf(b[0]);
    })
    .map(([key, value], i) => [new Date(formatTimestamp(key)), value]);
};

const chartBuffer = 0.02;
const height = 150;
const margin = { top: 20, right: 10, bottom: 80, left: 35 };
const yScales = {};

export const TimeSeries = ({
  chartWidth,
  metricsData,
  selectedRuns,
  sidebarVisible,
}) => {
  const previouslySelectedRuns = usePrevious(selectedRuns);
  const [showTooltip, setShowTooltip] = useState(tooltipDefaultProps);
  const [rangeSelection, setRangeSelection] = useState(undefined);

  const { hoveredElementId, setHoveredElementId } =
    useContext(HoverStateContext);

  const defaultChartWidth = isNaN(chartWidth) ? 100 : chartWidth;

  const selectedMarkerRotate = [45, 0, 0];
  const selectedMarkerShape = [
    d3.symbolSquare,
    d3.symbolCircle,
    d3.symbolTriangle,
  ];

  const hoveredElementDate =
    hoveredElementId && new Date(formatTimestamp(hoveredElementId));

  const hoveredValues = hoveredElementId && metricsData.runs[hoveredElementId];

  const metricKeys = Object.keys(metricsData.metrics);
  const metricData = Object.entries(metricsData.metrics);
  const runKeys = Object.keys(metricsData.runs);
  const runData = Object.entries(metricsData.runs);

  const parsedData = runData.map(([key, value]) => [
    new Date(formatTimestamp(key)),
    value,
  ]);
  const parsedDates = parsedData.map(([key, _]) => key);

  const diffDays = parseInt(
    (d3.max(parsedDates) - d3.min(parsedDates)) / (1000 * 60 * 60 * 24),
    10
  );
  const minDate = new Date(d3.min(parsedDates));
  minDate.setDate(minDate.getDate() - diffDays * chartBuffer);
  const maxDate = new Date(d3.max(parsedDates));
  maxDate.setDate(maxDate.getDate() + diffDays * chartBuffer);

  const selectedData = runData
    .filter(([key, _]) => selectedRuns.includes(key))
    .map(([key, value], i) => [new Date(formatTimestamp(key)), value]);

  metricData.map(
    ([_, value], i) =>
      (yScales[i] = d3
        .scaleLinear()
        .domain([
          Math.min(...value) - Math.min(...value) * chartBuffer,
          Math.max(...value) + Math.max(...value) * chartBuffer,
        ])
        .range([height, 0]))
  );

  const xScale = d3
    .scaleTime()
    .domain([minDate, maxDate])
    .range([0, defaultChartWidth]);

  if (rangeSelection) {
    xScale.domain(rangeSelection);
  }

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
    d3.selectAll(`line[id="${hoveredElementId}"]`).raise();
  }, [hoveredElementId]);

  if (previouslySelectedRuns !== selectedRuns) {
    if (rangeSelection) {
      setRangeSelection(undefined);
    }
  }

  return (
    <div className="time-series">
      <ExperimentTrackingTooltip
        content={showTooltip.content}
        direction={showTooltip.direction}
        position={showTooltip.position}
        visible={showTooltip.visible}
      />
      {metricKeys.map((metricName, metricIndex) => {
        const metricValues = Object.values(metricsData.metrics)[metricIndex];

        const getXAxis = (ref) => {
          if (rangeSelection) {
            d3.select(ref)
              .transition()
              .duration(1000)
              .call(d3.axisBottom(xScale).tickSizeOuter(0));
          } else {
            d3.select(ref).call(d3.axisBottom(xScale).tickSizeOuter(0));
          }
        };

        const getYAxis = (ref) => {
          d3.select(ref).call(
            d3
              .axisLeft(yScales[metricIndex])
              .tickSizeOuter(0)
              .tickFormat((x) => `${x.toFixed(2)}`)
          );
        };

        const lineGenerator = d3.line().defined(function (d) {
          return d !== null;
        });

        const linePath = (data) => {
          let points = data.map((x, i) => {
            if (x !== null) {
              return [xScale(parsedDates[i]), yScales[metricIndex](x)];
            } else {
              return null;
            }
          });

          return lineGenerator(points);
        };

        const trendLinePath = (data) => {
          let points = data.map(([key, value]) => {
            if (value !== null) {
              return [xScale(key), yScales[metricIndex](value[metricIndex])];
            } else {
              return null;
            }
          });
          return d3.line()(points);
        };

        const brush = d3
          .brushX()
          .extent([
            [0, 0],
            [defaultChartWidth, height],
          ])
          .on('end', (e) => {
            if (e.selection) {
              const indexSelection = e.selection.map(xScale.invert);
              setRangeSelection(indexSelection);
              d3.selectAll('.time-series__brush').call(brush.move, null);
            }
          });

        d3.selectAll('.time-series__brush').call(brush);

        const resetXScale = () => setRangeSelection(undefined);

        return (
          <React.Fragment key={metricName + metricIndex}>
            <div className="time-series__metric-name">{metricName}</div>
            <svg
              preserveAspectRatio="xMinYMin meet"
              key={`time-series--${metricName}`}
              width={defaultChartWidth + margin.left + margin.right}
              height={height + margin.top + margin.bottom}
            >
              <defs>
                <clipPath id="clip">
                  <rect x={0} y={0} width={defaultChartWidth} height={height} />
                </clipPath>
              </defs>

              <defs>
                <clipPath id="brush_clip">
                  <rect
                    height={height - 1}
                    width={defaultChartWidth}
                    x={0}
                    y={0.5}
                  />
                </clipPath>
              </defs>

              <g
                id={metricName}
                transform={`translate(${margin.left},${margin.top})`}
              >
                <g
                  className="time-series__runs-axis"
                  ref={getXAxis}
                  transform={`translate(0,${height})`}
                />

                <g className="time-series__metric-axis" ref={getYAxis} />

                <g
                  className="time-series__metric-axis-dual"
                  ref={getYAxis}
                  transform={`translate(${defaultChartWidth},0)`}
                />

                <text
                  className="time-series__axis-label"
                  x={-10 - height / 2}
                  y={10 - margin.left}
                >
                  value
                </text>

                <g className="time-series__brush" onDoubleClick={resetXScale} />

                <g
                  className="time-series__run-lines"
                  clipPath="url(#brush_clip)"
                >
                  {parsedData.map(([key, _], index) => (
                    <line
                      className={classnames('time-series__run-line', {
                        'time-series__run-line--hovered':
                          hoveredElementId === runKeys[index],
                        'time-series__run-line--blend':
                          hoveredElementId || selectedRuns.length > 1,
                      })}
                      id={runKeys[index]}
                      key={key + index}
                      x1={xScale(key)}
                      y1={0}
                      x2={xScale(key)}
                      y2={height}
                      onMouseOver={(e) =>
                        handleMouseOverLine(e, runKeys[index])
                      }
                      onMouseLeave={handleMouseOutLine}
                    />
                  ))}
                </g>

                {hoveredValues && (
                  <g className="time-series__hovered-line-group">
                    {hoveredValues.map((value, index) => {
                      if (metricIndex === index) {
                        return (
                          <React.Fragment key={value + index}>
                            <line
                              className="time-series__hovered-line"
                              x1={0}
                              y1={yScales[index](value)}
                              x2={defaultChartWidth}
                              y2={yScales[index](value)}
                            />
                            <g className="time-series__ticks">
                              <line
                                className="time-series__tick-line"
                                x1={xScale(hoveredElementDate)}
                                y1={yScales[index](value)}
                                x2={xScale(hoveredElementDate) - 5}
                                y2={yScales[index](value)}
                              />
                              <text
                                className="time-series__tick-text"
                                x={xScale(hoveredElementDate)}
                                y={yScales[index](value)}
                              >
                                {value?.toFixed(3)}
                              </text>
                            </g>
                          </React.Fragment>
                        );
                      } else {
                        return null;
                      }
                    })}
                    ;
                  </g>
                )}

                <g
                  className={classnames('time-series__metric-line', {
                    'time-series__metric-line--blend':
                      hoveredElementId || selectedRuns.length > 1,
                  })}
                  clipPath="url(#clip)"
                >
                  <path d={linePath(metricValues)} />
                </g>

                <g
                  className="time-series__selected-group"
                  clipPath="url(#brush_clip)"
                >
                  {getSelectedOrderedData(runData, selectedRuns).map(
                    ([key, value], index) => (
                      <React.Fragment key={key + value}>
                        <line
                          className={`time-series__run-line--selected-${index}`}
                          x1={xScale(key)}
                          y1={0}
                          x2={xScale(key)}
                          y2={height}
                        />
                        <text
                          className="time-series__tick-text"
                          x={xScale(key)}
                          y={yScales[metricIndex](value[metricIndex])}
                        >
                          {value[metricIndex]?.toFixed(3)}
                        </text>
                        <path
                          className={`time-series__marker--selected-${index}`}
                          d={`${d3.symbol(selectedMarkerShape[index], 20)()}`}
                          transform={`translate(${xScale(key)},${yScales[
                            metricIndex
                          ](value[metricIndex])}) 
                  rotate(${selectedMarkerRotate[index]})`}
                        />
                      </React.Fragment>
                    )
                  )}
                </g>

                <g className="time-series__trend-line">
                  <path d={trendLinePath(selectedData)} />
                </g>
              </g>
            </svg>
          </React.Fragment>
        );
      })}
    </div>
  );
};
