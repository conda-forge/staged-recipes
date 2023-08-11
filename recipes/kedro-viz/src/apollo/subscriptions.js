import gql from 'graphql-tag';

/** subscribe to receive new runs */
export const NEW_RUN_SUBSCRIPTION = gql`
  subscription {
    runsAdded {
      id
      bookmark
      gitSha
      title
    }
  }
`;
