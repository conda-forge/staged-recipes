'''
datapungi_fed.utils
~~~~~~~~~~~~~~~~~~

This module provides utility functions that are used 
within datapungibea and by the users when they want 
to update internal configs.
'''

import json
import pkg_resources
import yaml
import os

def getConnectionParameters(connectionParameters = {}, userSettings = {}):  
    '''
      :param userSettings: (optional) dictionary of  ``'ApiKeysPath': a path to json with API Keys`` and  ``'ApiKeyLabel': label (key) of JSON entry containing the key``
      If userSettings is an empty dictionary (default option), method will try to load it from saved userSettings.  

      output, a dictionary with user key and datasource url
    '''

    if not connectionParameters == {}:
        if isinstance(connectionParameters,str):  #in this case, user only passes a key, no url
            pkgcfgPath = getResourcePath("/config/pkgConfig.yaml")
            with open(pkgcfgPath, 'r') as stream:
               pkgCfg = yaml.safe_load(stream) 
            connectionParameters = {'url':pkgCfg['url'],'key':connectionParameters}
        return(connectionParameters)

    if userSettings == {}:
        userSettings = getUserSettings()

    try:
        storingMethod = userSettings['ApiKeysPath'].split('.')[-1]
        labelName = userSettings['ApiKeyLabel']
        if storingMethod == 'json': 
            with open(userSettings['ApiKeysPath']) as jsonFile:
                 connectionParameters = (json.load(jsonFile))[labelName]
        elif storingMethod == 'yaml':
            with open(userSettings['ApiKeysPath'], 'r') as stream:
                pkgCfg = yaml.safe_load(stream)
                connectionParameters = pkgCfg[labelName]
        elif storingMethod =='env':
            #look for an environment variable called something like BEA_url
            url = os.getenv(labelName+'_url')
            if url == None:  #if can't find it, load from the package config
                pkgcfgPath = getResourcePath("/config/pkgConfig.yaml")
                with open(pkgcfgPath, 'r') as stream:
                   pkgCfg = yaml.safe_load(stream) 
                url = pkgCfg['url']
            connectionParameters = {'key':os.getenv(labelName),'url':url}
        return(connectionParameters)
    except:
        print('Could not find dictionary key ' + labelName + ' in \n '+ userSettings['ApiKeysPath'])
        return   

def getResourcePath(relativePath, resource_package = __name__):
    '''
     Given relative, get its full path
     eg: relative path: /config/userSettings.json
     will return
     datapungibea path + relative path
     note: can replace resource_package with package name:
     eg: 'datapungi_fed'
    '''
    fullPath = pkg_resources.resource_filename(resource_package, relativePath)
    return(fullPath)

def getUserSettings(userSettings = {}):
    '''
        loads the userSettings file.
    '''
    if not userSettings == {}:
        return(userSettings)

    userSettingsPath = getResourcePath('/config/userSettings.json') 
    try:
        with open(userSettingsPath) as jsonFile:
             userSettings = json.load(jsonFile)
        return(userSettings)
    except:
        print('.utils.py: Could not open the userSettings: \n ./config/userSettings.json \n returning empty dictionary')
        return({})

def getPkgConfig():
    '''
      Reads the PkgConfig - eg the default url
    '''
    pkgcfgPath = getResourcePath("/config/pkgConfig.yaml")
    with open(pkgcfgPath, 'r') as stream:
        pkgCfg = yaml.safe_load(stream)    
    return(pkgCfg)

def setPkgConfig(newUrl):
    '''
     save the default url of the api
    '''
    if not isinstance(newUrl,str):
        print('Provide a string of the API URL')
        pass
    pkgcfgPath = getResourcePath("/config/pkgConfig.yaml")
    with open(pkgcfgPath, 'r') as stream:
        pkgCfg = yaml.safe_load(stream) 
    pkgCfg['url'] = newUrl
    with open(pkgcfgPath, 'w') as outfile:
         yaml.dump(pkgCfg,outfile, default_flow_style=False)
    
def setUserSettings(newPath):  #TODO: check if still valid
    '''
       sets the api key path in the package config file. 
       eg:
       import datapungi_fed as dp
       dp.utils.setUserSettings('myPath')
    '''
    userSettingsPath = getResourcePath('/config/userSettings.json')
    try:
        with open(userSettingsPath) as jsonFile:
             config = json.load(jsonFile)
    except:
        print('Could not open the configuration file: \n datapungi/config/userSettings.json')
        pass
    
    config['ApiKeysPath'] = newPath

    try:
        with open(userSettingsPath,'w') as jsonFile:
            json.dump(config,jsonFile)
        print('Path to the API Keys updated! New Path: \n' + config['ApiKeysPath'])
    except:
        print('Could not save the configuration to file: \n datapungi_fed/config/userSettings.json \n Path API Key not updated')
        pass

def setKeyName(newName):  #TODO: check if still valid
    '''
       sets the api key name in the package config file. 
       eg:
       import datapungi_fed as dp
       dp.utils.setKeyName('BEA_Secrete')
    '''
    userSettingsPath = getResourcePath('/config/userSettings.json')
    try:
        with open(userSettingsPath) as jsonFile:
             config = json.load(jsonFile)
    except:
        print('Could not open the configuration file: \n datapungi_fed/config/userSettings.json')
        pass
    
    config["ApiKeyLabel"] = newName

    try:
        with open(userSettingsPath,'w') as jsonFile:
            json.dump(config,jsonFile)
        print('Name of the API Keys updated! New Name: \n' + config["ApiKeyLabel"])
    except:
        print('Could not save the configuration to file: \n datapungibea/config/userSettings.json \n API Key Name not updated')
        pass

def setTestFolder(newTestsPath):
    userSettingsPath = getResourcePath('/config/userSettings.json')
    try:
        with open(userSettingsPath) as jsonFile:
             config = json.load(jsonFile)
    except:
        print('Could not open the configuration file: \n datapungi/config/userSettings.json')
        pass
    
    config['TestsOutputPath'] = newTestsPath

    try:
        with open(userSettingsPath,'w') as jsonFile:
            json.dump(config,jsonFile)
        print('Path to the Tests Output Folder updated! New Path: \n' + config['TestsOutputPath'])
    except:
        print('Could not save the configuration to file: \n datapungibea/config/userSettings.json \n Path to the Tests Output not updated')
        pass            

if __name__ == '__main__':
    setTestFolder('U:/Tests')