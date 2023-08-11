import gql from 'graphql-tag';

/** query for runsList sidebar */
export const GET_RUNS = gql`
  query getRunsList {
    runsList {
      bookmark
      gitSha
      id
      title
      notes
    }
  }
`;

/** query for runMetadata and runDataset components */
export const GET_RUN_DATA = gql`
  query getRunData($runIds: [ID!]!, $showDiff: Boolean) {
    runMetadata(runIds: $runIds) {
      id
      author
      bookmark
      gitBranch
      gitSha
      notes
      runCommand
      title
    }
    plots: runTrackingData(runIds: $runIds, showDiff: $showDiff, group: PLOT) {
      ...trackingDatasetFields
    }
    metrics: runTrackingData(
      runIds: $runIds
      showDiff: $showDiff
      group: METRIC
    ) {
      ...trackingDatasetFields
    }
    JSONData: runTrackingData(
      runIds: $runIds
      showDiff: $showDiff
      group: JSON
    ) {
      ...trackingDatasetFields
    }
  }

  fragment trackingDatasetFields on TrackingDataset {
    data
    datasetName
    datasetType
    runIds
  }
`;

/** query for runMetricsData  */
export const GET_METRIC_PLOT_DATA = gql`
  query getMetricPlotData($limit: Int) {
    runMetricsData(limit: $limit) {
      data
    }
  }
`;

/** query for obtaining installed and latest Kedro-Viz versions */
export const GET_VERSIONS = gql`
  query getVersion {
    version {
      installed
      isOutdated
      latest
    }
  }
`;
