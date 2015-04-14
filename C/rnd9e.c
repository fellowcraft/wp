#include <stdio.h>
#include <gsl/gsl_rng.h>

/*
<cfscript>
if (IsDefined('url.id')) { url.id = id; } else { id = 0; }   // versioning
</cfscript>
*/

/*  Copyright (c) 1987-2012 by Frank H. Rothkamm. Forth 1998. Coldfusion 2010. C 2012. 
 *  psychostochastics - supersynthesis - humanized uniform random distributions  
 */

char name[] 	= "rnd9e";
char comment[] = "";
float scale 	= 1;

int events	= 1000000;	
float maxfreq 	= 7;	
float minfreq 	= 7;	
float maxdur  	= 5;	
float mindur  	= 0.001;
float attack  	= 5;
float release 	= 1;
float attack2 	= 80;
float release2	= 1;
float maxdb	= 96;
float mindb	= 36;
float panstart	= 1;
float panend	= 1;

int total       = 3600;	

float revSend 	=  .60;
float filter	= 4;
float revTime 	= 0.85;
float prnd      = 4;


main(void) { 
// orchestra 

puts(
"sr = 44100 \n"
"kr =  4410 \n"
"ksmps = 10 \n"
"nchnls = 2 \n"
"galeft init 0 \n"
"garight init 0 \n"
"; gklfo init 0 \n"
"\n"
"gisin   ftgen 1, 0, 65536, 10, 1, .1  \n" 
"gisaw   ftgen 2, 0, 65536, 10, 1, .5, .25, .2, .15, .2, .1, .05, .01  \n" 
"gisqu   ftgen 3, 0, 65536, 10, 1, 0,  .5,  0,  .2,  0,  .2,  0,  .015,  0,  .005 \n"
"gipul   ftgen 4, 0, 65536, 10, 1, .8, .6,  .4  \n"
"\n"
"instr 2 \n"
"gklfo	oscil3  30, 0.005, 1 \n" 
"endin \n"
"\n"
"instr 1 \n"
"idur     		= p3     		; total duration of event \n"
"iamp     		= ampdb(p4*0.85)	; amplitude in dB: 0-96 \n"
"ifreq    		= cpsoct(p5)    	; decimal octaves: 1.00-12.000 \n"
"iat      		= p6    		; Attack portion of the AR amplitude envelope \n"  
"irel     		= p7    		; Release portion of the AR amplitude envelope  \n"                      
"						; NOTE: probability is computed for the attack portion, the envelope is: \n"
"						; idur - iat = irel \n" 
"						; at 100 (max) for iat, attack could be the whole envelope, with release = 0 \n"
"ipanstart 		= p8    		; Start of Pan (0-1 = left to right) \n"
"ipanend   		= p9    		; End of Pan \n"
"ifilter		= p10   		; Originally the Width of Notch Filter, here used as a waveform selection tool \n"
"irevsend  		= p11   		; Reverb Amount \n"
"iprnd           	= p12   		; general rnd number \n"
"iat2      		= p13    		; Attack portion of the AR modulation envelope  \n"
"irel2     		= p14   		; Release portion of the AR modulation envelope \n"         
   
"kpan    linseg  ipanstart, idur, ipanend   \n"
"kAmpEnv linseg  0, iat,  iamp, irel,  0  \n"
"kModEnv linseg  0, iat2, iamp, irel2, 0 \n"
"kOsc    oscil3  iamp*0.01, iprnd*10, 1 \n"
	 
"ifreq = ifreq+(ifilter*20) \n"

"a2      oscil3  kModEnv/iprnd*0.1, ifreq, 1 \n"

"a4      oscil3 kAmpEnv,               ifreq+a2      ,    ifilter+1 \n"
"a3      oscil3 kAmpEnv*0.01   +kOsc,  ifreq*iprnd+a2,    ifilter+1 \n"

"a40 	lowpass2 a4, ifreq     +kOsc+kAmpEnv, 0.3 \n"
"a30 	lowpass2 a3, ifreq*1.01+kOsc+kAmpEnv, 0.3 \n"

";a30b 	clfilt   a3b,120, 1, 40 \n"
		
"a1 =	a40 + a30 \n"

"outs    a1 *  kpan, a1 * (1 - kpan) \n"

"galeft    =         galeft  +  a1*kpan     * irevsend \n"
"garight   =         garight +  a1*(1-kpan) * irevsend \n"

"endin \n"

"instr 99                 ; global reverb \n"
"irvbtime    =         p4  \n"
"aleft,  aleft  reverbsc  galeft,  galeft, irvbtime, 16000, sr, 0.5, 1  \n"
"aright, aright reverbsc  garight, garight,irvbtime, 16000, sr, 0.5, 1  \n"
"outs  aright, aleft \n"
"galeft    =    0 \n"
"garight   =    0  \n"

"endin  \n"


         
// score

);

// printf(name);

RndFreq() {
return  random.Range(minfreq,maxfreq); 
}


/*
function RndEnvelope() { 

start    = random.Range(0,total);

duration = random.Loga() * 3;

at   =  attack*duration/100;   // % of duration
at2  =  attack2*duration/100; 

at   = random.Range(0,at);
at2  = random.Range(0,at2);  

release = duration - at;
release2= duration - at2;

if  (release LT 0.1) {
duration = duration + 0.1;
release =             0.1;
}
}

function GenerateEnvelope() {

RndEnvelope(); 

while(start + duration GT total) { 
RndEnvelope(); 
}
} 
 
 
FreqLimit = 20000;
dbLimit   = 96;
FreqTodBRatio  =  FreqLimit / dbLimit;
 
function RndDb() {
return   random.Range(mindb,maxdb);

//Ramp =  dbLimit-db;
//db = db + random.Range(0,freq/FreqTodBRatio-Ramp); // scale up
// db = db / scale;
}

function RndPanStart() {
return   random.Range(0,panStart); 
}

function RndPanEnd() {
return   random.Range(0,panEnd);
}

function RndrevSend() {
return   random.Range(0,revSend);
}

function RndfilterWidth() {
return   random.Range(0,filter);
}

function RndPitch() {
return   int(RAND() * prnd)^2;
}


</cfscript>

============= scoreHeader ==================

<CFSAVECONTENT variable="scoreHeader">
<CFOUTPUT>
;  #events# events - total #total# seconds
;  #NumberFormat(minfreq,".0")# - #NumberFormat(maxfreq,".0")# Hz     
;  #NumberFormat(mindb,".0")# - #NumberFormat(maxdb,".0")# dB


; Reverb
; ins     strt dur                					revTime                 
  i99     0    #Evaluate(total+revTime*3)# #revTime#

;++..time02....dur03....amp04...freq05.attack06....rel07...panS08...panE09.filter10.revSen11...gRnd12.attack13...relE14

</CFOUTPUT>
</CFSAVECONTENT>

============= WriteCSD ==================

<CFSET csdFile = "#name#-#trim(numberformat(id,'00'))#">

<CFFILE action = "write" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd"
output='
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
#orchestra#
</CsInstruments>
<CsScore>
#scoreHeader#
 '>

<!--- gen/ --->
<CFLOOP FROM="1" TO="#events#" INDEX="i">

<cfscript>
GenerateEnvelope();
</cfscript>


<CFFILE action = "append" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd" 
output = 'i1 #NumberFormat(start,"9999.999")# #NumberFormat(duration,"9999.999")# #NumberFormat(RndDb(),"9999.999")# #NumberFormat(RndFreq(),"9999.999")# #NumberFormat(at,"9999.999")# #NumberFormat(release,"9999.999")# #NumberFormat(RndPanStart(),"9999.999")# #NumberFormat(RndPanEnd(),"9999.999")# #NumberFormat(RndfilterWidth(),"9999.999")# #NumberFormat(RndrevSend(),"9999.999")# #NumberFormat(RndPitch(),"9999.999")# #NumberFormat(at2,"9999.999")# #NumberFormat(release2,"9999.999")# ;#NumberFormat(i,"9999")# #NumberFormat(Evaluate(int(start/60)),"999")#:#NumberFormat(Evaluate(start mod 60),"00")# #chr(10)##chr(13)#'>

</CFLOOP>

<CFFILE action = "append" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd"
output='
e
</CsScore>
</CsoundSynthesizer>
'>



<CFOUTPUT>
<a href="#csdFile#.csd">#csdFile#.csd</a>
</CFOUTPUT>

<!---
<CFFILE action="READ"
file="#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd" 
variable="CSD">

<html><font size="1" face="Lucida Console, Monaco, monospace">#HTMLeditformat(CSD)#
--->

<!--- <cfif IsDefined("URL.play")>
<cfexecute name="csound" arguments="-odac5 #csdFile#.csd" timeout="60" variable="csound"></cfexecute>
 #csound#
</cfif>
 --->

<cfif IsDefined("URL.write")>
<cfexecute name="csound" arguments="-+rtmidi=null -o /home/frank/rothkamm/snd/#csdFile#.wav /home/frank/rothkamm/IFORMM/CSOUND/#csdFile#.csd" timeout="360" variable="csound"></cfexecute>
 #csound#

<a href="/snd/#csdFile#.wav">#csdFile#.wav</a>

</cfif>
</font></pre>


<!--- <cfchart FORMAT="PNG"  --->

</html>
 
*/

}


