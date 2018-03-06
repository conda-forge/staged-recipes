if [ "$ARCH" == "64" ]; then  
	SET GENERATOR=Visual Studio 14 2015 Win64
else
	SET GENERATOR=Visual Studio 14 2015 Win32
fi

%PYTHON% setup.py clean
%PYTHON% setup.py install
