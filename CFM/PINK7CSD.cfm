<!--- 
\  Copyright (c) 1987-2011 by Frank H. Rothkamm.  Adopted from Forth in 2010. All rights reserved.
\  psychostochastics - supersynthesis - humanized uniform random distributions 
\ ------------------------------------------------------------------------------

--->


<cfscript>
para.name 		= 'pink7csd';
para.comment 	= '';
</cfscript>

<CFIF NOT IsDefined("url.RequestTimeOut")>
 <CFSET  url.RequestTimeOut = "180">
</CFIF>

<CFSETTING RequestTimeOut="#url.RequestTimeOut#">

<!--- orchestra --->

<CFSAVECONTENT variable="orchestra">
<CFOUTPUT>
  
; sr = 48000
; kr =  4800
sr = 44100
kr =  4410
ksmps = 10
nchnls = 2
galeft init 0
garight init 0
; gklfo init 0


; instr 2

; gklfo      oscil3  30, 0.005, 1 

; endin


instr 1
idur     		= p3    ; total duration of event
iamp     		= p4*0.82 ; amplitude in dB: 0-96
ifreq    		= p5    ; frequency in Hz: 20-20000 (depending on sr (sample rate)) 
iat      		= p6    ; Attack portion of the AR amplitude envelope 
irel     		= p7    ; Release portion of the AR amplitude envelope                       
						; NOTE: probability is computed for the attack portion, the envelope is:
						; idur - iat = irel 
						; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    ; Start of Pan (0-1 = left to right)
ipanend   		= p9    ; End of Pan
ifilterwidth	= p10   ; Originally the Width of Notch Filter, here used as a uniform random number 1-100
irevsend  		= p11   ; Reverb Amount

   awhite unirand 2.0
   awhite = awhite - 1.0
   
   iArrow =  ((ipanstart + ipanend) * 0.5) + 0.5  
   
   print iArrow
   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
   kasc    linseg  ifreq, idur, ifreq*iArrow
                                                         
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      oscil3  50, 0.05, 1
   
   

	
/*	
   vibrato, very slight with the same envelope than the volume
*/
 		
;	a4      oscil3 k1,       (ifreq+a2)     , int(ifilterwidth/29)+1
;	a40 	lowpass2 p4, ifreq     +k2+k1, 0.3
   
    asig    pinkish awhite, 1, 0, 0, 1
    a2      butterbp asig*k1, ifreq, ifilterwidth*30+k2
    a1      clfilt a2, kasc, 1, 40
		
;    a1  =   a40 + a30b + a30 + a3c

	outs    a1 *  kpan, a1 * (1 - kpan)
    galeft    =         galeft  +  a1*kpan     * irevsend/5.7
    garight   =         garight +  a1*(1-kpan) * irevsend/5.7
endin

instr 99                 ; global reverb
     irvbtime    =         p4 
     aleft        reverb    galeft,  irvbtime
     aright       reverb    garight, irvbtime 
     outs  aright, aleft
     galeft    =    0              ; then clear it
     garight   =    0 
endin
         
</CFOUTPUT>
</CFSAVECONTENT>


<!--- score --->

<cfscript>


scale 		= 1000;

//start		= 0;
//duration 	= 10;    
//attack 		= 50;
//release		= 1;
//start 		= 1;
//db 			= 90;
//alldb 		= 90;


para.events  = 18000;	
para.maxfreq = 16000;	
para.minfreq = 50;	
para.maxdur  = 5;	
para.mindur  = 0.001;
para.attack  = 100;
para.maxdb	= 96;
para.mindb	= 36;
para.panstart= 100;
para.panend	= 100;

para.total   = 3600;	

para.revSend 	= 100;
para.filterwidth = 100;
para.revTime 	= 5;

</cfscript>



 
<!--- <cfquery DATASOURCE="iformm" NAME="para">
insert into parameters (duration,attack,release,revSend,) 
values ()
</cfquery> --->

<cfif para.maxdur GE para.total>
<cfoutput>maxdur #para.maxdur# can not be larger than total #para.total#</cfoutput>
<cfabort>
</cfif>

<cfscript>


function grnd2(a,b) {

result = RandRange(a,b,"SHA1PRNG");
return result; 
}

