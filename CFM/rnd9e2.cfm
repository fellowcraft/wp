<cfflush interval="50"> 
<!--- <cfsilent> --->

<cfprocessingdirective PAGEENCODING="ascii"/>

<CFIF NOT IsDefined("url.RequestTimeOut")>
 <CFSET  url.RequestTimeOut = "3600">
</CFIF>

<CFSETTING RequestTimeOut="#url.RequestTimeOut#">

<cfscript>
if (IsDefined('url.id')) { url.id = id; } else { id = 0; }   // versioning
</cfscript>

<!--- 
\  Copyright (c) 1987-2011 by Frank H. Rothkamm.  Adopted from Forth in 2010. All rights reserved.
\  psychostochastics - supersynthesis - humanized uniform random distributions 
\ ------------------------------------------------------------------------------

--->

<cfscript>
name 		= 'rnd9e2';
comment 	= '';
</cfscript>

<cfscript>
scale 		= 1;

events	    = 3000;	
maxfreq 	= 15;	
minfreq 	= 17;	
maxdur  	= 360;	
mindur  	= 180;
attack  	= 50;
release 	= 50;
attack2 	= 50;
release2	= 50;
maxdb		= 96;
mindb		= 66;
panstart	= 1;
panend		= 1;

total       = 3600;	

revSend 	=  .67;
filter		= 4;
revTime 	= 0.85;
prnd      	= 4;
</cfscript>

<!--- orchestra --->

<CFSAVECONTENT variable="orchestra">

<CFOUTPUT>
sr = 44100 ;
kr =  4410 ;
ksmps = 10 ;
nchnls = 2 ;
galeft init 0 ;
garight init 0 ;
; gklfo init 0 ;

gisin   ftgen 1, 0, 65536, 10, 1, .1  ; 
gisaw   ftgen 2, 0, 65536, 10, 1, .5, .25, .2, .15, .2, .1, .05, .01  ; 
gisqu   ftgen 3, 0, 65536, 10, 1, 0,  .5,  0,  .2,  0,  .2,  0,  .015,  0,  .005 ;
gipul   ftgen 4, 0, 65536, 10, 1, .8, .6,  .4  ;

instr 2 
gklfo	oscil3  30, 0.005, 1  
endin 

instr 1 ;
idur     		= p3     		; total duration of event ;
iamp     		= ampdb(p4*0.85)	; amplitude in dB: 0-96 ;
ifreq    		= cpsoct(p5)    	; decimal octaves: 1.00-12.000 ;
iat      		= p6    		; Attack portion of the AR amplitude envelope ;  
irel     		= p7    		; Release portion of the AR amplitude envelope  ;                      
								; NOTE: probability is computed for the attack portion, the envelope is: ;
								; idur - iat = irel ; 
								; at 100 (max) for iat, attack could be the whole envelope, with release = 0 ;
ipanstart 		= p8    		; Start of Pan (0-1 = left to right) ;
ipanend   		= p9    		; End of Pan ;
ifilter			= p10   		; Originally the Width of Notch Filter, here used as a waveform selection tool ;
irevsend  		= p11   		; Reverb Amount ;
iprnd           	= p12   		; general rnd number ;
iat2      		= p13    		; Attack portion of the AR modulation envelope  ;
irel2     		= p14   		; Release portion of the AR modulation envelope ;         
   
kpan    linseg  ipanstart, idur, ipanend 
kAmpEnv linseg  0, iat,  iamp, irel,  0 
kModEnv linseg  0, iat2, iamp, irel2, 0 
kOsc    oscil3  iamp*0.01, iprnd*10, 1 
	 
ifreq = ifreq+(iwfilter*20)

a2      oscil3  kModEnv/iprnd*0.1, ifreq, 1 

a4      oscil3 kAmpEnv,               ifreq+a2      ,    ifilter+1 
a3      oscil3 kAmpEnv*0.01   +kOsc,  ifreq*iprnd+a2,    ifilter+1 

a40 	lowpass2 a4, ifreq     +kOsc+kAmpEnv, 0.3 
a30 	lowpass2 a3, ifreq*1.01+kOsc+kAmpEnv, 0.3 

;a30b 	clfilt   a3b,120, 1, 40 
		
a1 =	a40 + a30 

outs    a1 *  kpan, a1 * (1 - kpan) 

galeft    =         galeft  +  a1*kpan     * irevsend 
garight   =         garight +  a1*(1-kpan) * irevsend 

endin ;

instr 99            
irvbtime    =         p4 
aleft,  aleft  reverbsc  galeft,  galeft, irvbtime, 16000, sr, 0.5, 1 
aright, aright reverbsc  garight, garight,irvbtime, 16000, sr, 0.5, 1 
outs  aright, aleft 
galeft    =    0 
garight   =    0  

endin  

      
</CFOUTPUT>
</CFSAVECONTENT>
<cfscript>

random   = createObject("component","random");

function RndFreq() {
return  random.Range(minfreq,maxfreq); //nextrandom.Range(minfreq,maxfreq);
}

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

<!--- ============= scoreHeader ================== --->

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


