import { SchemaLink } from '@apollo/client/link/schema';
import { makeExecutableSchema } from '@graphql-tools/schema';
import GraphQLJSON, { GraphQLJSONObject } from 'graphql-type-json';

import gql from 'graphql-tag';

const typeDefs = gql`
  """
  Generic scalar type representing a JSON object
  """
  scalar JSONObject

  type Mutation {
    updateRunDetails(
      runId: ID!
      runInput: RunInput!
    ): UpdateUserDetailsResponse!
  }

  type Query {
    runsList: [Run!]!
    runMetadata(runIds: [ID!]!): [Run!]!
    runTrackingData(
      runIds: [ID!]!
      showDiff: Boolean = false
    ): [TrackingDataset!]!
  }

  type Run {
    id: ID!
    title: String!
    author: String
    gitBranch: String
    gitSha: String
    bookmark: Boolean
    notes: String
    runCommand: String
  }

  input RunInput {
    bookmark: Boolean = null
    title: String = null
    notes: String = null
  }

  type TrackingDataset {
    datasetName: String
    datasetType: String
    data: JSONObject
  }

  type UpdateRunDetailsFailure {
    id: ID!
    errorMessage: String!
  }

  union UpdateUserDetailsResponse =
      UpdateUserDetailsSuccess
    | UpdateRunDetailsFailure

  type UpdateUserDetailsSuccess {
    run: Run!
  }
`;

const resolvers = {
  JSON: GraphQLJSON,
  JSONObject: GraphQLJSONObject,
};

export const schemaLink = new SchemaLink({
  schema: makeExecutableSchema({ typeDefs, resolvers }),
});
