import {
  removeChildFromObject,
  removeElementsFromObjectValues,
} from './object-utils';
import { data } from '../components/experiment-tracking/mock-data';

const mockToBeRemovedValues = {
  'Dataset1.Metrics1': 0,
  'Dataset1.Metrics2': 1,
  'Dataset1.Metrics3': 2,
};

test('return expected metrics which should not have the first 3 metrics keys "Dataset1.Metrics1", "Dataset1.Metrics2", and "Dataset1.Metrics3"', () => {
  const expected = {
    'Dataset2.Metrics4': [4, 2.9, 7.7, 3.5, 2.4, 2.4, 3.4, 6.4, 1.4],
    'Dataset2.Metrics5': [5, 6, 1, 2.1, 1.6, 5.6, 4.6, 2.6, 6.6],
    'Dataset2.Metrics6': [4, 2.9, 7.7, 3.5, 2.4, 2.4, 3.4, 6.4, 1.4],
    'Dataset1.Metrics7': [1, 3, 4.5, 2.4, 3.3, 5.3, 1.3, 6.5, 3.4],
    'Dataset1.Metrics8': [3, 1.3, 6.6, 6.6, 5.6, 5.6, 2.6, 1.6, 4.6],
    'Dataset2.Metrics9': [5, 6, 1, 2.1, 1.6, 5.6, 4.6, 2.6, 6.6],
  };

  const received = removeChildFromObject(
    data.metrics,
    Object.keys(mockToBeRemovedValues)
  );

  expect(received).toStrictEqual(expected);
});

test('return expected runs which should not have the first 3 values', () => {
  const expected = {
    '2022-09-05T12.27.04.496Z': [4, 5],
    '2022-10-05T12.22.35.825Z': [2.9, 6],
    '2022-12-24T21.05.59.296Z': [7.7, 1],
    '2022-08-24T21.04.31.605Z': [3.5, 2.1],
    '2022-08-24T21.03.25.671Z': [2.4, 1.6],
    '2022-07-22T13.49.08.764Z': [2.4, 5.6],
    '2022-07-21T12.54.06.759Z': [3.4, 4.6],
    '2022-07-20T15.39.58.437Z': [6.4, 2.6],
    '2022-06-22T13.13.06.258Z': [1.4, 6.6],
  };

  const received = removeElementsFromObjectValues(
    data.runs,
    Object.values(mockToBeRemovedValues)
  );

  expect(received).toStrictEqual(expected);
});
