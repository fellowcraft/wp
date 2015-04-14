
<cfflush interval="50"> 
<cfsilent>

<cfprocessingdirective PAGEENCODING="ascii"/>

<CFIF NOT IsDefined("url.RequestTimeOut")>
 <CFSET  url.RequestTimeOut = "180">
</CFIF>

<CFSETTING RequestTimeOut="#url.RequestTimeOut#">

<cfscript>
if (IsDefined('url.id')) { url.id = para.id; } else { para.id = 0; }   // versioning
</cfscript>

<!--- 
\  Copyright (c) 1987-2011 by Frank H. Rothkamm.  Adopted from Forth in 2010. All rights reserved.
\  psychostochastics - supersynthesis - humanized uniform random distributions 
\ ------------------------------------------------------------------------------

--->

<cfscript>
para.name 		= 'rnd9csd';
para.comment 	= '';
</cfscript>

<cfscript>

scale 		= 1000;

para.events  = 1800;	
para.maxfreq = 9.0;	
para.minfreq = 7.0;	
para.maxdur  = 1;	
para.mindur  = 0.001;
para.attack  = 5;
para.maxdb	 = 96;
para.mindb	 = 36;
para.panstart= 100;
para.panend	 = 100;

para.total   = 360;	

para.revSend 	= 100;
para.filterwidth = 100;
para.revTime 	= .85;
para.prnd       = 3;

</cfscript>


<!--- orchestra --->

<CFSAVECONTENT variable="orchestra">
<CFOUTPUT>
;sr = 48000
;kr =  4800
sr = 44100
kr =  4410
ksmps = 10
nchnls = 2
galeft init 0
garight init 0
; gklfo init 0

instr 2

gklfo      oscil3  30, 0.005, 1 

endin


instr 1
idur     		= p3     		; total duration of event
iamp     		= p4*0.8 		; amplitude in dB: 0-96
ifreq    		= cpsoct(p5)    ; decimal octaves: 1.00-12.000
iat      		= p6    		; Attack portion of the AR amplitude envelope 
irel     		= p7    		; Release portion of the AR amplitude envelope                       
								; NOTE: probability is computed for the attack portion, the envelope is:
								; idur - iat = irel 
								; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    		; Start of Pan (0-1 = left to right)
ipanend   		= p9    		; End of Pan
ifilterwidth	= p10   		; Originally the Width of Notch Filter, here used as a uniform random number 1-100
irevsend  		= p11   		; Reverb Amount
iprnd           = p12   		; general rnd number

   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
                                                         
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      oscil3  3, 0.005, 1,
	 
	a2      oscil3 k1*0.0006, ifilterwidth*iprnd+k2, 1 ; int(ipanstart*3.9)+1
	
	a4      oscil3 k1,       (ifreq+a2)     , int(ifilterwidth/29)+1
	a40 	lowpass2 a4, ifreq     +k2+k1, 0.3
	
	a3      oscil3 k1*0.8,  (ifreq+a2)*iprnd, int(ifilterwidth/29)+1
    a30 	lowpass2 a3, ifreq*2.01+k2+k1, 0.3

	a3b     oscil3 k1*0.1,  (ifreq+a2)*iprnd, int(ifilterwidth/29)+1
	a30b 	clfilt a3b, 120, 1, 40

	a3c     oscil3 k1*0.4,  (ifreq+a2)*iprnd, int(ifilterwidth/29)+1
		
    a1  =   a40 + a30b + a30 + a3c

	outs    a1 *  kpan, a1 * (1 - kpan)
    galeft    =         galeft  +  a1*kpan     * irevsend*.3
    garight   =         garight +  a1*(1-kpan) * irevsend*.3
endin

instr 99                 ; global reverb
     irvbtime    =         p4 
;     aleft        reverb    galeft,  irvbtime
;     aright       reverb    garight, irvbtime 
;     outs  aleft, aright 
      aleft,  aleft reverbsc   galeft,  galeft, irvbtime, 12000, sr, 0.5, 1 
     aright, aright reverbsc  garight, garight, irvbtime, 12000, sr, 0.5, 1 
     outs  aright, aleft
     galeft    =    0              ; then clear it
     garight   =    0 
endin 

         
</CFOUTPUT>
</CFSAVECONTENT>






<!--- score --->

<!--- <cfquery DATASOURCE="iformm" NAME="para">
select * 
from parameters
where ID = #ID#
</cfquery>
 --->
 
<cfif para.maxdur GE para.total>
<cfoutput>maxdur #para.maxdur# can not be larger than total #para.total#</cfoutput>
<cfabort>
</cfif>




<cfscript>

function grnd2(a,b) {

result = RandRange(a,b,"SHA1PRNG");
return result; 
}


freq = 0;


function expo(rnd,lambda) {
	
result = log(RAND()* rnd) / lambda;

return result;
}



// x =  2^10;

