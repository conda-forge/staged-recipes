#pylint: disable-msg=W0311

from .Fichier import *
import os
import sys

arg_in = sys.argv

def al_aide():
   print("Usage:",arg_in[0]," --fichier=FICHIER")
   raise NameError("Argument d'entree incorrect")

debutInteract = "######################################################################"
ligneCommande = "    #  ---------------------------"
titreCommande = "    #  COMMANDE NO :"
finCommande = "    #  FIN COMMANDE NO :"

sepErrResuBatch = "++++++++++++++++++++"
fichErrBatch = " Fichier:  ERREUR"
fichResuBatch = " Fichier:  RESULTAT"

sepErrResuInteract = "--------------------------------------------------------------------------------"
fichErrInteract = " Content of ERROR file"
fichResuInteract = " Content of RESU file"
finErrorInteract = "------------------------------------------------------------"

finResu = " * TOTAL_JOB                :"

enteteHTML = """<html>
<head>
<meta http-equiv="Content-Language" content="en-us">

   <style type="text/css">
      a.alarme:link, a.alarme:visited {
         //color: black;
         //text-decoration: none;
      }
      .alarme {
         //background-color: #ffeccb;
         //color: black;
      }
      #navigation { 
         margin: 0 ; 
         padding: 0 ; 
         list-style: none ; 
         text-align: center ; 
      }
      #navigation li { 
         display: inline ; 
         margin-right: 1px ; 
         color: #fff ; 
         background: #c00 ; 
      }
      #navigation li a { 
         padding: 4px 20px ; 
         background: #c00 ; 
         color: #fff ; 
         border: 1px solid #600 ; 
         font: 1em "Trebuchet MS",Arial,sans-serif ; 
         line-height: 1em ; 
         text-align: center ; 
         text-decoration: none ; 
      }
      #navigation li a:hover, #navigation li a:focus, #navigation li a:active { 
         background: #900 ; 
         text-decoration: underline ; 
      }
   </style>

<title>%(title)s</title>

<script>
function toggleFollowingText(id)
{
   document.getElementById(id).style.display == '' ? document.getElementById(id).style.display = 'none' : document.getElementById(id).style.display = '';
}

function toggleFollowingTextBool(id,test)
{
   if (test == true)
   {
      document.getElementById(id).style.display = 'none'
   }
   else
   {
      document.getElementById(id).style.display = ''
   }
}

function toggleLines(id)
{
   test = toggleLines.arguments[0];
   
   for(var i = 1; i < toggleLines.arguments.length; i++)
   {
      oDisplay = document.getElementById(toggleLines.arguments[i]);
      if(oDisplay)
      {
         toggleFollowingTextBool(toggleLines.arguments[i],test);
      }
   }
}

function goToExpand(id1,id2)
{
   for(var i = 1; i < goToExpand.arguments.length; i++)
   {
      //oDisplay = document.getElementById(goToExpand.arguments[i]);
      toggleFollowingTextBool(goToExpand.arguments[i],false);
   }
   document.location.href = id1;
   //changerPliageBool(id2+'Txt',false);
}

function compstr(a, b, sens){
   if (sens) return a<b;
   else return a>b;
}

//function toggleList(id)
//{
//   arg1 = toggleList.arguments[0];
//   var tab=document.getElementById(arg1);
//   arg2 = true
//   if(tab.innerHTML == 'Replier tout')
//   {
//      arg2 = true;
//      tab.innerHTML = 'D&eacute;plier tout';
//   }
//   else
//   {
//      arg2 = false;
//      tab.innerHTML = 'Replier tout';
//   }
//   
//   for(var i = 1; i < toggleList.arguments.length; i++)
//   {
//      oDisplay = document.getElementById(toggleList.arguments[i]);
//      if(oDisplay)
//      {
//         toggleFollowingTextBool(toggleList.arguments[i],arg2);
//         tmp = toggleList.arguments[i] + 'Txt';
//         changerPliageBool(tmp,arg2);
//      }
//   }
//}

function toggleList2(id)
{
   arg1 = toggleList2.arguments[0];
   var tab = document.getElementById(arg1);
   arg2 = true
   if(tab.innerHTML == 'Replier tout')
   {
      arg2 = true;
      tab.innerHTML = 'D&eacute;plier tout';
   }
   else
   {
      arg2 = false;
      tab.innerHTML = 'Replier tout';
   }
   
   for(var i = 1; i < toggleList2.arguments.length; i++)
   {
      oDisplay = document.getElementById(toggleList2.arguments[i]);
      if(oDisplay)
      {
         toggleFollowingTextBool(toggleList2.arguments[i],arg2);
      }
   }
}

//function toggleOneCell(id1,id2)
//{
//   toggleFollowingText(id2);
//   changerPliage(id1);
//}

function triInsertion(id, arrayindex, sens)
{
   var tab=document.getElementById(id);
   var a=tab.childNodes[1];
   var i=0, j, k, l, m;
   var x = new Array();
   //var x;
   k=0;
   l=a.childNodes.length;
   for (j=1; j<l; j++)
   {
      for (k=0; k<a.childNodes[j].cells.length; k++)
      {
         x[k] = a.childNodes[j].cells[k].innerHTML;
      }
      i = j-1;
      // x doit etre insere dans le tableau ordonne 0..j-1
      while (i>=1 && compstr(a.childNodes[i].cells[arrayindex].innerHTML,x[arrayindex],sens))
      {
         for (k=0; k<a.childNodes[i+1].cells.length; k++)
         {
            a.childNodes[i+1].cells[k].innerHTML = a.childNodes[i].cells[k].innerHTML;
         }
         i = i-1;
      }
      for (k=0; k<a.childNodes[i+1].cells.length; k++)
      {
         a.childNodes[i+1].cells[k].innerHTML = x[k];
      }
   }
}

//function changerPliageBool(id, sens)
//{
//   var tab=document.getElementById(id);
//   if ( sens ) tab.innerHTML = "D&eacute;plier";
//   else tab.innerHTML = "Replier";
//}

//function changerPliage(id)
//{
//   var tab=document.getElementById(id);
//   if ( tab.innerHTML == 'Replier' ) tab.innerHTML = "D&eacute;plier";
//   else tab.innerHTML = "Replier";
//}
</script>

</head>
<body>
<h1 align="center">
<a name="navig"></a>
Fichier de sortie de <i>Code_Aster</i>
</h1>
<ul name="navig" id="navigation"> 
    <li><a href="JavaScript://" onClick="goToExpand('#contexte','cont')" title="aller au contexte">Contexte d'execution</a></li>
    <li><a href="JavaScript://" onClick="goToExpand('#concepts','conc')" title="aller au .resu">Concepts produits</a></li>
    <li><a href="JavaScript://" onClick="goToExpand('#sommaire','mess')" title="aller au .mess">Fichier message</a></li>
    <li><a href="JavaScript://" onClick="goToExpand('#resultat','resu')" title="aller au .resu">Fichier r&eacute;sultat</a></li>
    <li><a href="JavaScript://" onClick="goToExpand('#erreur','erre')" title="aller au .erre">Fichier erreur</a></li>
</ul>
<br>
<h3 align="center">
<center>
<a href="JavaScript://" onClick="toggleLines(false,'cont','conc','mess','resu','erre')">D&eacute;plier tout</a>
<a href="JavaScript://" onClick="toggleLines(true,'cont','conc','mess','resu','erre')">Replier tout</a>
</h3>
<br>"""

