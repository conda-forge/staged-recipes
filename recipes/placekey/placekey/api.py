import json
import logging
import itertools
import requests
from ratelimit import limits, RateLimitException
from backoff import on_exception, fibo
from .__init__ import __version__

console_log = logging.StreamHandler()
console_log.setFormatter(
    logging.Formatter('%(asctime)s\t%(levelname)s\t%(message)s')
)
log = logging.getLogger()
log.setLevel(logging.ERROR)
log.handlers = [console_log]


class PlacekeyAPI:
    """
    PlacekeyAPI class

    This class provides functionality for looking up Placekeys using the Placekey
    API. Places to be looked a specified by a **place dictionary** whose keys and value types
    must be a subset of

    * latitude (float)
    * longitude (float)
    * location_name (string)
    * street_address (string)
    * city (string)
    * region (string)
    * postal_code (string)
    * iso_country_code (string)
    * query_id (string)

    See the `Placekey API documentation <https://docs.placekey.io/>`_ for more
    information on how to use the API.

    :param api_key: Placekey API key (string)
    :param max_retries: Maximum number of times to retry a failed request before
        halting (int). Backoffs due to rate-limiting are included in the retry count. Defaults
        to 20.
    :param logger: A logging object. Logs are sent to the console by default.
    :param user_agent_comment: A string to append to the client's user agent, which will be
        "placekey-py/{version_number} {user_agent_comment}.

    """
    URL = 'https://api.placekey.io/v1/placekey'
    REQUEST_LIMIT = 1000
    REQUEST_WINDOW = 60

    BULK_URL = 'https://api.placekey.io/v1/placekeys'
    BULK_REQUEST_LIMIT = 100
    BULK_REQUEST_WINDOW = 60
    MAX_BATCH_SIZE = 100

    DEFAULT_USER_AGENT = 'placekey-py/{}'.format(__version__)

    DEFAULT_MAX_RETRIES = 20

    QUERY_PARAMETERS = {
        'latitude',
        'longitude',
        'location_name',
        'street_address',
        'city',
        'region',
        'postal_code',
        'iso_country_code',
        'query_id'
    }

    DEFAULT_QUERY_ID_PREFIX = "place_"

    def __init__(self, api_key=None, max_retries=DEFAULT_MAX_RETRIES, logger=log,
                 user_agent_comment=None):
        self.api_key = api_key
        self.max_retries = max_retries
        self.logger = logger
        self.user_agent_comment = user_agent_comment

        self.key_ = {
            'Content-Type': 'application/json',
            'User-Agent': self.DEFAULT_USER_AGENT,
            'apikey': self.api_key
        }
        self.headers = self.key_

        if isinstance(self.user_agent_comment, str):
            self.headers['User-Agent'] = (
                    self.headers['User-Agent'] + " " + self.user_agent_comment).strip()

        # Rate-limited function for a single requests
        self.make_request = self._get_request_function(
            url=self.URL,
            calls=self.REQUEST_LIMIT,
            period=self.REQUEST_WINDOW,
            max_tries=self.max_retries)

        self.make_bulk_request = self._get_request_function(
            url=self.BULK_URL,
            calls=self.BULK_REQUEST_LIMIT,
            period=self.BULK_REQUEST_WINDOW,
            max_tries=self.max_retries)

    def lookup_placekey(self,
                        strict_address_match=False,
                        strict_name_match=False,
                        **kwargs):
        """
        Lookup the Placekey for a single place.

        :param strict_address_match: Boolean for whether or not to strict match
            on address fields. Defaults to `False`.
        :param strict_name_match: Boolean for whether or not to strict match
            on `location_name`. Defaults to `False`.
        :kwargs: Place fields can be passed to this method as keyword arguments. The allowed
            keyword arguments are ['latitude', 'longitude', 'location_name','street_address',
            'city', 'region', 'postal_code', 'iso_country_code', 'query_id']

        :return: A Placekey API response (dict)

        """
        if not self._validate_query(kwargs):
            raise ValueError(
                "Query contains keys other than: {}".format(self.QUERY_PARAMETERS))

        payload = {"query": kwargs}
        if strict_address_match:
            payload['options'] = {"strict_address_match": True}
        if strict_name_match:
            payload['options'] = {"strict_name_match": True}

        # Make request, and retry if there is a server-side rate limit error
        while True:
            result = self.make_request(payload)
            if result.status_code != 429:
                break

        return json.loads(result.text)

    def lookup_placekeys(self,
                         places,
                         strict_address_match=False,
                         strict_name_match=False,
                         batch_size=MAX_BATCH_SIZE,
                         verbose=False):
        """
        Lookup Placekeys for an iterable of places specified by place dictionaries.
        This method checks that the place dictionaries are valid before querying
        the API, and it will return partial results if it encounters a fatal error.
        Places without a `query_id` will have one generated for them based on their
        index in `places`, e.g., "place_0" for the first item in the list, but a
        user-provided `query_id` will be passed through as is.

        This function is a wrapper for `lookup_batch`, and that function may be
        used if different error handling or logic around batch processing is desired.

        This method follows the rate limits of the Placekey API.

        :param places: An iterable of of place dictionaries.
        :param strict_address_match: Boolean for whether or not to strict match
            on address fields. Defaults to `False`.
        :param strict_name_match: Boolean for whether or not to strict match
            on `location_name`. Defaults to `False`.
        :param batch_size: Integer for the number of places to lookup in a single batch.
            Defaults to 100, and cannot exceeded 100.
        :param verbose: Boolean for whether or not to log additional information.
            Defaults to False

        :return: A list of Placekey API responses for each place (list(dict))

        """
        if batch_size > self.MAX_BATCH_SIZE:
            raise ValueError("Batch size cannot exceed {}.".format(self.MAX_BATCH_SIZE))

        if not all([self._validate_query(a) for a in places]):
            raise ValueError(
                "Some queries contain keys other than: {}".format(self.QUERY_PARAMETERS))

        if verbose:
            self.logger.setLevel(logging.INFO)
            logging.getLogger('backoff').setLevel(logging.INFO)
        else:
            self.logger.setLevel(logging.ERROR)
            logging.getLogger('backoff').setLevel(logging.ERROR)

        # Add a query_id to each place that doesn't have one
        for i, place in enumerate(places):
            if 'query_id' not in place:
                place['query_id'] = self.DEFAULT_QUERY_ID_PREFIX + str(i)

        results = []
        for i in range(0, len(places), batch_size):
            max_batch_idx = min(i + batch_size, len(places))
            batch_query_ids = [p['query_id'] for p in places[i:max_batch_idx]]

            try:
                res = self.lookup_batch(
                    places[i:max_batch_idx],
                    strict_address_match=strict_address_match,
                    strict_name_match=strict_name_match
                )
            except RateLimitException:
                self.logger.error(
                    'Fatal error encountered. Returning processed items.')
                break

            # Catch case where all queries in batch having an error,
            # and generate rows for individual items.
            if isinstance(res, dict) and 'error' in res:
                self.logger.info(
                    'All queries in batch (%s, %s) had errors', i, max_batch_idx)

                res = [{'query_id': query_id,  'error': res['error']}
                       for query_id in batch_query_ids]

            # Catch other server-side errors
            elif 'message' in res:
                self.logger.error(res['message'])
                self.logger.error('Returning completed queries')
                break

            results.append(res)

            if max_batch_idx % (10 * batch_size) == 0 and i > 0:
                self.logger.info('Processed %s items', max_batch_idx)

        result_list = list(itertools.chain.from_iterable(results))
        self.logger.info('Processed %s items', len(result_list))
        self.logger.info('Done')

        return result_list

    def lookup_batch(self, places,
                     strict_address_match=False,
                     strict_name_match=False):
        """
        Lookup Placekeys for a single batch of places specified by place dictionaries.
        The batch size can be at most 100 places. This method respects the rate limits
        of the Placekey API.

        :param places: An iterable of of place dictionaries.
        :param strict_address_match: Boolean for whether or not to strict match
            on address fields. Defaults to `False`.
        :param strict_name_match: Boolean for whether or not to strict match
            on `location_name`. Defaults to `False`.

        :return: A list of Placekey API responses for each place (list(dict))

        """
        if len(places) > self.MAX_BATCH_SIZE:
            raise ValueError(
                '{} places submitted. The number of places in a batch can be at most {}'
                .format(len(places), self.MAX_BATCH_SIZE)
            )

        batch_payload = {
            "queries": places
        }
        if strict_address_match:
            batch_payload['options'] = {"strict_address_match": True}
        if strict_name_match:
            batch_payload['options'] = {"strict_name_match": True}

        # Make request, and retry if there is a server-side rate limit error
        while True:
            result = self.make_bulk_request(batch_payload)
            if result.status_code != 429:
                break

        return json.loads(result.text)

    def _validate_query(self, query_dict):
        return set(query_dict.keys()).issubset(self.QUERY_PARAMETERS)

    def _get_request_function(self, url, calls, period, max_tries):
        """
        Construct a rate limited function for making requests.

        :param url: request URL
        :param calls: number of calls that can be made in time period
        :param  period: length of rate limiting time period in seconds
        :param max_tries: the maximum number of retries before giving up
        """
        @on_exception(fibo, RateLimitException, max_tries=max_tries)
        @limits(calls=calls, period=period)
        def make_request(data):
            return requests.post(
                url, headers=self.headers,
                data=json.dumps(data).encode('utf-8')
            )

        return make_request
