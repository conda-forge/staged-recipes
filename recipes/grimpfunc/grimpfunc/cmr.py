#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
Simplified version of NSIDC Download Script to return links without downloading
created by Scott Henderson
'''

import requests
import itertools

CMR_URL = 'https://cmr.earthdata.nasa.gov'
URS_URL = 'https://urs.earthdata.nasa.gov'
CMR_PAGE_SIZE = 2000
CMR_FILE_URL = (f'{CMR_URL}/search/granules.json?provider=NSIDC_ECS'
                f'&sort_key[]=start_date&sort_key[]=producer_granule_id'
                f'&scroll=false&page_size={CMR_PAGE_SIZE}')


def cmr_filter_urls(search_results):
    """Select only the desired data files from CMR response."""
    if 'feed' not in search_results or 'entry' not in search_results['feed']:
        return []

    entries = [e['links']
               for e in search_results['feed']['entry']
               if 'links' in e]
    # Flatten "entries" to a simple list of links
    links = list(itertools.chain(*entries))
    # print(len(links))
    urls = []
    unique_filenames = set()
    for link in links:
        if 'href' not in link:
            # Exclude links with nothing to download
            continue
        if 'inherited' in link and link['inherited'] is True:
            # Why are we excluding these links?
            continue
        if 'rel' in link and 'data#' not in link['rel']:
            # Exclude links which are not classified by CMR as "data" or
            # "metadata"
            continue

        if 'title' in link and 'opendap' in link['title'].lower():
            # Exclude OPeNDAP links--they are responsible for many duplicates
            # This is a hack; when the metadata is updated to properly identify
            # non-datapool links, we should be possible in a non-hack way
            continue

        filename = link['href'].split('/')[-1]
        if filename in unique_filenames:
            # Exclude links with duplicate filenames (they would overwrite)
            continue
        unique_filenames.add(filename)

        urls.append(link['href'])

    return urls


def query_cmr(query_url):
    ''' return JSON / python dictionary'''
    # print(query_url)
    response = requests.get(query_url)
    search_results = response.json()
    return search_results


def build_cmr_query_url(short_name, version, time_start, time_end, page,
                        bounding_box=None, polygon=None,
                        filename_filter=None):
    params = f'&short_name={short_name}'
    params += f'&version={version}'
    params += f'&temporal[]={time_start},{time_end}'
    if polygon:
        params += f'&polygon={polygon}'
    elif bounding_box:
        params += f'&bounding_box[]={bounding_box}'
    if filename_filter:
        option = '&options[producer_granule_id][pattern]=true'
        params += f'&producer_granule_id[]={filename_filter}{option}'
    # Return search string
    return CMR_FILE_URL + f'&page_num={page}' + params


def get_urls(short_name, version, time_start, time_end, bounding_box, polygon,
             filename_filter, verbose=False):
    urls = []
    # Loop over pages - this should allow 30,000 returns 15*2000
    for page in range(1, 16):
        query_url = build_cmr_query_url(short_name, version, time_start,
                                        time_end, page,
                                        bounding_box, polygon, filename_filter)
        if verbose:
            print(query_url)
        search_results = query_cmr(query_url)
        # print(search_results)
        urls += cmr_filter_urls(search_results)
        # Page not full so done
        if len(search_results['feed']['entry']) < CMR_PAGE_SIZE:
            return urls
