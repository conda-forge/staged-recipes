import gql from 'graphql-tag';
import { useMutation } from '@apollo/client';

export const UPDATE_RUN_DETAILS = gql`
  mutation updateRunDetails($runId: ID!, $runInput: RunInput!) {
    updateRunDetails(runId: $runId, runInput: $runInput) {
      ... on UpdateRunDetailsFailure {
        errorMessage
        id
      }
      ... on UpdateRunDetailsSuccess {
        run {
          bookmark
          id
          notes
          title
        }
      }
    }
  }
`;

export const useUpdateRunDetails = () => {
  const [_updateRunDetails, { error, loading, reset }] =
    useMutation(UPDATE_RUN_DETAILS);

  return {
    updateRunDetails: function (variables) {
      _updateRunDetails({ variables });
    },
    error,
    loading,
    reset,
  };
};
