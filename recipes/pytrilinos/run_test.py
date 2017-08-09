import os
os.environ["OMPI_MCA_pml"]="isolated"

import PyTrilinos.Teuchos
import PyTrilinos.Epetra
import PyTrilinos.TriUtils
import PyTrilinos.Tpetra
import PyTrilinos.EpetraExt
import PyTrilinos.Domi
import PyTrilinos.AztecOO
import PyTrilinos.Galeri
import PyTrilinos.Amesos
import PyTrilinos.IFPACK
import PyTrilinos.Komplex
import PyTrilinos.ML
import PyTrilinos.Anasazi

