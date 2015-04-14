<!--- 
\  Copyright (c) 1987-2011 by Frank H. Rothkamm.  Adopted from Forth in 2010. All rights reserved.
\  psychostochastics - supersynthesis - humanized uniform random distributions 
\ ------------------------------------------------------------------------------

--->


<cfscript>
para.name 		= 'pink[39-4]recon';
para.comment 	= '';
</cfscript>


<CFIF NOT IsDefined("url.RequestTimeOut")>
 <CFSET  url.RequestTimeOut = "180">
</CFIF>

<cfscript>
if (IsDefined('url.id')) { url.id = para.id; } else { para.id = '00'; }   // versioning
if (IsDefined('url.testDiv')) { testDiv = url.testDiv; } else { testDiv = 1; }   // testing

</cfscript>


<CFSETTING RequestTimeOut="#url.RequestTimeOut#">

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
idur     		= p3    ; total duration of event
iamp     		= p4*0.8 ; amplitude in dB: 0-96
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

   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
                                                         
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      poscil  k1, 0.05, 1,
	 
	a2      poscil k1*0.000006, ifilterwidth*0.3+k2, 1 ; int(ipanstart*3.9)+1
	             
	a4      poscil k1,       (ifreq)     , int(ifilterwidth/29)+1
	a40 	lowpass2 a4,  ifreq    +k2, .5
	
	a3      poscil k1*0.08,  (ifreq)*2.01, int(ifilterwidth/29)+1
    a30 	lowpass2 a3,  ifreq*2.01+k2, .5

	a3b     poscil k1*0.01,  (ifreq)*0.51, int(ifilterwidth/29)+1
	a30b 	clfilt a3b, 120, 1, 40

	a3c     poscil k1*0.004,  (ifreq)*4.02, int(ifilterwidth/29)+1
		
    a1  =   a40 + a30b + a30 + a3c

	outs    a1 *  kpan, a1 * (1 - kpan)
    galeft    =         galeft  +  a1*kpan     * irevsend*.5
    garight   =         garight +  a1*(1-kpan) * irevsend*.5
endin

instr 99                 ; global reverb
;-------
irvbtime    =         p4 
aleft,  aleft  reverbsc  galeft,  galeft, irvbtime, 12000, sr, 0.5, 1 
aright, aright reverbsc  garight, garight,irvbtime, 12000, sr, 0.5, 1 
outs  aright, aleft
galeft    =    0
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


para.events  = 18000 / testDiv;	
para.maxfreq = 800;	
para.minfreq = 50;	
para.maxdur  = 5;	
para.mindur  = 0.001;
para.attack  = 100;
para.maxdb	 = 96;
para.mindb	 = 36;
para.panstart= 100;
para.panend	 = 100;

para.total   = 3600 / testDiv;	

para.revSend 	= 100;
para.filterwidth = 100;
para.revTime 	= .85;

</cfscript>


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

; Osc	start	dur	amp	freq	attack	rel	panS	panE 	filterwidth		revSend

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
p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,UID
)
VALUES (
#NumberFormat(start,".000")#,
#NumberFormat(duration,".000")#,
#NumberFormat(db,".0")#,
#NumberFormat(freq,".0")#,
#NumberFormat(attack,".000")#,
#NumberFormat(release,".000")#,
#PanStart#,
#PanEnd#,
#filterWidth#,
#NumberFormat(revSend,".0")#,
#para.ID#
)

</CFQUERY>

</CFLOOP>
<!--- /gen --->

<!--- read/ --->
<CFQUERY DATASOURCE="iformm" NAME="PData">
SELECT * FROM P 
WHERE UID = #para.ID# 
ORDER BY p3 
</CFQUERY>

<CFSAVECONTENT variable="scoreData">
<CFOUTPUT query="PData">i1	#NumberFormat(p3,".000")#	#NumberFormat(p4,".000")#	#NumberFormat(p5,".0")#	#NumberFormat(p6,".0")#	#NumberFormat(p7,".000")#	#NumberFormat(p8,".000")#	#p9#	#p10#	#p11#	#NumberFormat(p12,".0")# #chr(10)##chr(13)#
</CFOUTPUT>
</CFSAVECONTENT>
<!--- read/ --->


<CFSAVECONTENT variable="CSD">; <pre>
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
</CsoundSynthesizer>;</pre>
</CFOUTPUT>
</CFSAVECONTENT>




<CFFILE action = "write" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##para.name#-#trim(numberformat(para.id,'00'))#.csd" 
output = "#CSD#">

<CFOUTPUT>
<a href="#para.name#-#trim(numberformat(para.id,'00'))#.csd">#para.name#-#trim(numberformat(para.id,'00'))#.csd</a>
<br />
<pre>#HTMLEditFormat(CSD)#</pre>
</CFOUTPUT> 