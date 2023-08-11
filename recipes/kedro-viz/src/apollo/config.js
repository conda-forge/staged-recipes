import fetch from 'cross-fetch';
import {
  ApolloClient,
  InMemoryCache,
  createHttpLink,
  split,
} from '@apollo/client';
import { getMainDefinition } from '@apollo/client/utilities';
import { WebSocketLink } from '@apollo/client/link/ws';
import { replaceMatches } from '../utils';

const { host, pathname, protocol } = window.location;
const sanitizedPathname = replaceMatches(pathname, {
  'experiment-tracking': '',
});

const wsHost = process.env.NODE_ENV === 'development' ? 'localhost:4142' : host;

const wsProtocol = protocol === 'https:' ? 'wss:' : 'ws:';

const wsLink = new WebSocketLink({
  uri: `${wsProtocol}//${wsHost}${sanitizedPathname}graphql`,
  options: {
    reconnect: true,
  },
});

const httpLink = createHttpLink({
  // our graphql endpoint, normally here: http://localhost:4141/graphql
  uri: `${sanitizedPathname}graphql`,
  fetch,
});

const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query);

    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    );
  },
  wsLink,
  httpLink
);

export const client = new ApolloClient({
  connectToDevTools: true,
  link: splitLink,
  cache: new InMemoryCache(),
  defaultOptions: {
    query: {
      errorPolicy: 'all',
    },
    mutate: {
      errorPolicy: 'all',
    },
  },
});
