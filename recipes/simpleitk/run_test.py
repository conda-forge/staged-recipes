import SimpleITK as sitk

img = sitk.Image(11,12,sitk.sitkUInt8)

# test writing the external third party libraries
sitk.WriteImage(img, "test.jpg")
sitk.WriteImage(img, "test.png")
sitk.WriteImage(img, "test.tiff")


print(sitk.Version())
