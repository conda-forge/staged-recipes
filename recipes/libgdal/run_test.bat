cd %RECIPE_DIR%\test_data

:: From @mhearne-usgs. See https://github.com/conda-forge/gdal-feedstock/issues/23#issue-144997326
set proj4="+y_0=2400761.714982585 +lat_ts=-19.6097 +a=6378137.0 +proj=merc +units=m +b=6356752.3142 +lat_0=-19.6097 +x_0=-0.0 +lon_0=-70.7691"
gdalwarp -s_srs "+proj=latlong" -t_srs "%PROJ4%" -of EHdr grid.asc grid.flt

:: Test ISIS3/USGS driver `SetNoDataValue()` issue.
gdalinfo cropped.cub

:: From @akorosov. See https://github.com/conda-forge/gdal-feedstock/issues/83
gdalinfo /vsizip/stere.zip/stere.tif

:: Check shapefile read.
ogrinfo sites.shp