script = """

<script language="JavaScript" type="text/javascript">
  <!--
   toggleFollowingText('cont')
   toggleFollowingText('conc')
   toggleFollowingText('mess')
   toggleFollowingText('resu')
   toggleFollowingText('erre')
%(toggles)s
  //-->
</script>"""

piedHTML = """</body>
</html>"""

class Commande:
   def __init__(self,nom,concept,numero):
      self.__nom = nom
      self.__concepts = concept
      self.__fichier = None
      self.__numero = numero
      self.__commmandeUtilisateur = ""
      self
   
   def __str__(self):
      txt = "Commande : "+self.__nom
      if self.__concepts != "":
         txt = txt+" - concept produit : "+self.__concepts
      return txt
   
   def concept(self):
      return self.__concepts
   
   def nom(self):
      return self.__nom
   
   def numero(self):
      return self.__numero
      
   def definirFichier(self,fichier):
      if not isinstance(fichier,Fichier): raise NameError('Type incompatible')
      self.__fichier = fichier
   
   def fichier(self):
      if self.__fichier == None: raise NameError('self.__fichier pas encore cree')
      return self.__fichier

def remplacerChar(chaine,charI,charM):
   tab = chaine.split(charI)
   if len(tab) > 0:
      chaine = tab[0]
      for i in range(len(tab)-1):
         chaine = chaine+charM+tab[i+1]
   return chaine

