// This file contains any web-workers used in the app, which are inlined by
// webpack + workerize-loader, so that they can be used in the exported library
// without needing any special configuration on the part of the consumer.
// Web workers don't work in Jest, so in a test environment we directly import
// them instead, and then mock up a faux-worker function

/* eslint-disable import/no-webpack-loader-syntax */

// Check for test environment
const isTest = typeof jest !== 'undefined';

// Conditionally load task via web worker only in non-test env
const graphWorker = isTest
  ? require('./graph')
  : require('workerize-loader?inline!./graph');

/**
 * Emulate a web worker for testing purposes
 */
const createMockWorker = (worker) => {
  if (!isTest) {
    return worker;
  }
  return () => {
    const mockWorker = {
      terminate: () => {},
    };
    Object.keys(worker).forEach((name) => {
      mockWorker[name] = (payload) =>
        new Promise((resolve) => resolve(worker[name](payload)));
    });
    return mockWorker;
  };
};

export const graph = createMockWorker(graphWorker);

/**
 * Manage the worker, avoiding race conditions by terminating running
 * processes when a new request is made, and reinitialising the instance.
 * Example getJob: (instance, payload) => instance.job(payload)
 * @param {Function} worker Init worker and return job functions
 * @param {Function} getJob Callback to select correct job function
 * @return {Function} Function which returns a promise
 */
export function preventWorkerQueues(worker, getJob) {
  let instance = worker();
  let running = false;

  return (payload) => {
    if (running) {
      // If worker is already processing a job, cancel it and restart
      instance.terminate();
      instance = worker();
    }
    running = true;

    return getJob(instance, payload).then((response) => {
      running = false;
      return response;
    });
  };
}
