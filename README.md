# Introducció

Aquesta aplicació ha estat creada pel Projecte Òrbita per tal de facilitar a famílies i escoles l'accés a 
la informació  relacionada amb l'efecte de la COVID-19 als centres educatius de Catalunya. Tota la informació 
utilitzada és pública i està referenciada en el següent apartat del document. Tots els càlculs i models utilitzats
també estan explicats més avall. 

# Dades

Les dades provenen de les fonts següents:

- Casos COVID-19: https://analisi.transparenciacatalunya.cat/ (document jj6z-iyrp).
- Demografia: https://www.idescat.cat/pub/?id=aec&n=925 (compte que els codis de municipi tenen una xifra més que els de casos COVID; és la última, que es pot treure i aleshores coincideixen).
- Dades escoles globals: https://www.idescat.cat/pub/?id=aec&n=734.
- Dades escoles individuals: http://ensenyament.gencat.cat/ca/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/ (primer fitxer).
- Mapes: https://www.icgc.cat/Administracio-i-empresa/Descarregues/Capes-de-geoinformacio/Base-municipal.</ul>

# Càlculs

## Variables epidemiològiques

Totes les dades epidemiològiques han estat calculades seguint les metodologies del grup biocomsc de la UPC, que podeu trobar aquí: https://biocomsc.upc.edu/en/shared/avaluacio_risc.pdf.

# Probabilitats

 Pel que fa als càlculs de probabilitats de casos, s'han utilitzat models de Poisson amb lambda igual a la prevalença de la malaltia a 14 dies.

**Nota: seguint aquest article (https://www.nature.com/articles/s41591-020-0962-9) s'ha tingut en compte que els infants i adolescents tenen una incidència de la malaltia d'aproximadament el 40% que els adults. Aquest valor segurament vagi actualitzant-se a mesura que surten més investigacions.**

Els valors de la guia de Harvard els podeu trobar aquí: https://globalepidemics.org/wp-content/uploads/2020/07/pandemic_resilient_schools_briefing_72020.pdf.

La resta de càlculs són bastant directes; si els voleu repassar, són als fitxers calcs.R i calc_funcs.R.


# Exempció de responsabilitat
 
No cal dir (però ho diem igualment, que ens coneixem) que això només són models simples i que aspiren a 
ajudar a les persones a estar informades i a prendre decisions sobre l'escolarització en aquestes circumstànies 
tan complicades. Evidentment, molts altres factors s'han de tenir en compte a l'hora de prendre decisions.

Insitim, de totes maneres, que estem completament oberts a correccions i suggerències.

# Agraïments

Aquest treball està inspirat en els de @_AlexArenas, @BIOCOMSC1, @JCerquidesW i @gmnzgerard. Gràcies a tots!
