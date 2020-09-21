docs <- "
<h1> Introducció </h1>
<p> Aquesta aplicació ha estat creada pel Projecte Òrbita per tal de facilitar a famílies i centres educatius l'accés a
la informació  relacionada amb l'efecte de la COVID-19 als centres educatius de Catalunya. Tota la informació
utilitzada és pública i està referenciada en el següent apartat del document. Tots els càlculs i models utilitzats
també estan explicats més avall. El codi elaborat també és públic i el podeu trobar a
<a href = 'https://github.com/Projecte-Orbita/escoles' target='_blank'>https://github.com/Projecte-Orbita/escoles</a>.</p>


<h1> Dades </h1>

<p>Les dades provenen de les fonts següents: </p>

<ul>- Casos COVID-19: <a href = 'https://analisi.transparenciacatalunya.cat/' target='_blank'>https://analisi.transparenciacatalunya.cat/ </a> (document jj6z-iyrp).</ul>
<ul>- Demografia: <a href = 'https://www.idescat.cat/pub/?id=aec&n=925' target='_blank'>https://www.idescat.cat/pub/?id=aec&n=925</a>  (compte que els codis de municipi tenen una xifra més que els de casos COVID; és la última, que es pot treure i aleshores coincideixen).</ul>
<ul>- Dades centres educatius globals: <a href = 'https://www.idescat.cat/pub/?id=aec&n=734' target='_blank'>https://www.idescat.cat/pub/?id=aec&n=734</a>.</ul>
<ul>- Dades centres educatius individuals: <a href = 'http://ensenyament.gencat.cat/ca/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/' target='_blank'>http://ensenyament.gencat.cat/ca/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/</a> (primer fitxer).</ul>
<ul>- Mapes: <a href = 'https://www.icgc.cat/Administracio-i-empresa/Descarregues/Capes-de-geoinformacio/Base-municipal' target='_blank'>https://www.icgc.cat/Administracio-i-empresa/Descarregues/Capes-de-geoinformacio/Base-municipal</a>.</ul>

<h1> Càlculs </h1>

<h2> Variables epidemiològiques </h2>

<p>Totes les dades epidemiològiques han estat calculades seguint les metodologies del grup biocomsc de la UPC, que podeu trobar aquí: <a href='https://biocomsc.upc.edu/en/shared/avaluacio_risc.pdf' target='_blank'>https://biocomsc.upc.edu/en/shared/avaluacio_risc.pdf</a>. </p>

<h4> Risc de rebrot </h4>

<p>El risc de rebrot, també anomenat índex de creixement potencial (EPG per les seves sigles en anglès) és calcula com la multiplicació de la rho7 i l'incidència acumulada a 14 dies (per 100.000 habitants). Utilitzem aquest índex com a principal ja que s'ha establert com el de referència en les comunicacions oficials i dels mitjans de comunicació de Catalunya. </p>

<h4> Incidència acumulada a 14 dies </h4>

<p> Aquest valor és simplement la suma de tots els casos positius confirmats per PCR dels últims 14 dies dividits per cada 100.000 habitants. </p>

<h4> Rho 7 </h4>

La rho_0, en models epidemiològics, és la taxa base de creixement. En el nostre cas aquest número no té massa sentit teòric, perquè les restriccions modifiquen molt la rho0 (és la seva feina) i per tant, a nivell teòric, no té sentit. És per això que des de la UPC han creat la rho experimenta, que calculen com a la suma de casos dels tres últims dies dividit per la suma de casos d'entre 5 i 8 dies anteriors al que es calcula. La rho_7 és aleshores la mitjana de la rho calculada d'aquesta manera dels últims 7 dies. </p>

<h4> Guia de Harvard </h4>

La guia de Harvard, que podeu trobar <a href = 'https://globalepidemics.org/wp-content/uploads/2020/07/pandemic_resilient_schools_briefing_72020.pdf' target='_blank'>aquí</a> dóna referències per tal de decidir si obrir les comunitats (en particular centres educatius) segons l'estat de la pandèmia i, en concret, segons el número de casos confirmats diaris per cada 100.000 habitants. El resum de la guia seria:</p>
<ol> Verd: tots els centres educatius han d'obrir sempre que es compleixin els protocols de seguretat. </ol>
<ol> Groc: Guarderies obertes i centres d'educació espeicial fins a 8 anys oberts. Primària fins a 8 anys i educació especial fins a 12 anys s'han d'obrir només si els protocols de seguretat es poden complir estríctament en tots els centres del territori afectat.</ol>
<ol> Taronja: igual que l'anterior, però només si tots els centres del territori poden complir els protocols de forma totalment estricta.</ol>
<ol> Vermell: tots els centres educatius del territori han d'estar tancats. </ol>

<h2> Probabilitats </h2>

<p> Pel que fa als càlculs de probabilitats de casos, s'han utilitzat models de Poisson amb lambda igual a la prevalença de la malaltia a 14 dies. </p>

<strong>Nota: seguint aquest <a href = 'https://www.nature.com/articles/s41591-020-0962-9' target='_blank'>article</a> s'ha tingut en compte que els infants i adolescents tenen una incidència de la malaltia d'aproximadament el 40% que els adults. Aquest valor segurament vagi actualitzant-se a mesura que surten més investigacions.</strong>

<p> La resta de càlculs són bastant directes; si els voleu repassar, són als fitxers calcs.R i calc_funcs.R. </p>

<h1> Llicència: MIT </h1>
<h4>Copyright 2020, Projecte Òrbita SCCL</h4>

<p>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:</p>

<p>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.</p>

<p>THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.</p>

<p>A més, us convidem a fer-nos arribar suggerències de millora o de rectificació a info@projecteorbita.cat.</p>


<h1> Exempció de responsabilitat </h1>

<p> No cal dir (però ho diem igualment, que ens coneixem) que això només són models simples i que aspiren a
ajudar a les persones a estar informades i a prendre decisions sobre l'escolarització en aquestes circumstànies
tan complicades. Evidentment, molts altres factors s'han de tenir en compte a l'hora de prendre decisions.</p>

<p> Afegim també que nosaltres no som epidemiòlogs, així que ens limitem a reproduir els càlculs de @BIOCOMSC1 i afegir càlculs de probabilitats trivials.</p>

<p>Insistim, de totes maneres, que estem completament oberts a correccions i suggerències.</p>

<h1> Agraïments </h1>

<p>Aquest treball està inspirat en els de @_AlexArenas, @BIOCOMSC1, @JCerquidesW i @gmnzgerard. Gràcies a tots i totes!</p>


"

