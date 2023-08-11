import { useEffect, useState } from 'react';
import { useQuery } from '@apollo/client';

/**
 * @param {Apollo query Object} query
 * @param {Apollo query options Object} options
 * @returns The data from the query, including error and loading states
 */
export const useApolloQuery = (query, options) => {
  const [data, setData] = useState(undefined);
  const {
    subscribeToMore,
    data: queryData,
    error,
    loading,
  } = useQuery(query, options);

  useEffect(() => {
    if (queryData !== undefined) {
      setData(queryData);
    }
  }, [queryData]);

  return { subscribeToMore, data, error, loading };
};
