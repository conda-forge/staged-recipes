<!--
TODO: add explanation of the request part of the vintage.
-->

[![image](https://img.shields.io/pypi/v/datapungi_fed.svg)](https://pypi.org/project/datapungi_fed/) 
[![build Status](https://travis-ci.com/jjotterson/datapungi_fed.svg?branch=master)](https://travis-ci.com/jjotterson/datapungi_fed)
[![Downloads](https://pepy.tech/badge/datapungi-fed)](https://pepy.tech/project/datapungi-fed)
[![image](https://img.shields.io/pypi/pyversions/datapungi_fed.svg)](https://pypi.org/project/datapungi_fed/)

install code: pip install datapungi_fed 

<h1> datapungi_fed  </h1>

  datapungi_fed is a python package that extracts FRED and GeoFRED data from the Federal Reserve (FED) by connecting to its API.  Overall it:
  - provides a quick access to a FED's time-series data (just two lines of code away to any time-series!)
  - provides both a cleaned up output (pandas) and a full request output of any FRED or GeoFRED dataset.
  - provides code snippets that can be used to access the FED API independently of datapungi_fed     
  - can read a saved API key (as an environment variables (default) or from json/yaml files) to avoid having a copy of it on a script
  - can run many tests: check if all database access are working, if the data is being cleaned correctly, and if the code snippet returns the correct data. 


## Sections
  -  [Short sample runs](#Sample-runs)
  -  [Short sample runs of all drivers](#Sample-run-of-all-drivers)
  -  [Description of a full return](#Full-request-result) 
  -  [Setting up datapungi_fed](#Setting-up-datapungi_fed)
  -  [Testing the package](#Running-Tests) 

## Sample runs

### Short runs:

There are many datasets available in the FED API, and datapungi_fed connects to them all, but it is specially designed to quickly access the FED's time-series data.  After [setting the package up](#Setting-up-datapungi_fed), a time-series symbol (say 'gdp') can be fetched by typing:

```python
import datapungi_fed as dpf

dpf('gdp') 
```

If in doubt, try the print command on an datapungi_fed object to get information on how to proceed.

```python
'''Getting Help'''

import datapungi_fed as dpf

print(dpf)         #suggests to run data = dpf.data()

data = dpf.data()
print(data)        #list the database groups (eg. geo) and short description of each

print(data.geo)    #list the databases in the groups, their short descriptions and parameters
print(data.categories)    
print(data.series)        
```



At a top level, FRED has 5 groups of databases and we group the GeoFRED under the same group ("geo"). datapungi_fed includes a 6th group (datasetlist). 


FRED database group   | description
----------- | -----------
dataselist                                              | datapungi_fed metadata of all other (FRED and GeoFRED) databases
[categories](https://fred.stlouisfed.org/categories/)   | Catagories of datasets - 8 top categories (eg, National Accounts, Prices) that break down into subgroups 
[releases ](https://fred.stlouisfed.org/releases/)      | Release groups of data - about 300 (eg, Western Hemisphere Regional Economic Outlook, Penn World Table)
[series   ](https://fred.stlouisfed.org/)               | About 600,000 time series provided by various sources
[sources  ](https://fred.stlouisfed.org/sources/)       | List of data sources - about 90 data providers (eg, IMF and Bank of Mexico)
[tags     ](https://fred.stlouisfed.org/tags/)          | Tags applied to time series (eg, location, data source, frequency) - about 5,000 tags
[geo      ](https://research.stlouisfed.org/docs/api/geofred/)  | Harvest data and shape files found in GeoFRED 


These groups of databases are broken down into sets of databases.  datapungi_fed access all of them, but 
for each group it defaults to a specific case (use the "print" command as described above to get the name of the default database).  Below is a run sample of each default search.

```python
'''Sample Query of All Database Groups - Default Databases'''

import datapungi_fed as dpf

data = dpf.data() 

data.datasetlist()       
data.categories(125)   
data.releases()
data.series('GDP')
data.sources('1')   
data.tags(tag_names='monetary+aggregates;weekly')
data.geo(series_id='WIPCPI')
```
NOTICE: all returned pandas dataframes contain a "_meta" attribute with metadata information of dataset.

```python
'''Returned Metadata'''

import datapungi_fed as dpf

dpf('gnp')._meta
```
NOTICE: "meta" is not a pandas official attribute; slight changes to the dataframe (say, merging, or multiplying it by a number) will remove meta.

### Verbose 

Use the verbose option to get the full request result, a cleaned version of the dataset, and a string of the code used to get the data.

```python
'''Verbose Run: Get Full Request Result, Cleaned Data, and Code Snippet'''

import datapungi_fed as dpf

data = dpf.data()
full = data.series('gnp',verbose=true)  
full['dataFrame']           #pandas table, as above
full['request']             #full request run, see section below
full['code']                #code snippet of a request that reproduces the query. 

#to get the request result:
full['request'].json()
```
 
Notice: By default, datapungi_fed requests data in json format.   

### Sample run of all drivers




```python
'''Sample Run of All Datasets'''
import datapungi_fed as dpf


data = dpf.data()

# Categories data group
print(data.categories)
data.categories(125)
data.categories['category'](125)
data.categories['children'](13)
data.categories['related'](32073)
data.categories['series'](125)
data.categories['tags'](125)
data.categories['related_tags'](125,tag_names="services;quarterly")
    
# Releases data group
print(data.releases)
data.releases(verbose=True)
data.releases['releases'](verbose=True)
data.releases['release/dates'](release_id=53,verbose=True)
data.releases['release'](release_id=53,verbose=True)
data.releases['release/dates'](release_id=53,verbose=True)
data.releases['release/series'](release_id=53,verbose=True)
data.releases['release/sources'](release_id=53,verbose=True)
data.releases['release/tags'](release_id=53,verbose=True)
data.releases['release/related_tags'](release_id='86',tag_names='sa;foreign',verbose=True)
data.releases['release/tables'](release_id=53,verbose=True)
    
# Series data group
print(data.series)
data.series('gdp',verbose=True) 
data.series['series']('GDP',verbose=True)
data.series['categories']('EXJPUS',verbose=True)
data.series['observations']('GNP',verbose=True)
data.series['release']('IRA',verbose=True)
data.series['search'](search_text='monetary+service+index',verbose=True)
data.series['search/tags'](series_search_text='monetary+service+index',verbose=True)
data.series['search/related_tags'](series_search_text='mortgage+rate',tag_names='30-year;frb',verbose=True)
data.series['tags'](series_id='STLFSI',verbose=True)
data.series['categories']('EXJPUS',verbose=True)
data.series['updates'](verbose=True)
data.series['vintagedates']('GNPCA',verbose=True)
    
# Tags data group
print(data.tags)
data.tags(tag_names='monetary+aggregates;weekly',verbose=True)
data.tags['tags'](tag_names='monetary+aggregates;weekly',verbose=True)
data.tags['related_tags'](tag_names='monetary+aggregates;weekly',verbose=True)
data.tags['tags/series'](tag_names='slovenia;food;oecd',verbose=True)

#Geo data group
print(data.geo)
data.geo['shapes']('bea')
data.geo['meta'](series_id='SMU56000000500000001')
data.geo(series_id='WIPCPI',start_date='2012-01-01')
data.geo['data'](series_group='882',date='2013-01-01',region_type='state',units='Dollars',frequency='a',season='NSA')
```





## Setting up datapungi_fed 

To use the FED API, **the first step** is to [get an API key from the FED](https://research.stlouisfed.org/docs/api/api_key.html).

### Quick Setup (Suggest Setup)

For a quick setup, just save your api key as an environment variable called API_KEY_FED by, for example, typing on a termninal:

- windows:
   ```
   > setx API_KEY_FED "your api key"
   ```
- mac:
  ```
  $ touch ~/.bash_profile
  $ open -a TextEdit.app ~/.bash_profile
  ```
  add the following text at the end and save it: 
  
  ```
  export API_KEY_FED=yourKey 
  ```

Close the terminal (may need to restart the computer) after saving the variable. 


Notice: searching for an environment variable named 'API_KEY_FED' is the default option.  If changed to some other option and want to return to the default, run:

```python
import datapungi_fed as dpf

dpf.utils.setUserSettings('env')  
```

If you want to save the url of the API in the environment, call it API_KEY_FED_url. datapungi_fed will use the provided http address instead of the default. 

### Other setting up options:

Besides the suggested setup above, there are two main options to pass an api key to datapungi_fed:

#### (Option 1) Pass the key directly:
```python
import datapungi_fed as dpf

data = dpf.data("API KEY")

data.series('gdp')
```

#### (Option 2) Save the key in either a json or yaml file and let datapungi_fed know its location:

 sample json file : 
```python
    {  
         "API_KEY_FED": {"key": "**PLACE YOUR KEY HERE**", "url": ""},
         (...Other API keys...)
    }
```
sample yaml file:

```yaml
API_KEY_FED: 
    key: PLACE API KEY HERE
    description: FED data
    url: 
api2:
    key:
    description:
    url:
```

Save the path to your FED API key on the package's user settings (only need to run the utils once, datapungi_fed will remember it in future runs):


```python
import datapungi_fed as dpf

dpf.utils.setUserSettings('C:/Path/myKeys.yaml') #or .json

data = dpf.data()
data.series('gdp')
```
 

### Changing the API key name
  By default, datapungi_fed searches for an API key called 'API_KEY_FED' (in either json/yaml file or in the environment).  In some cases, it's preferable to call it something else (eg, in a conda env can use FED_Secret to encript it).  To change the name of the key, run

  ```python
  import datapungi_fed as dpf
  
  dpf.utils.setKeyName('FED_Secret')  #or anyother prefered key name
  ```
  When using environment variables, if saving the API url in the environment as well, call it KeyLabel_url (for example, 'FED_Secret_url'). Else, datapungi_fed will use the default one.
  
## Running Tests

datapungi_fed comes with a family of tests to check its access to the API and the quality of the retrieved data.  They check if:

1. the connection to the API is working,
2. the data cleaning step worked,
3. the code snippet is executing,
4. the code snippet produces the same data as the datapungi_fed query.

Other tests check if the data has being updated of if new data is available.  Most of these tests are run every night on python 3.6 and 3.7 (see the code build tag on the top of the document).  However, 
these test runs are not currently checking the code snippet quality to check if its output is the same as the driver's. To run the tests, including the one 
that checks code snippet quality, type:

```python
import datapungi_fed as dpf

dpf.tests.runTests()
```

the results should open on a web browser.  To re-open the last test results, run:

```python
import datapungi_fed as dpf

dpf.tests.viewTests()
```



To save the tests in a desired folder, run 

```python
import datapungi_fed as dpf

dpf.utils.setTestFolder('C:/mytestFolder/')
```

Future tests will be saved an html file called datapungi_fed_Tests.html in the path specified.


