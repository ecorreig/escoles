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

## Risc de rebrot

El risc de rebrot, també anomenat índex de creixement potencial (EPG per les seves sigles en anglès) és calcula com la multiplicació de la rho7 i l'incidència acumulada a 14 dies (per 100.000 habitants). Utilitzem aquest índex com a principal ja que s'ha establert com el de referència en les comunicacions oficials i dels mitjans de comunicació de Catalunya.

## Incidència acumulada a 14 dies

Aquest valor és simplement la suma de tots els casos positius confirmats per PCR dels últims 14 dies dividits per cada 100.000 habitants.

## Rho 7

La rho_0, en models epidemiològics, és la taxa base de creixement. En el nostre cas aquest número no té massa sentit teòric, perquè les restriccions modifiquen molt la rho0 (és la seva feina) i per tant, a nivell teòric, no té sentit. És per això que des de la UPC han creat la rho experimenta, que calculen com a la suma de casos dels tres últims dies dividit per la suma de casos d'entre 5 i 8 dies anteriors al que es calcula. La rho_7 és aleshores la mitjana de la rho calculada d'aquesta manera dels últims 7 dies.

## Guia de Harvard

La guia de Harvard, que podeu trobar aquí:  https://globalepidemics.org/wp-content/uploads/2020/07/pandemic_resilient_schools_briefing_72020.pdf, dóna referències per tal de decidir si obrir les comunitats (en particular centres educatius) segons l'estat de la pandèmia i, en concret, segons el número de casos confirmats diaris per cada 100.000 habitants. El resum de la guia seria:

- Verd: tots els centres educatius han d'obrir sempre que es compleixin els protocols de seguretat.
- Groc: Guarderies obertes i centres d'educació espeicial fins a 8 anys oberts. Primària fins a 8 anys i educació especial fins a 12 anys s'han d'obrir només si els protocols de seguretat es poden complir estríctament en tots els centres del territori afectat.
- Taronja: igual que l'anterior, però només si tots els centres del territori poden complir els protocols de forma totalment estricta.
- Vermell: tots els centres educatius del territori han d'estar tancats.

# Probabilitats

Pel que fa als càlculs de probabilitats de casos, s'han utilitzat models Binomials tenint en compte la prevalença de la malaltia a 14 dies.

El que anomenem 'Prob. cas classe' és la probabilitat de que hi hagi un cas cada 25 alumnes, per tant, un cas <strong>en cada classe</strong>. 'Prob. cas escola' és la probabilitat de que hi hagi un cas cada N alumnes, on N és la mida de l'escola que depèn del número de cursos i de línies d'aprenentatge de que disposen. Tenim la informació del número de cursos, però no la del número de línies, de manera que hem assumit que totes les escoles tenen només dues línies. Evidentment aquesta és una mala aproximació i estem treballant per aconseguir aquesta informació.

Aquests models tenen en compte que l'epidèmia està repartida de forma homogènia en la població del municipi. Això vol dir, per exemple, que si hi ha un brot gran però controlat (per exemple, en una residència), nosaltres assumim que tots aquells casos estan repartits per la població i per tant alguns seran infants i adolescents. Evidentment, això no és mai així i per tant aquests càlculs s'han de prendre com una primera aproximació i s'han de tenir en compte les idiosincràcies de cada municipi i cada brot per interpretar-los correctament.

**Nota: seguint aquest article (https://www.nature.com/articles/s41591-020-0962-9) s'ha tingut en compte que els infants i adolescents, en conjunt, tenen una incidència de la malaltia d'aproximadament el 60% que els adults. Aquest valor segurament vagi actualitzant-se a mesura que surten més investigacions.**

La resta de càlculs són bastant directes; si els voleu repassar, són als fitxers calcs.R i calc_funcs.R.

 Pel que fa als càlculs de probabilitats de casos, s'han utilitzat models de Poisson amb lambda igual a la prevalença de la malaltia a 14 dies.

# Exempció de responsabilitat
 
No cal dir (però ho diem igualment, que ens coneixem) que això només són models simples i que aspiren a 
ajudar a les persones a estar informades i a prendre decisions sobre l'escolarització en aquestes circumstànies 
tan complicades. Evidentment, molts altres factors s'han de tenir en compte a l'hora de prendre decisions.

Insistim, de totes maneres, que estem completament oberts a correccions i suggerències.

# Agraïments

Aquest treball està inspirat en els de @_AlexArenas, @BIOCOMSC1, @JCerquidesW i @gmnzgerard. Gràcies a tots i totes!
