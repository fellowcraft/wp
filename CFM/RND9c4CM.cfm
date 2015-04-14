
<!--- <cfflush interval="50">--->
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
name 		= ListFirst(ListLast(CGI.Script_Name,"/"),".");
comment 	= '';
</cfscript>

<cfscript>

scale 		= 1;

events		= 1600*3*4;	  
maxfreq 	= 7.5;	
minfreq 	= 5;	
maxdur  	= 30;	
mindur  	= 0.1;
attack  	= 50;
release 	= 1;
attack2 	= 50;
release2	= 1;
maxdb	 	= 96;
mindb	 	= 36;
panstart	= 1;
panend	 	= 1;

total       = 900*4;	

revSend 	=  .3;
filter		=  16;
revTime 	= 0.9;
prnd        =  7;



// if(maxdur GE total) throw(
 
</cfscript>
 
<!--- <cfif>
<cfoutput>maxdur #maxdur# can not be larger than total #total#</cfoutput>
<cfabort>
</cfif> --->


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
; -----
gklfo	oscil3  30, 0.005, 1 

endin


instr 1
; -----
idur     		= p3     		; total duration of event
iamp     		= ampdb(p4*0.8); amplitude in dB: 0-96
ifreq    		= cpsoct(p5)    ; decimal octaves: 1.00-12.000
iat      		= p6    		; Attack portion of the AR amplitude envelope 
irel     		= p7    		; Release portion of the AR amplitude envelope                       
								; NOTE: probability is computed for the attack portion, the envelope is:
								; idur - iat = irel 
								; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    		; Start of Pan (0-1 = left to right)
ipanend   		= p9    		; End of Pan
ifilter			= p10   		; Originally the Width of Notch Filter, here used as a waveform selection tool
irevsend  		= p11   		; Reverb Amount
iprnd           = p12   		; general rnd number
iat2      		= p13    		; Attack portion of the AR modulation envelope 
irel2     		= p14   		; Release portion of the AR modulation envelope         
   
kpan    linseg  ipanstart, idur, ipanend   
kAmpEnv linseg  0, iat,  iamp, irel,  0 
kModEnv linseg  0, iat2, iamp, irel2, 0
kOsc    oscil3  iamp*0.00033, .15, 1

; ifreq = ifreq+(ifilter*10)
	 
a2      oscil3  kModEnv/iprnd*0.01, ifreq, ifilter

a4      oscil3 kAmpEnv,      (ifreq+a2)   , ifilter

; a3      oscil3 kAmpEnv*0.2   +kOsc,  ifreq/iprnd+a2, ifilter

; a3b     oscil3 kOsc,  ifreq*iprnd+a2, ifilter

; a3c     oscil3 kOsc*0.1,  ifreq*(iprnd/10)*4+a2, ifilter

; a40 	lowpass2 a4, ifreq     +kOsc+kAmpEnv, 0.3
; a30 	lowpass2 a3, ifreq*2.01+kOsc+kAmpEnv, 0.3
		
a1 =	a4  ; + a3

outs    a1 *  kpan, a1 * (1 - kpan)

galeft    =         galeft  +  a1*kpan     * irevsend
garight   =         garight +  a1*(1-kpan) * irevsend

endin

instr 99                 ; global reverb
;-------
irvbtime    =         p4 
aleft,  aleft  reverbsc  galeft,  galeft, irvbtime, 18000, sr, 0.5, 1 
aright, aright reverbsc  garight, garight,irvbtime, 18000, sr, 0.5, 1 
outs  aright, aleft
galeft    =    0
garight   =    0 

endin 

         
</CFOUTPUT>
</CFSAVECONTENT>



<!--- score --->

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
return   int(random.Range(1,filter));
}

function RndPitch() {
return   int(RAND() * prnd);
}


</cfscript>

<!--- ============= scoreHeader ==================--->

<CFSAVECONTENT variable="scoreHeader">
<CFOUTPUT>
;  #events# events - total #total# seconds"
;  #NumberFormat(minfreq,".0")# - #NumberFormat(maxfreq,".0")# Hz     
;  #NumberFormat(mindb,".0")# - #NumberFormat(maxdb,".0")# dB


