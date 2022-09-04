#pylint: disable-msg=W0311

from .Ligne import Ligne
import os

class Fichier:
   # Constructeur
   def __init__(self,nomFichier="",format="Ligne"):
      if not type(nomFichier) == str: raise NameError('Type incompatible')
      self.lignes=[]
      self.nomFichier = nomFichier
      self.format = format
      if self.nomFichier != "":
         existence = os.path.exists(self.nomFichier)
         if not existence: raise NameError('Fichier inexistant')
   
   # Iterateur "for toto in fic"
   # Si on a deja donne un nom de fichier : Boucle "as is"
   # Routine sous performante !!!!!!!!!!!!!!!!!!
   def __iter__(self):
      if self.nomFichier == "" and self.lignes != []:
         for x in self.lignes:
            yield x
      else:
         if self.format == "texte":
            for curLigne in file(self.nomFichier):
               yield curLigne
         else:
            for curLigne in file(self.nomFichier):
               txt = ""
               if curLigne[0] != "\n":
                  txt = curLigne[0:len(curLigne)-1]
               yield Ligne(txt)
   
   # Obtenir la longeur : len(fic)
   def __len__(self):
      return len(self.lignes)
   
   def __str__(self):
      tab = []
      for x in self.lignes:
         tab.append(str(x))
         tab.append("\n")
      return ''.join(tab)
   
   def __getitem__(self,numero):
      if not type(numero) == int: raise NameError('Type incompatible')
      else:
         if (numero >= len(self.lignes)) or (numero < 0):
            vide=['vide']
            return Ligne(vide)
         else:
            return self.lignes[numero]

   def __setitem__(self,numero,item):
      if not type(numero) == int: raise NameError('Type incompatible')
      if not isinstance(item,Ligne): raise NameError('Type incompatible')
      
      if (numero >= len(self.lignes)) or (numero < 0):
         raise NameError('Depassement de tableau')
      else:
         self.lignes[numero] = item
   
   def __add__(self,b):
      if b == None: return self
      if not isinstance(b,Fichier): raise NameError('Type incompatible')
      tmp = Fichier()
      tmp.lignes = self.lignes+b.lignes
      return tmp
   
   def ajouter(self,numero,item):
      if not type(numero) == int: raise NameError('Type incompatible')
      if not isinstance(item,Ligne):
         if type(item) == str: item = Ligne(item)
         else: raise NameError('Type incompatible')
      
      if numero < 0:
         raise NameError('Depassement de tableau')
      else:
         self.lignes.insert(numero,item)
   
   def modifier(self,numero,item):
      if not type(numero) == int: raise NameError('Type incompatible')
      if not isinstance(item,Ligne):
         if type(item) == str: item = Ligne(item)
         else: raise NameError('Type incompatible')
      
      if numero < 0:
         raise NameError('Depassement de tableau')
      else:
         self.lignes[numero] = item
   
   # On construit un Fichier a partir d'un nom de fichier
   # On fournit aussi ce qui separe les elements d'une meme ligne
   def construireFichier(self,nom,separateur='',ligneVide=True,commentaire=True,
                         caractereCommentaire='#'):
      if not type(nom) == str or not type(separateur) == str:
         raise NameError('Type incompatible')
      
      existence = os.path.exists(nom)
      if not existence: return False
      for curLigne in file(nom):
         if not ligneVide:
            if curLigne[0] == '\n':
               continue
         if not commentaire and curLigne[0] == caractereCommentaire:
            continue
         if separateur == '':
            tmp=Ligne(curLigne[0:len(curLigne)-1])
            self.ajouterLigne(tmp)
            continue
         else:
            ligneTemp = curLigne.split(separateur)
            listeLigne = []
            for elt in ligneTemp:
               # Cas ou il n'y a rien dans l'element
               if elt != '':
                  # Cas du retour chariot
                  if elt[len(elt)-1:len(elt)+1] == '\n':
                     listeLigne.append(elt[0:len(elt)-1])
                  else:
                     listeLigne.append(elt)
            if len(listeLigne) != 0:
               tmp=Ligne(listeLigne)
               self.ajouterLigne(tmp)
      return True
   
   # Ajout d'une Ligne a la fin du fichier
   def ajouterLigne(self,curLigne):
      if not isinstance(curLigne, Ligne):
         if type(curLigne) == str: curLigne = Ligne(curLigne)
         else: raise NameError('Type incompatible')
      self.lignes.append(curLigne)
   
   # Suppression d'une ligne
   def supprimerLigne(self,numero):
      if (numero >= len(self.lignes)) or (numero < 0):
         return False
      else:
         del self.lignes[numero]
         return True
   
   # On recherche toutes les lignes qui correspondent (ou non)
   # au patron et on les recopie dans un nouveau Fichier
   def trouverLignes(self,lignPatron,correspond):
      if not isinstance(lignPatron, Ligne): raise NameError('Type incompatible')
      if not type(correspond) == bool: raise NameError('Type incompatible')
      
      ficRetour=Fichier()
      for curLign in self:
         curComp=(curLign == lignPatron)
         if not correspond:
            curComp = not curComp
         if curComp:
            ficRetour.ajouterLigne(curLign)
      return ficRetour
   
   # Recherche si une ligne est presente
   # Renvoit un booleen et la position de la premiere ligne trouvee
   def lignePresente(self,lignPatron,correspond):
      if not isinstance(lignPatron, Ligne): raise NameError('Type incompatible')
      if not type(correspond) == bool: raise NameError('Type incompatible')
      
      compteur=0
      for curLign in self:
         curComp=(curLign == lignPatron)
         if not correspond:
            curComp = not curComp
         if curComp:
            return [True,compteur]
         compteur=compteur+1
      return [False,-1]
   
   # Trouve toutes les lignes correspondant a lignPatron et 
   # les supprime dans un nouveau Fichier
   def trouverEtSupprimerLignes(self,lignPatron):
      if not isinstance(lignPatron, Ligne): raise NameError('Type incompatible')
      
      compteur=0
      ficRetour = Fichier()
      for curLign in self:
         curComp=(curLign == lignPatron)
         if not curComp:
            ficRetour.ajouterLigne(curLign)
            #self.SupprimerLigne(compteur)
         else:
            compteur=compteur+1
      
      return ficRetour
   
   def afficher(self,nombre):
      print('Taille du fichier :',len(self.lignes))
      
      compteur=0
      for curLigne in self.lignes:
         print(curLigne)
         compteur = compteur + 1
         if compteur > nombre:
            break
   
   def ecrireFichierP(self,nomFichier,debut=-1,fin=-1):
      if (not type(debut) == int) or (not type(fin) == int):
         raise NameError('Type incompatible')
      if not type(nomFichier) == str:
         raise NameError('Type incompatible')
      borneMin=-1
      borneMax=-1
      
      tabTxtOut = []
      for curLign in self:
         textOut=''
         if (debut<1):
            borneMin=0
         else:
            borneMin=debut-1
         
         if (fin<1):
            borneMax=len(curLign)
         else:
            borneMax=min(fin,len(curLign))
         
         space = curLign.getSeparateur()
         nbEspaces = curLign.getNombreEspaces()
         # Rajouter Lignes::__range__
         for num in range(borneMax-borneMin):
            elt = curLign[borneMin+num]
            if nbEspaces-len(elt) <= 0:
               espaces = space
            else:
               espaces = (nbEspaces-len(elt))*space
            if num == borneMax-borneMin-1:
               espaces = ''
            textOut = textOut+elt+espaces
         textOut = textOut+'\n'
         tabTxtOut.append(textOut)
      
      textOut = ''.join(tabTxtOut)
      fichierOut = open(nomFichier,'w')
      fichierOut.write(textOut)
      fichierOut.close()
   
   def ecrireFichier(self,nomFichier):
      if not type(nomFichier) == str:
         raise NameError('Type incompatible')
      
      tabTxtOut = []
      for curLign in self:
         textOut=''
         for elt in curLign:
            textOut = textOut+elt
         textOut = textOut+'\n'
         tabTxtOut.append(textOut)
      
      textOut = ''.join(tabTxtOut)
      fichierOut = open(nomFichier,'w')
      fichierOut.write(textOut)
      fichierOut.close()
