import subprocess
import os
import platform
import webbrowser
from datapungi_fed.utils import getUserSettings, getResourcePath


def runTests(outputPath='',testsPath='',verbose = True):
    if not testsPath:
       testsPath =  getResourcePath('tests')
       if verbose:
           print('**************************** \nWill run tests in: ' + testsPath)
    if not outputPath:
        outputPath = getResourcePath('tests/testResults')
        try:
            #if not empty, use path saved in user settings.
            settingsFile = getUserSettings()
            if settingsFile['TestsOutputPath']:
                outputPath = settingsFile['TestsOutputPath']
        except:
            print("Could not load TestOutputPath from user settings.  Saving in package memory.  \n To set a path, run: util.setTestFolder( FilePath ) \n to view results run: tests.viewTests() ")
    outputTestFile = os.path.join(outputPath,'datapungi_fed_Tests.html')
    testCode = 'pytest "{testsPath}" --html="{outputTestFile}" --self-contained-html'.format(**{'outputTestFile':outputTestFile,'testsPath':testsPath})
    if platform.system() == 'Darwin':
        testCode = 'python3 -m ' + testCode
    proc = subprocess.Popen(testCode,shell=True)
    
    if verbose:
        proc.communicate()
        print(' \n**************************** \n Tests will be saved in \n {} \n opening results in Browser now.  To view run: \n datapungi_fed.tests.viewTests() \n****************************'.format(outputTestFile))
        webbrowser.open('file://'+outputTestFile)

def viewTests(outputPath=''):
        if not outputPath:
            outputPath = getResourcePath('tests/testResults')
        try:
            #if not empty, use path saved in user settings.
            settingsFile = getUserSettings()
            if settingsFile['TestsOutputPath']:
                outputPath = settingsFile['TestsOutputPath']
        except:
            pass
        
        outputTestFile = os.path.join(outputPath,'datapungi_fed_Tests.html')
        webbrowser.open('file://'+outputTestFile)            
        
        

if __name__ == '__main__':
    from sys import argv    
    import subprocess
    import os 

    runTests()
    #print(os.path.dirname(os.path.realpath(__file__)))
    #query = subprocess.Popen('pytest --html=datapungibea_Tests.html')
    #print(query)