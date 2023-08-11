/**
 * Take a value and return a meaningful value for display on experiment tracking tables
 * @param {value} value The value to be sanitized
 * @returns A sanitized value
 */
export const sanitizeValue = (value) => {
  if (value === '' || value === null || value === undefined) {
    return '-';
  } else if (typeof value === 'object' || typeof value === 'boolean') {
    return JSON.stringify(value);
  }

  return value;
};

/**
 * Takes a set of run metadata and run tracking data to construct the array object for csv export
 * @param {Array} runMetadata The set of runMetadata
 * @param {Array} runTrackingData The set of runTrackingData
 * @returns An array formatted for CSV export
 */
export const constructExportData = (runMetadata, runTrackingData) => {
  let csvData = [];

  if (runMetadata && runTrackingData) {
    // Obtain runMetadata
    const runTitle = runMetadata?.map((run) => sanitizeValue(run.title));
    const createdBy = runMetadata?.map((run) => sanitizeValue(run.author));
    const gitSha = runMetadata?.map((run) => sanitizeValue(run.gitSha));
    const gitBranch = runMetadata?.map((run) => sanitizeValue(run.gitBranch));
    const runCommand = runMetadata?.map((run) => sanitizeValue(run.runCommand));
    const notes = runMetadata?.map((run) => sanitizeValue(run.notes));

    csvData.push(
      ['Title', ...runTitle],
      ['Created By', ...createdBy],
      ['Git SHA', ...gitSha],
      ['Git Branch', ...gitBranch],
      ['Run Command', ...runCommand],
      ['Notes', ...notes]
    );

    // Create empty line between metadata fields and tracking data fields.
    csvData.push([]);

    buildCSVRows('Metrics');
    buildCSVRows('JSON Data');

    function buildCSVRows(section) {
      runTrackingData[section].forEach((trackingDataset) => {
        const { datasetName, data } = trackingDataset;
        const dataKeyNames = Object.keys(data).sort((a, b) => {
          return a.localeCompare(b);
        });

        csvData.push([datasetName]);

        dataKeyNames.forEach((key) => {
          let keyData = [key];

          data[key].forEach((dataField) => keyData.push(dataField.value));
          csvData.push(keyData);
        });

        csvData.push([]);
      });
    }
  }

  return csvData;
};

/**
 * Take a the runMetadata list to generate a meaningful file name for csv export
 * @param {Array} runMetadata The set of runMetadata to be exported
 * @returns A string to be used as the file name
 */
export const generateCSVFileName = (runMetadata) => {
  let filename = 'rundata';

  runMetadata?.forEach((run) => (filename += `-${run.id}`));
  filename += '.csv';

  return filename;
};
