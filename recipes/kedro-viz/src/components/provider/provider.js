import React from 'react';
import { ApolloProvider } from '@apollo/client';
import { client } from '../../apollo/config';

export const GraphQLProvider = ({ children }) => {
  return (
    <ApolloProvider client={client}>
      <>{children}</>
    </ApolloProvider>
  );
};
