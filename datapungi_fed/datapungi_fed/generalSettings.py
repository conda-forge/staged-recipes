'''
  .generalSettings
  ~~~~~~~~~~~~~~~~~
  Loads general information: metadata of the datasource, metadata of the package's 
  database drives (methods connecting to the databases of the datasource), 
  and the datasource url and user api key.
'''

from datapungi_fed import utils

class getGeneralSettings(): #NOTE: write as a mixin?
    def __init__(self,connectionParameters={},userSettings={}):
        ''' 
         sessionParameters  - API key and the url (most used) of the datasource
           entry should look like:
           {'key': 'your key', 'description': 'BEA data', 'address': 'https://apps.bea.gov/api/data/'}
         userSettings - containg things like the path to api keys, preferred output format (json vs xml)
         datasourceOverview - a quick description of the datasource and its license
         packageMetadata - basic info on the package - to be used in a GUI or catalog of 
            methods that read data.  Also, "databases" will get automaticall updated with
            info on the methods that get specific dataset from the datasource.  A typical 
            entry should look like:
            {
                 "displayName":"List of Datasets",
                 "method"     :"datasetlist",   #NOTE run with getattr(data,'datasetlist')()
                 "params"     :{},              #No parameters in this case.
            }
        '''
        
        #Load, for example, API Key and the (most used) path to the datasource
        self.userSettings         = utils.getUserSettings(userSettings=userSettings)
        self.connectionParameters = utils.getConnectionParameters(connectionParameters,userSettings)
        self.baseRequest          = getBaseRequest(self.connectionParameters,self.userSettings)
        self.datasourceOverview   = getDatasourceOverview()
        self.packageMetadata      = getPackageMetadata()
               
            
def getBaseRequest(connectionParameters={},userSettings={}):
    '''
      translate the connection parameters, a flat dictionary, to the format used by 
      requests (or other connector), also, translate names to ones used by the datasource.        
    '''   
    if userSettings == {}:
        userSettings = dict(file_type = 'JSON')
        print("result format was set to JSON since none could be found or was passed as a 'ResultFormat' in userSettings")
    
    output = { #this is, for example, the base of a requests' request - the drivers add to this.
       'url' : connectionParameters['url'],
       'params' :{
         'api_key' : connectionParameters['key'],
         'file_type': userSettings["ResultFormat"]
       }
    }
    
    return(output)

def getDatasourceOverview():
    output = '''
         Userguides:
         
         Licenses (always check with the data provider):
            Data used is sourced from Federal Reserve (FED)
            As stated on its website: 
            -                  
            For more information, see: 
               
        '''   
    
    return(output)

def getPackageMetadata():
    output = {
        "name":             "datapungi_fed",
        "loadPackageAs" :   "dpf",
        "apiClass":         "data",
        "displayName":      "FED",
        "description":      "Access data from the Federal Reserve (FED)",
        "databases":        [  #TODO: pass this to the driver, load the individual drivers metdata in the api.
                        {
             "displayName":"categories",
             "method"     :"categories",   
             "params"     :{}, #Parameters and default options.
            },
                        {
             "displayName":"tags",
             "method"     :"tags",   
             "params"     :{ 'category_id': '125', 'file_type': 'json', 'realtime_start': '', 'realtime_end':   '', 'tag_names' : '', 'exclude_tag_names':'', 'tag_group_id': '', 'search_text': '', 'limit':'', 'offset':'', 'order_by':'', 'sort_order':'' }, #Parameters and default options.
            },
                               
          ],
     }  
    
    return(output)