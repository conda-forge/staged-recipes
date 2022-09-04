#pylint: disable-msg=W0311

class Ligne:
   def __init__(self,structure,nbspace = 0,sep = ''):
      # On ne prend en entree que de liste
      if not type(structure) == list:
         structure = [structure]
      
      self.espace = nbspace
      self.separateur = sep
      self.contenu = []
      for temp in structure:
         # On ne prend dans la liste que les chaines
         if type(temp) != str: raise NameError('Type incompatible')
         self.contenu.append(temp)
   
   # Definir "print lign"
   def __str__(self):
      ligne = ''
      for temp in self.contenu:
         ligne=ligne+temp
      ligne=ligne+''
      return ligne
   
   def __iter__(self):
      for x in self.contenu:
         yield x
   
   # Test le '=='
   # Si une des chaines est egale a '*' : on ne fait pas de comparaison
   def __cmp__(self, b):
      # Les deux doivent etre des lignes
      if not isinstance(self, Ligne) or not isinstance(b, Ligne):
         raise NameError('Type incompatible')
      
      # Elles doivent etre de meme taille
      # Mais c'est peut etre un peu violent de planter pour ca...
      if len(self) != len(b):
         raise NameError('Taille non concordante')
      
      tailleMax=0
      for num in range(0,len(self)):
         # On prend en compte le cas '*'
         aCmp=self[num]
         tACmp=len(aCmp)
         bCmp=b[num]
         tBCmp=len(bCmp)
         
         if (aCmp=='*') or (bCmp=='*'):
            continue
         
         # Si on a une '*' a la fin d'une des chaines, on coupe
         if aCmp[tACmp-1:tACmp] == '*':
            aCmp=aCmp[0:tACmp-1]
            bCmp=bCmp[0:tACmp-1]
         if bCmp[tBCmp-1:tBCmp] == '*':
            bCmp=bCmp[0:tBCmp-1]
            aCmp=aCmp[0:tBCmp-1]
         
         if aCmp > bCmp: return 1
         if aCmp < bCmp: return -1
      return 0
   
   def __add__(self,b):
      if not b.__class__ == Ligne: raise NameError('Type incompatible')
      ajout=[]
      for cont in self:
         ajout.append(cont)
      for cont in b:
         ajout.append(cont)
      return Ligne(ajout)
   
   # __getitem__ prend en entree un entier
   def __getitem__(self,numero):
      if not type(numero) == int: raise NameError('Type incompatible')
      else:
         if (numero >= len(self.contenu)) or (numero < 0):
            raise NameError('Depassement de tableau')
         else:
            return self.contenu[numero]

   def __setitem__(self,numero,item):
      if not type(numero) == int: raise NameError('Type incompatible')
      if not type(item) == str: raise NameError('Type incompatible')
      
      if (numero >= len(self.contenu)) or (numero < 0):
         raise NameError('Depassement de tableau')
      else:
         self.contenu[numero] = item
   
   def __len__(self):
      return len(self.contenu)
   
   def getNombreEspaces(self):
      return self.espace
   
   def setNombreEspaces(self,nombre):
      if not type(nombre) == int: raise NameError('Type incompatible')
      self.espace = nombre

   def getSeparateur(self):
      return self.separateur

   def setSeparateur(self,sep):
      if not type(sep) == str: raise NameError('Type incompatible')
      self.separateur = sep
   
   def afficher(self):
      ligne = ''
      for temp in self.contenu:
         ligne=ligne+temp+' '
      print(ligne)
   
   def ajouter(self,numero,texte):
      if not type(texte) == str: raise NameError('Type incompatible')
      if not type(numero) == int: raise NameError('Type incompatible')
      
      self.contenu.insert(numero,texte)
   
   def modifierContenu(self,contenu):
      if not type(contenu) == list:
         contenu = [contenu]
      
      self.contenu = []
      for temp in contenu:
         # On ne prend dans la liste que les chaines
         if type(temp) != str: raise NameError('Type incompatible')
         self.contenu.append(temp)