function RndFreq() {
// freq = 0;
// Irwin–Hall Normal Distribution 
// For (i=1;i LTE 12; i=i+1) {
// freq  = freq + RandRange(para.minfreq*scale,para.maxfreq*scale,"SHA1PRNG");
// }
// freq = freq - 6*para.maxfreq*scale;
// range = para.maxfreq*scale - para.minfreq*scale;                   
 
freq  = RandRange(para.minfreq*scale,para.maxfreq*scale,"SHA1PRNG");
// freq  = freq - RandRange(0,freq-(para.minfreq*scale),"SHA1PRNG"); // scale down
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


function RndPitch() {
Prnd = RAND() * para.prnd;
}


</cfscript>

<!--- ============= scoreHeader ==================--->

<CFSAVECONTENT variable="scoreHeader">
<CFOUTPUT>
;  #para.events# events - total #para.total# seconds"
;  #NumberFormat(para.minfreq,".0")# - #NumberFormat(para.maxfreq,".0")# Hz     
;  #NumberFormat(para.mindb,".0")# - #NumberFormat(para.maxdb,".0")# dB

   f1 0 65536 10 1 .1                                                     ; Sine     .
   f2 0 65536 10 1 .5 .25 .2 .15 .2 .1 .05 .01                            ; Sawtooth ++
   f3 0 65536 10 1  0  .5  0  .2  0  .2  0  .015  0  .005                 ; Square   +++
   f4 0 65536 10 1 .9 .8 .7                                               ; Pulse    +

; Reverb
; ins     strt dur                					revTime                 
  i99     0    #Evaluate(para.total+para.revTime)# #para.revTime#

;++....time......dur......amp.....freq...attack......rel.....panS.....panE.filterwi..revSend

</CFOUTPUT>
</CFSAVECONTENT>

<!--- ============= scoreData ==================--->

<!--- kill/ --->
<CFIF para.ID EQ 0>
<CFQUERY DATASOURCE="iformm" NAME="P">
DELETE FROM P 
WHERE UID = #para.ID#
</CFQUERY>
</CFIF>
<!--- /kill --->

<!--- gen/ --->
<CFLOOP FROM="1" TO="#para.events#" INDEX="i">

<cfscript>

GenerateEnvelope();
RndFreq();	
RndDb();
RndPan();
RndfilterWidth();
RndrevSend();
RndPitch();
</cfscript>


<CFQUERY DATASOURCE="iformm" NAME="P">

<!--- UPDATE P SET 
p3  = #NumberFormat(start,".000")#,
p4  = #NumberFormat(duration,".000")#,
p5  = #NumberFormat(db,".0")#,
p6  = #NumberFormat(freq,".0")#,
p7  = #NumberFormat(attack,".000")#,
p8  = #NumberFormat(release,".000")#,
p9  = #PanStart#,
p10 = #PanEnd#,
p11 = #filterWidth#,
p12 = #NumberFormat(revSend,".0")#
WHERE ID = #para.ID# --->

INSERT into P (
p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13, UID
)
VALUES (
#start#,
#duration#,
#db#,
#freq#,
#attack#,
#release#,
#PanStart#,
#PanEnd#,
#filterWidth#,
#revSend#,
#Prnd#,
#para.ID#
)

</CFQUERY>

</CFLOOP>
<!--- /gen --->

<!--- read/ --->
<CFQUERY DATASOURCE="iformm" NAME="PData">
SELECT * FROM P 
WHERE UID = #para.ID# AND p5 > 0
ORDER BY p3 
</CFQUERY>


<CFSAVECONTENT variable="scoreData">
<CFOUTPUT query="PData">i1 #NumberFormat(p3,"9999.999")# #NumberFormat(p4,"9999.999")# #NumberFormat(p5,"9999.999")# #NumberFormat(p6,"9999.999")# #NumberFormat(p7,"9999.999")# #NumberFormat(p8,"9999.999")# #NumberFormat(p9,"9999.999")# #NumberFormat(p10,"9999.999")# #NumberFormat(p11,"9999.999")# #NumberFormat(p12,"9999.999")# #NumberFormat(p13,"9999.999")# ;#NumberFormat(currentrow,"9999")# #chr(10)##chr(13)#
</CFOUTPUT>
</CFSAVECONTENT>

<!--- read/ --->

<CFSAVECONTENT variable="CSD">
<CFOUTPUT>
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
#orchestra#
</CsInstruments>
<CsScore>
#scoreHeader#
#scoreData#
e
</CsScore>
</CsoundSynthesizer>
</CFOUTPUT>
</CFSAVECONTENT>

<CFSET csdFile = "#para.name#-#trim(numberformat(para.id,'00'))#">

<CFFILE action = "write" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd" 
output = '#CSD#'>


<CFFILE action="READ"
file="#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd" 
variable="CSD">


</cfsilent>
<CFOUTPUT>
<a href="#csdFile#.csd">#csdFile#.csd</a>
<br />
<html><pre><font size="1" face="Lucida Console, Monaco, monospace">#HTMLeditformat(CSD)#

<!--- <cfif IsDefined("URL.play")>
<cfexecute name="csound" arguments="-odac5 #csdFile#.csd" timeout="60" variable="csound"></cfexecute>
 #csound#
</cfif>
 --->
<cfif IsDefined("URL.write")>
<cfexecute name="csound" arguments="-o c:\rothkamm\snd\#csdFile#.wav C:\rothkamm\IFORMM\CSOUND\#csdFile#.csd" timeout="360" variable="csound"></cfexecute>
 #csound#

<a href="/snd/#csdFile#.wav">#csdFile#.wav</a>

</cfif>
</font></pre>


<!--- <cfchart FORMAT="PNG"  --->

</html>
</CFOUTPUT> 



