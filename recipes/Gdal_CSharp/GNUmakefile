
include ../../GDALmake.opt
include csharp.opt

all: build

BINDING = csharp
include ../SWIGmake.base

SWIGARGS = -DSWIG2_CSHARP -Wall -I../include -I../include/$(BINDING)

LINK = $(LD_SHARED)
LINK_EXTRAFLAGS =
OBJ_EXT = o
ifeq ($(HAVE_LIBTOOL),yes)
LINK = $(LD)
LINK_EXTRAFLAGS = -rpath $(INST_LIB) -no-undefined -version-info $(LIBGDAL_CURRENT):$(LIBGDAL_REVISION):$(LIBGDAL_AGE)
OBJ_EXT = lo
endif

CONFIG_LIBS = ${LIBGDAL_}

SUPPRESSW = -Wno-missing-prototypes -Wno-missing-declarations -Wno-deprecated-declarations -Wno-unused-parameter -Wno-unused-function

CSHARP_MODULES = libgdal_wrap.$(SO_EXT) libogr_wrap.$(SO_EXT) libgdalconst_wrap.$(SO_EXT) libosr_wrap.$(SO_EXT)
CSHARP_OBJECTS = gdalconst_wrap.$(OBJ_EXT) gdal_wrap.$(OBJ_EXT) osr_wrap.$(OBJ_EXT) ogr_wrap.$(OBJ_EXT)

CSC = mcs

SWIG_GDAL_WRAP = -namespace OSGeo.GDAL -dllimport gdal_wrap -outdir gdal
SWIG_GDALCONST_WRAP = -namespace OSGeo.GDAL -dllimport gdalconst_wrap -outdir const
SWIG_OGR_WRAP = -namespace OSGeo.OGR -dllimport ogr_wrap -outdir ogr
SWIG_OSR_WRAP = -namespace OSGeo.OSR -dllimport osr_wrap -outdir osr

APPS = $(notdir $(patsubst %.cs, %.exe, $(wildcard apps/*.cs)))

clean:
	-rm -f ${CSHARP_MODULES} *.$(OBJ_EXT) *.config *.dll *.mdb *.exe *.config

veryclean: clean
	-rm -f -R const/*.cs gdal/*.cs osr/*.cs ogr/*.cs *.c *.cpp Data

build:	template.csproj	${CSHARP_OBJECTS} samples

template.csproj:
	echo '<Project Sdk="Microsoft.NET.Sdk">' > template.csproj
	echo '<PropertyGroup>' >> template.csproj
	echo '<TargetFramework>netstandard2.0</TargetFramework>' >> template.csproj
	echo '<AssemblyVersion>3.2.1</AssemblyVersion>' >> template.csproj
	echo '<AssemblyOriginatorKeyFile>../gdal.snk</AssemblyOriginatorKeyFile>' >> template.csproj
	echo '<SignAssembly>true</SignAssembly>' >> template.csproj
	echo '<AllowUnsafeBlocks>true</AllowUnsafeBlocks>' >> template.csproj
	echo '<EnableDefaultCompileItems>false</EnableDefaultCompileItems>'  >>  template.csproj
	echo '</PropertyGroup>' >> template.csproj
	echo '<ItemGroup>' >>  template.csproj
	echo '<Compile Include="*.cs" />' >>  template.csproj
	echo '</ItemGroup>' >>  template.csproj
	echo '</Project>' >> template.csproj

sign:
	sn -k gdal.snk

install:
	@echo "No installation to be done"

generate: ${WRAPPERS}

$(CSHARP_MODULES): lib%_wrap.$(SO_EXT): %_wrap.$(OBJ_EXT)
	$(LINK) $(LDFLAGS) $(CONFIG_LIBS) $< -o $@ $(GDAL_SLIB_LINK) $(LINK_EXTRAFLAGS)
	rm -rf $*_csharp.dll.config

%.$(OBJ_EXT): %.cpp
	$(CXX) $(CFLAGS) $(SUPPRESSW) $(GDAL_INCLUDE) -c $<

%.$(OBJ_EXT): %.c
	$(CC) $(CFLAGS) $(SUPPRESSW) $(GDAL_INCLUDE) -c $<

osr_csharp.dll: libosr_wrap.$(SO_EXT)
	$(CSC) /unsafe /debug:full /target:library /out:osr_csharp.dll osr/*.cs AssemblyInfo.cs

ogr_csharp.dll: libogr_wrap.$(SO_EXT) 
	$(CSC) /unsafe /debug:full /target:library /r:osr_csharp.dll /out:ogr_csharp.dll ogr/*.cs AssemblyInfo.cs
	
gdal_csharp.dll: libgdal_wrap.$(SO_EXT) 
	$(CSC) /unsafe /debug:full /target:library /r:osr_csharp.dll /r:ogr_csharp.dll /out:gdal_csharp.dll gdal/*.cs AssemblyInfo.cs

gdalconst_csharp.dll: libgdalconst_wrap.$(SO_EXT)
	$(CSC) /unsafe /debug:full /target:library /out:gdalconst_csharp.dll const/*.cs AssemblyInfo.cs

%.exe:
	$(CSC) /r:gdal_csharp.dll /r:ogr_csharp.dll /r:osr_csharp.dll /r:System.Drawing.dll /out:$@ apps/$(basename $@).cs

%.csproj: %.cs
	echo '<Project Sdk="Microsoft.NET.Sdk">' > $@
	echo '<PropertyGroup>' >> $@
	echo '<OutputType>Exe</OutputType>' >> $@
	echo '<TargetFramework>netcoreapp3.1</TargetFramework>' >>  $@
	echo '<AssemblyVersion>3.2.0</AssemblyVersion>' >>  $@
	echo '<EnableDefaultCompileItems>false</EnableDefaultCompileItems>'  >>  $@
	echo '</PropertyGroup>' >>  $@
	echo '<ItemGroup>' >>  $@
	echo '<Reference Include="../dotnet/gdal_csharp.dll" />'  >>  $@
	echo '<Reference Include="../dotnet/ogr_csharp.dll" />'  >>  $@
	echo '<Reference Include="../dotnet/osr_csharp.dll" />'  >>  $@
	echo '<Compile Include="'$(notdir $<)'" />' >>  $@
	echo '</ItemGroup>' >>  $@
	echo '</Project>' >>  $@
	
samples: gdalconst_csharp.dll osr_csharp.dll ogr_csharp.dll gdal_csharp.dll ${APPS}

vagrant_safe_test:
	LC_ALL=C mono createdata.exe Data pointlayer
	LC_ALL=C mono ogrinfo.exe Data/pointlayer.shp
	LC_ALL=C mono GDALWrite.exe Data/sample.tif
	LC_ALL=C mono GDALDatasetWrite.exe Data/sample1.tif
	LC_ALL=C mono GDALCreateCopy.exe Data/sample.tif Data/sample2.tif
	LC_ALL=C mono GDALOverviews.exe Data/sample.tif NEAREST 2 4
	LC_ALL=C mono GDALInfo.exe Data/sample.tif

test: vagrant_safe_test	
	LC_ALL=C mono OSRTransform.exe

.PHONY: all clean veryclean generate interface build sign install gdal_csharp samples vagrant_safe_test test