function RndFreq() {
// freq = 0;
// Irwin–Hall Normal Distribution 
// For (i=1;i LTE 12; i=i+1) {
// freq  = freq + RandRange(para.minfreq*scale,para.maxfreq*scale,"SHA1PRNG");
// }
// freq = freq - 6*para.maxfreq*scale;
// range = para.maxfreq*scale - para.minfreq*scale;                   

freq  = RandRange(para.minfreq*scale,para.maxfreq*scale,"SHA1PRNG");
freq  = freq - RandRange(0,freq-(para.minfreq*scale),"SHA1PRNG"); // scale down
freq  = freq / scale;
}


 
function RndEnvelope() { // 2 part envelope, what's not attack is release (decay)

duration = RandRange(para.mindur*scale,para.maxdur*scale,"SHA1PRNG");

attack = para.attack*duration/100;   // % of duration

// release = 0;
// while(release LTE 0) {
attack = RandRange(0,attack,"SHA1PRNG");  
release  = duration - attack;
// write.output(release);
// }

if  (release/scale LT 0.1 AND freq LT 100) {
duration = duration + 0.1*scale;
release =             0.1*scale;
}

attack = attack / scale;
release = release / scale;
duration = duration / scale;
// 100 * 10000 attack% @ irnd 1 max / / dup  
// attack ! - release !
}  

 
function RndStart() {
start = RandRange(0,para.total*scale,"SHA1PRNG");  
start = start/scale;
} 


function GenerateEnvelope() { 

RndEnvelope();
RndStart();

while(start + duration GT para.total) { 
RndEnvelope();
RndStart(); 
}
} 
 
FreqLimit = 20000;
dbLimit   = 96;
FreqTodBRatio  =  FreqLimit / dbLimit;
 

function RndDb() {
db = RandRange(para.mindb*scale,para.maxdb*scale,"SHA1PRNG");

Ramp =  dbLimit*scale-db;

db = db + RandRange(0,freq*scale/FreqTodBRatio-Ramp,"SHA1PRNG"); // scale up


db = db / scale;
}

function RndPan() {
PanStart = RandRange(0,para.panStart,"SHA1PRNG")/100; 
PanEnd = RandRange(0,para.panEnd,"SHA1PRNG")/100;
}

function RndrevSend() {
revSend = RandRange(0,para.revSend,"SHA1PRNG")/100;
}

function RndfilterWidth() {
filterWidth = RandRange(0,para.filterwidth,"SHA1PRNG");
}

</cfscript>


<CFSAVECONTENT variable="score">
<CFOUTPUT>
;  #para.events# events - total #para.total# seconds"
;  #NumberFormat(para.minfreq,".0")# - #NumberFormat(para.maxfreq,".0")# Hz     
;  #NumberFormat(para.mindb,".0")# - #NumberFormat(para.maxdb,".0")# dB

   f1 0 65536 10 1 .1                                                     ; Sine     .
   f2 0 65536 10 1 .5 .25 .2 .15 .2 .1 .05 .01                            ; Sawtooth ++
   f3 0 65536 10 1  0  .5  0  .2  0  .2  0  .015  0  .005                 ; Square   +++
   f4 0 65536 10 1 .9 .8 .7                                               ; Pulse    +

; Reverb
; ins     strt dur                revTime                 
  i99     0    #Evaluate(para.total+para.revTime)# #para.revTime#

; Osc	start	dur	amp	freq	attack	rel	panS	panE 	filterwidth		revSend

<CFLOOP FROM="1" TO="#para.events#" INDEX="i">#GenerateEnvelope()##RndFreq()# 	#RndDb()##RndPan()#
i1 	#NumberFormat(start,".000")#	#NumberFormat(duration,".000")#	#NumberFormat(db,".0")#	#NumberFormat(freq,".0")#	#NumberFormat(attack,".000")#	#NumberFormat(release,".000")#	#PanStart#	#PanEnd#	#RndfilterWidth()# #filterWidth# #RndrevSend()# 	#NumberFormat(revSend,".0")#</CFLOOP>

e
</CFOUTPUT>
</CFSAVECONTENT>

<CFSAVECONTENT variable="CSD">; <pre>
<CFOUTPUT>
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
#orchestra#
</CsInstruments>
<CsScore>
#score#
</CsScore>
</CsoundSynthesizer>;</pre>
</CFOUTPUT>
</CFSAVECONTENT>

<cfscript>
if (IsDefined('url.id')) { url.id = para.id; } else { para.id = '00'; }   // versioning
</cfscript>

<CFFILE action = "write" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##para.name#-#trim(numberformat(para.id,'00'))#.csd" 
output = "#CSD#">

<CFOUTPUT>
<a href="#para.name#-#trim(numberformat(para.id,'00'))#.csd">#para.name#-#trim(numberformat(para.id,'00'))#.csd</a>
<br />
<pre>#HTMLEditFormat(CSD)#</pre>
</CFOUTPUT> 