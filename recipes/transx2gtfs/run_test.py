import os
import transx2gtfs

dir_name = os.path.join(os.environ['RECIPE_DIR'], 'test_data')
outfp = os.path.join(dir_name, 'test_gtfs.zip')
transx2gtfs.convert(data_dir=dir_name, output_filepath=outfp)
