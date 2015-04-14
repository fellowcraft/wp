#!/usr/bin/python
import random

""" 
Copyright (c) 1987-2013 by Frank H. Rothkamm.  Adopted from Forth in 2010, from Coldfusion in 2013. All rights reserved.
psychostochastics - supersynthesis - humanized uniform random distributions 
------------------------------------------------------------------------------
"""
 
name 		= "rndpy"
comment 	= ''
start      = 0
duration   = 0
scale 	= 1 
events	= 1600   
maxfreq 	= 7.5 
minfreq 	= 5	
maxdur  	= 30	
mindur  	= 0.1
attack  	= 50
at         = 50 
attack2 	= 50
at2        = 50 
release 	= 1
release2	= 1
maxdb	 	= 96
mindb	 	= 36
panStart	= 1
panEnd	= 1
total      = 900*4	
revSend 	=  0.3
filter	=  16
revTime 	=  0.9
prnd       =  7

# orchestra --->
orchestra = r'''
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
ipanStart 		= p8    		; Start of Pan (0-1 = left to right)
ipanEnd   		= p9    		; End of Pan
ifilter			= p10   		; Originally the Width of Notch Filter, here used as a waveform selection tool
irevSend  		= p11   		; Reverb Amount
iprnd           = p12   		; general rnd number
iat2      		= p13    		; Attack portion of the AR modulation envelope 
irel2     		= p14   		; Release portion of the AR modulation envelope         
   
kpan    linseg  ipanStart, idur, ipanEnd   
kAmpEnv linseg  0, iat,  iamp, irel,  0 
kModEnv linseg  0, iat2, iamp, irel2, 0
kOsc    oscil3  iamp*0.00033, .15, 1

; ifreq = ifreq+(ifilter*10)
	 
a2      oscil3  kModEnv/iprnd*0.01, ifreq, ifilter
a4      oscil3  kAmpEnv,      (ifreq+a2)   , ifilter
a1 =	a4  ; + a3

outs    a1 *  kpan, a1 * (1 - kpan)

galeft    =         galeft  +  a1*kpan     * irevSend
garight   =         garight +  a1*(1-kpan) * irevSend

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

'''         

# score 
def RndFreq(): return random.uniform(minfreq,maxfreq)

def RndEnvelope(): 
    global start   
    start = random.uniform(0,total)
    global duration 
    duration = random.lognormvariate(1,0.9)
    global at   
    at =  attack*duration/100    # % of duration
    at   = random.uniform(0,at)
    global at2  
    at2 =  attack2*duration/100 
    at2  = random.uniform(0,at2)  
    global release 
    release = duration - at
    global release2 
    release2 = duration - at2
    if release < 0.1:
        duration = duration + 0.1
        release =  0.1

def GenerateEnvelope():
    RndEnvelope()     
    while start + duration > total: 
        RndEnvelope() 

def RndDb(): return   random.uniform(mindb,maxdb)

def RndpanStart(): return   random.uniform(0,panStart) 

def RndpanEnd(): return random.uniform(0,panEnd)

def RndrevSend(): return random.uniform(0,revSend)

def RndfilterWidth(): return int( random.uniform(1,filter) ) 
    
def RndPitch(): return int( random.uniform(0,1) * 7 )


# <!--- ============= scoreHeader ==================--->
scoreHeader = ""

for i in range(1,17):
    scoreHeader += "f" + `i` + " 0 65536 10 " + \
    `round(random.uniform(0,1), 3)` + " \r"

scoreHeader += '''
; Reverb
; ins     strt dur                					revTime                 
  i99     0    #Evaluate(total+revTime*3)# #revTime#

;++..time02....dur03....amp04...freq05.attack06....rel07...panS08...panE09.filter10.revSen11...gRnd12.attack13...relE14
'''

#<!--- ============= scoreData ==================--->
import MySQLdb
db = MySQLdb.connect(host="127.0.0.1", user="root", passwd="@", db="IFORMM")
c = db.cursor()

# <!--- kill/ --->
del_P = ("DELETE FROM P") 
add_P = ("INSERT into P (p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15) "
         "VALUES        (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)")
# <!--- gen/ --->
c.execute(del_P)


for i in range(events):
    GenerateEnvelope()
    data_P = (start,duration,RndDb(),RndFreq(),at,release,RndpanStart(),
              RndpanEnd(),RndfilterWidth(),RndrevSend(),RndPitch(),at2,release2)    
    c.execute(add_P,data_P)
    



get_data = ("SELECT * FROM P"  
            "WHERE p5 > 0"
            "ORDER BY p3")  

c.execute(get_data)

db.commit()
c.close()
db.close()

'''
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