#XXX from xml.sax import saxutils ==> saxutils.escape
def modifierChaineToHTML(chaine):
   chaine = remplacerChar(chaine,"&","&amp;")
   chaine = remplacerChar(chaine,"<","&lt;")
   chaine = remplacerChar(chaine,">","&gt;")
   chaine = remplacerChar(chaine,"\"","&quot;")
   return chaine

class Output:
   def __init__(self,path):
      if type(path) != str: raise NameError('Type incompatible')
   
      self.__path = path
      self.__fichier = Fichier(self.__path)
      #self.__fichier.construireFichier(nom=self.__path,ligneVide=True,commentaire=True)
      
      self.__commandes = []
      self.__concepts = {}
      self.__enTete = None
      self.__finExec = None
      self.__erreur = None
      self.__resu = None
      
      self.__analyserFichier()
      
   def __analyserFichier(self):
      numeroLigne = 0
      debutCommande = -50
      derniereCommande = 0
      commandeFinTrouvee = False
      fichierErrResu = 0
      txtPrec = ""
      fic = Fichier()
      compteur = 0
      interactif = False
      for ligne in self.__fichier:
         strLigne = modifierChaineToHTML(str(ligne))
         if compteur == 0:
            if strLigne == debutInteract:
               sepErrResu = sepErrResuInteract
               fichErr = fichErrInteract
               fichResu = fichResuInteract
               interactif = True
            else:
               sepErrResu = sepErrResuBatch
               fichErr = fichErrBatch
               fichResu = fichResuBatch
            compteur = 1
         if commandeFinTrouvee:
            if interactif:
               if strLigne == fichErr or strLigne == fichResu or strLigne == finErrorInteract:
                  if fichierErrResu == 0:
                     self.__finExec = fic
                     fichierErrResu = 1
                     fic = Fichier()
                  elif fichierErrResu == 1:
                     self.__resu = fic
                     fic = Fichier()
                     fichierErrResu = 2
                  elif fichierErrResu == 2:
                     self.__erreur = fic
                     #fic = Fichier()
            else:
               if strLigne == sepErrResu or strLigne[0:29] == finResu:
                  if fichierErrResu == 0:
                     self.__finExec = fic
                     fichierErrResu = 1
                     fic = Fichier()
                  elif fichierErrResu == 1:
                     fichierErrResu = 2
                  elif fichierErrResu == 2:
                     if txtPrec == "erreur":
                        self.__erreur = fic
                        fic = Fichier()
                     elif txtPrec == "resu":
                        self.__resu = fic
                     fichierErrResu = 1
               elif strLigne == fichErr:
                  txtPrec = "erreur"
               elif strLigne == fichResu:
                  txtPrec = "resu"
         else:
            # Sauvegarde du txt precedent
            if numeroLigne == debutCommande+1:
               txtPrec = strLigne[0:20]
            
            # Si on est au debut d'une commande : creation de l'objet
            if numeroLigne == debutCommande+3 and txtPrec == titreCommande:
               txtLigne = strLigne.lstrip()
               tab1 = txtLigne.split("(")
               tab2 = tab1[0].split("=")
               co = ""
               com = ""
               if len(tab2) > 1:
                  co = tab2[0]
                  if co in self.__concepts:
                     tab = self.__concepts[co]
                     if len(tab) == 1: tab.append(derniereCommande)
                     else: tab[1] = derniereCommande
                  else:
                     self.__concepts[co] = [derniereCommande]
                  com = tab2[1]
               elif len(tab2) == 1: com = tab2[0]
               else: raise NameError('Probleme de taille')
               
               self.__commandes.append(Commande(com,co,derniereCommande))
               derniereCommande = derniereCommande + 1
            
            # Recherche des lignes de separations
            if strLigne[0:34] == ligneCommande:
               if txtPrec == finCommande:
                  fic.ajouterLigne(strLigne)
                  self.__commandes[derniereCommande-1].definirFichier(fic)
                  txt = self.__commandes[derniereCommande-1].nom()
                  if txt == "FIN":
                     commandeFinTrouvee = True
                  txtPrec = ""
               else:
                  if len(self.__commandes) == 0:
                     self.__enTete = fic
                  debutCommande = numeroLigne
               fic = Fichier()
            
            # Recherche chaine de fin de commande
            if strLigne[0:24] == finCommande:
               txtPrec = strLigne[0:24]
            numeroLigne = numeroLigne + 1
         fic.ajouterLigne(strLigne)
      
   
   def sortieHTML(self,nomFichier):
      if not type(nomFichier) == str: raise NameError('Type incompatible')
      
      # Creation du fichier qui sera utilise pour la sortie
      fichierSortie = Fichier()
      fichierSortie.ajouterLigne(enteteHTML % {
        'title' : os.path.basename(nomFichier),
      })
      # Creation du tableau general contenant l'ensemble des differents fichiers
      fichierSortie.ajouterLigne("<table border=\"0\" align=\"left\" width=\"100%\">")
      
      # Format du titre des rubrique
      #topRubrique = "<tr><td><h3><a name=\"%(nomRubrique)s\" href=\"#navig\">%(txt)s</a> <a id=\"%(idCellule)sTxt\" href=\"JavaScript://\" onclick=\"toggleOneCell('%(idCellule)sTxt','%(idCellule)s')\">D&eacute;plier</a></h3></td></tr>"
      topRubrique = "<tr><td><h3><a name=\"%(nomRubrique)s\" href=\"JavaScript://\" onclick=\"toggleFollowingText('%(idCellule)s')\">%(txt)s</a></h3></td></tr>"
      
      # Fichier contexte
      fichierContexte = Fichier()
      # Saut de ligne...
      fichierContexte.ajouterLigne("<tr><td></td></tr>")
      curRubrique = {"nomRubrique":"contexte","idCellule":"cont","txt":"Contexte d'execution"}
      fichierContexte.ajouterLigne(topRubrique%curRubrique)
      fichierContexte.ajouterLigne("<tr id=\"cont\">\n<td>\n<pre>")
      fichierContexte = fichierContexte+self.__enTete
      fichierContexte.ajouterLigne("</pre>\n</td></tr>")
      # Fin fichier contexte
      
      # Fichier mess
      fichierMess = None
      if self.__commandes != None:
         fichierMess = Fichier()
         curRubrique = {"nomRubrique":"sommaire","idCellule":"mess","txt":"Fichier Message"}
         fichierMess.ajouterLigne(topRubrique%curRubrique)
         fichierMess.ajouterLigne("<tr id=\"mess\">\n<td>\n<pre>")
         # Creation du tableau contenant les differents fonctions aster
         fichierMess.ajouterLigne("<table border=\"0\">")
         
         # Reduire une commande
         lienToggle = "<a name=\"comm%(num)s\" href=\"JavaScript://\" onclick=\"toggleFollowingText('sub%(num)s')\">"
         # Commande a ajouter en fin de fichier pour tout reduire a l'ouverture
         curToggle = "   toggleFollowingText('sub%(num)s')\n"
         # Lien pour plier toutes les commandes du mess
         toggleT = "<a id=\"pliageMess\" href=\"JavaScript://\" onClick=\"toggleList2('pliageMess'%(noms)s)\">D&eacute;plier tout</a>"
         toggles = ""
         
         curConcepts = {}
         typeConcepts = {}
         txtSub = ""
         
         for comm in self.__commandes:
            numeroComm = comm.numero()
            nomComm = comm.nom()
            txtSub = txtSub+", 'sub"+str(numeroComm)+"'"
            
            # Debut et fin de la ligne du tableau
            deb = "<tr><td>"
            fin = "</td></tr>\n"
            lien = lienToggle%{"num":str(numeroComm)}
            mess = deb+lien+nomComm+"</a>"
            concept = comm.concept()
            # Pour les liens de concept si on est dans la premiere commande qui cree le concept
            # on cree un lien vers le tableau de concept, sinon, lien vers la precedente
            # commande qui cree ce concept
            if concept != "":
               tab = self.__concepts[concept]
               lienConcept = ""
               if tab[0] != numeroComm:
                  commandeToGo = "'#comm"+str(curConcepts[concept])+"'"
                  commandeToExpand = "'sub"+str(curConcepts[concept])+"'"
                  href = "href=\"JavaScript://\" onClick=\"goToExpand("+commandeToGo+",'mess',"+commandeToExpand+")\""
                  lienConcept = "<a "+href+">"+concept+"</a>"
               else:
                  href = "href=\"JavaScript://\" onClick=\"goToExpand('#"+concept+"','conc')\""
                  lienConcept = "<a "+href+">"+concept+"</a>"
                  curConcepts[concept] = numeroComm
               mess = mess+" - Concept produit : "+lienConcept
            mess = mess+fin+"<tr id=\"sub"+str(numeroComm)+"\">\n<td>\n<pre>\n"
            fichierMess.ajouterLigne(mess)
            
            fichierComm = comm.fichier()
            finCommTrouvee = False
            nouveauFichier = Fichier()
            # Boucle sur le fichier de la commande pour ajouter les liens sur les concepts
            for ligne in fichierComm:
               ligne2 = ligne
               if not finCommTrouvee:
                  strLigne = str(ligne)
                  strLigneLStrip = strLigne.lstrip()
                  if strLigneLStrip == ");": finCommTrouvee = True
                  tabDecoup = strLigne.split("=")
                  if len(tabDecoup) > 0:
                     # On enleve la virgule et la parenthese eventuelle
                     concept = tabDecoup[len(tabDecoup)-1]
                     concept = concept.split(")")[0].split(",")[0]
                     concept = concept.lstrip()
                     if concept in self.__concepts:
                        if concept in curConcepts:
                           num = curConcepts[concept]
                           if curConcepts[concept] == numeroComm:
                              lienConcept = concept
                           else:
                              commandeToGo = "'#comm"+str(curConcepts[concept])+"'"
                              commandeToExpand = "'sub"+str(curConcepts[concept])+"'"
                              href = "href=\"JavaScript://\" onClick=\"goToExpand("+commandeToGo+",'mess',"+commandeToExpand+")\""
                              lienConcept = "<a "+href+">"+concept+"</a>"
                           curConcepts[concept] = numeroComm
                           tab = strLigne.split(concept)
                           txt = ""
                           for i in range(len(tab)-1):
                              if i == len(tab)-2: txt = txt+tab[i]+lienConcept+tab[i+1]
                              else:txt = txt+tab[i]+concept
                           ligne2 = Ligne(txt)
                        else:
                           curConcepts[concept] = numeroComm
               nouveauFichier.ajouterLigne(ligne2)
            fichierMess = fichierMess+nouveauFichier
            fichierMess.ajouterLigne("</pre>\n</td>\n</tr>\n")
            
            toggles = toggles+curToggle%{"num":str(numeroComm)}
            
            # Si on est dans la commande FIN, on recupere les types des concepts
            if nomComm == "FIN":
               conceptsTrouves = False
               for ligne in comm.fichier():
                  strLigne = str(ligne)
                  if conceptsTrouves:
                     nomCo = strLigne[4:15].rstrip()
                     typeCo = strLigne[15:40]
                     if nomCo in self.__concepts:
                        typeConcepts[nomCo] = typeCo.split("_SDASTER")[0].rstrip()
                  if strLigne[0:24] == " -----------------------" and conceptsTrouves:
                     break
                  if strLigne[0:24] == " Concepts de la base: G":
                     conceptsTrouves = True
         
         txtSub = toggleT%{"noms":txtSub}
         fichierMess.lignes.insert(2,Ligne(txtSub))
         fichierMess.ajouterLigne("</table>")
      
      # Fichier Concept
      fichierConcept = None
      if self.__concepts != None:
         fichierConcept = Fichier()
         curRubrique = {"nomRubrique":"concepts","idCellule":"conc","txt":"Concepts produits"}
         fichierConcept.ajouterLigne(topRubrique%curRubrique)
         fichierConcept.ajouterLigne("<tr id=\"conc\">\n<td>\n")
         fichierConcept.ajouterLigne("<table class=\"tableau\" id=\"tableau\" border=\"1\">\n<tbody><tr>")
         ligneTmp = "<th>Nom du concept <a onclick=\"triInsertion('tableau', 0, false)\">&darr;</a><a onclick=\"triInsertion('tableau', 0, true)\">&uarr;</a></th>"
         ligneTmp2 = "<th>Type du concept <a onclick=\"triInsertion('tableau', 1, false)\">&darr;</a><a onclick=\"triInsertion('tableau', 1, true)\">&uarr;</a></th>"
         fichierConcept.ajouterLigne(ligneTmp+"\n"+ligneTmp2)
         txt = "</tr>"
         for concept in self.__concepts:
            txt = txt+"<tr>\n"
            commandeToGo = "'#comm"+str(curConcepts[concept])+"'"
            commandeToExpand = "'sub"+str(curConcepts[concept])+"'"
            href = "href=\"JavaScript://\" onClick=\"goToExpand("+commandeToGo+",'mess',"+commandeToExpand+")\""
            txt = txt+"<td><a name=\""+concept+"\" "+href+">"+concept+"</a></td>"
            typeCo = ""
            if concept in typeConcepts:
               typeCo = typeConcepts[concept]
            txt = txt+"<td>"+typeCo+"</td>\n</tr>"
         fichierConcept.ajouterLigne(txt)
         fichierConcept.ajouterLigne("</tbody>\n</table>")
         fichierConcept.ajouterLigne("</tr>\n</td>\n")
      
      # Concatenation des differents fichiers
      fichierSortie = fichierSortie+fichierContexte+fichierConcept+fichierMess
      
      if self.__resu != None:
         fichierSortie.ajouterLigne("<tr><td></td></tr>")
         curRubrique = {"nomRubrique":"resultat","idCellule":"resu","txt":"Fichier R&eacute;sultat"}
         fichierSortie.ajouterLigne(topRubrique%curRubrique)
         fichierSortie.ajouterLigne("<tr id=\"resu\">\n<td>\n<pre>")
         #print self.__resu
         fichierSortie = fichierSortie+self.__resu
         fichierSortie.ajouterLigne("</pre>\n</td></tr>")
      
      if self.__erreur != None:
         fichierSortie.ajouterLigne("<tr><td></td></tr>")
         curRubrique = {"nomRubrique":"erreur","idCellule":"erre","txt":"Fichier Erreur"}
         fichierSortie.ajouterLigne(topRubrique%curRubrique)
         fichierSortie.ajouterLigne("<tr id=\"erre\">\n<td>\n<pre>")
         fichierSortie = fichierSortie+self.__erreur
         fichierSortie.ajouterLigne("</pre>\n</td></tr>")
      
      scriptAjout = script%{"toggles":toggles}
      fichierSortie.ajouterLigne("\n</table>"+scriptAjout)
      fichierSortie.ajouterLigne(piedHTML)
      
      # Ecriture du fichier
      fichierSortie.ecrireFichier(nomFichier)


if __name__ == "__main__":
    nomFichier = ""
    pathOutHTML = ""

    if len(arg_in) == 2:
       for i in range(1,len(arg_in)):
          arg = arg_in[i]
          if arg[0:10] == "--fichier=":
             nomFichier = arg[10:len(arg)]
          else:
             al_aide()
       if nomFichier == "": al_aide()
       
    else: al_aide()

    out = Output(nomFichier)

    out.sortieHTML(nomFichier+".html")