<cfloop from="1" to="16" index="i">
f#i# 0 65536 10 #random.Range1(0,1)# #random.Range1(0,1)# #random.Range1(0,1)# #random.Range1(0,1)# #random.Range1(0,1)# #random.Range1(0,1)#</cfloop>


; Reverb
; ins     strt dur                					revTime                 
  i99     0    #Evaluate(total+revTime*3)# #revTime#

;++..time02....dur03....amp04...freq05.attack06....rel07...panS08...panE09.filter10.revSen11...gRnd12.attack13...relE14

</CFOUTPUT>
</CFSAVECONTENT>

<!--- ============= scoreData ==================--->

<!--- kill/ --->
<CFIF ID EQ 0>
<CFQUERY DATASOURCE="iformm" NAME="P">
DELETE FROM P 
WHERE UID = #ID#
</CFQUERY>
</CFIF>
<!--- /kill --->

<!--- gen/ --->
<CFLOOP FROM="1" TO="#events#" INDEX="i">

<cfscript>

GenerateEnvelope();

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
WHERE ID = #ID# --->

INSERT into P (
p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,UID
)
VALUES (
#start#,
#duration#,
#RndDb()#,
#RndFreq()#,
#at#,
#release#,
#RndPanStart()#,
#RndPanEnd()#,
#RndfilterWidth()#,
#RndrevSend()#,
#RndPitch()#,
#at2#,
#release2#,
#ID#
)

</CFQUERY>

</CFLOOP>
<!--- /gen --->

<!--- read/ --->
<CFQUERY DATASOURCE="iformm" NAME="PData">
SELECT * FROM P 
WHERE UID = #ID# AND p5 > 0
ORDER BY p3 
</CFQUERY>

<cfscript>function displayDB(p5) { x=p5/10-1; return int(x); }</cfscript>

<CFSAVECONTENT variable="scoreData">
<CFOUTPUT query="PData"><!--- <CFIF int(p3) MOD 60 LTE 1>; -----------------------------------------------------------------------------------------------------------------------#chr(10)##chr(13)#</CFIF> --->i1 #NumberFormat(p3,"9999.999")# #NumberFormat(p4,"9999.999")# #NumberFormat(p5,"9999.999")# #NumberFormat(p6,"9999.999")# #NumberFormat(p7,"9999.999")# #NumberFormat(p8,"9999.999")# #NumberFormat(p9,"9999.999")# #NumberFormat(p10,"9999.999")# #NumberFormat(p11,"9999.999")# #NumberFormat(p12,"9999.999")# #NumberFormat(p13,"9999.999")# #NumberFormat(p14,"9999.999")# #NumberFormat(p15,"9999.999")# ;#NumberFormat(currentrow,"9999")# [#NumberFormat(Evaluate(int(p3/60)),"999")#:#NumberFormat(Evaluate(p3 mod 60),"00")#] <CFLOOP from="1" to="#displayDB(p5)#" index="i">.</CFLOOP>| #chr(10)##chr(13)#</CFOUTPUT> 
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

<cfscript>

version = 0;
csdFile = name & "-" & version;

while(FileExists('#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd')) {
version = version + 1;
csdFile = name & "-" & version;
}

</cfscript>


<CFFILE action = "write" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd" 
output = '#CSD#'>


<CFFILE action="READ"
file="#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.csd" 
variable="CSD">


<!--- </cfsilent> --->
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
<cfexecute name="c:\windows\system32\cmd.exe" arguments="/c csound -o #drive#\rothkamm\snd\#csdFile#.wav #drive#\rothkamm\IFORMM\CSOUND\#csdFile#.csd" timeout="#url.RequestTimeOut#" outputFile="#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.log"></cfexecute>
 

<CFFILE action="READ"
file="#GetDirectoryFromPath(ExpandPath("*.*"))##csdFile#.log" 
variable="logfile"> 

#logfile#

<a href="/snd/#csdFile#.wav">#csdFile#.wav</a>

</cfif>
</font></pre>


<!--- <cfchart FORMAT="PNG"  --->

</html>
</CFOUTPUT> 


