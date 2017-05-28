cd
dir
dir %PREFIX%
dir %PREFIX%\opt

mkdir %PREFIX%\opt\oommf
xcopy * %PREFIX%\opt\oommf /e
#move * %PREFIX%\opt\oommf
