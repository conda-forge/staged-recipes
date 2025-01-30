using System;
using System.Runtime.InteropServices;

public class DynamicLibraryLoader
{
    private IntPtr _libraryHandle;
    private readonly string _libraryPath;

    public DynamicLibraryLoader(string libraryPath)
    {
        _libraryPath = libraryPath;
#if PLATFORM_WINDOWS
        _libraryHandle = LoadLibrary(libraryPath);
#elif PLATFORM_LINUX || PLATFORM_OSX
        _libraryHandle = dlopen(libraryPath, RTLD_NOW);
#endif

        if (_libraryHandle == IntPtr.Zero)
        {
            throw new Exception("Failed to load library: " + libraryPath);
        }
    }

    public void LoadLibrary(string libraryName)
    {
        var fullPath = System.IO.Path.Combine(_libraryPath, libraryName);
#if PLATFORM_WINDOWS
        _libraryHandle = LoadLibrary(fullPath);
#elif PLATFORM_LINUX || PLATFORM_OSX
        _libraryHandle = dlopen(fullPath, RTLD_NOW);
#endif

        if (_libraryHandle == IntPtr.Zero)
        {
            throw new Exception("Failed to load library: " + fullPath);
        }
    }

    public T GetFunctionDelegate<T>(string functionName) where T : Delegate
    {
        IntPtr functionAddress = IntPtr.Zero;

#if PLATFORM_WINDOWS
        functionAddress = GetProcAddress(_libraryHandle, functionName);
#elif PLATFORM_LINUX || PLATFORM_OSX
        functionAddress = dlsym(_libraryHandle, functionName);
#endif

        if (functionAddress == IntPtr.Zero)
        {
            throw new Exception("Failed to get function address: " + functionName);
        }

        return Marshal.GetDelegateForFunctionPointer<T>(functionAddress);
    }

    ~DynamicLibraryLoader()
    {
        if (_libraryHandle != IntPtr.Zero)
        {
#if PLATFORM_WINDOWS
            FreeLibrary(_libraryHandle);
#elif PLATFORM_LINUX || PLATFORM_OSX
            dlclose(_libraryHandle);
#endif
        }
    }

#if PLATFORM_WINDOWS
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr LoadLibrary(string dllToLoad);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetProcAddress(IntPtr hModule, string procedureName);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool FreeLibrary(IntPtr hModule);
#elif PLATFORM_LINUX || PLATFORM_OSX
    [DllImport("libdl.so")]
    private static extern IntPtr dlopen(string fileName, int flags);

    [DllImport("libdl.so")]
    private static extern IntPtr dlsym(IntPtr handle, string symbol);

    [DllImport("libdl.so")]
    private static extern int dlclose(IntPtr handle);

    private const int RTLD_NOW = 2;
#endif
}