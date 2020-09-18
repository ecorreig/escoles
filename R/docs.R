docs <- "
<h1> Introducció </h1>
<p> Aquesta aplicació ha estat creada pel Projecte Òrbita per tal de facilitar a famílies i escoles l'accés a 
la informació  relacionada amb l'efecte de la COVID-19 als centres educatius de Catalunya. Tota la informació 
utilitzada és pública i està referenciada en el següent apartat del document. Tots els càlculs i models utilitzats
també estan explicats més avall. El codi elaborat també és públic i el podeu trobar a 
<a href = 'https://github.com/Projecte-Orbita/escoles'target='_blank'>https://github.com/Projecte-Orbita/escoles</a>.</p>


<h1> Dades </h1>

<p>Les dades provenen de les fonts següents: </p>

<ul>- Casos COVID-19: https://analisi.transparenciacatalunya.cat/ (document jj6z-iyrp).</ul>
<ul>- Demografia: https://www.idescat.cat/pub/?id=aec&n=925 (compte que els codis de municipi tenen una xifra més que els de casos COVID; és la última, que es pot treure i aleshores coincideixen).</ul>
<ul>- Dades escoles globals: https://www.idescat.cat/pub/?id=aec&n=734.</ul>
<ul>- Dades escoles individuals: http://ensenyament.gencat.cat/ca/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/ (primer fitxer).</ul>
<ul>- Mapes: https://www.icgc.cat/Administracio-i-empresa/Descarregues/Capes-de-geoinformacio/Base-municipal.</ul>

<h1> Càlculs </h1>

<h2> Variables epidemiològiques </h2>

<p>Totes les dades epidemiològiques han estat calculades seguint les metodologies del grup biocomsc de la UPC, que podeu trobar aquí: https://biocomsc.upc.edu/en/shared/avaluacio_risc.pdf. </p>

<h2> Probabilitats </h2>

<p> Pel que fa als càlculs de probabilitats de casos, s'han utilitzat models de Poisson amb lambda igual a la prevalença de la malaltia a 14 dies. </p>

<strong>Nota: seguint aquest article (https://www.nature.com/articles/s41591-020-0962-9) s'ha tingut en compte que els infants i adolescents tenen una incidència de la malaltia d'aproximadament el 40% que els adults. Aquest valor segurament vagi actualitzant-se a mesura que surten més investigacions.</strong>

<p> Els valors de la guia de Harvard els podeu trobar aquí: https://globalepidemics.org/wp-content/uploads/2020/07/pandemic_resilient_schools_briefing_72020.pdf. </p>

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

<p>Insistim, de totes maneres, que estem completament oberts a correccions i suggerències.</p>

<h1> Agraïments </h1>

<p>Aquest treball està inspirat en els de @_AlexArenas, @BIOCOMSC1, @JCerquidesW i @gmnzgerard. Gràcies a tots!</p>


"

