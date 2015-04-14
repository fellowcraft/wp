#!/usr/bin/python
import random
import datetime
import MySQLdb
db = MySQLdb.connect(host="127.0.0.1", user="root", passwd="@", db="IFORMM")

""" 
Copyright (c) 1987-2013 by Frank Holger Rothkamm. Forth/Coldfusion/Python
psychostochastics - supersynthesis - humanized uniform random distributions 
------------------------------------------------------------------------------
"""
# orchestra --->
orchestra = '''

sr = 41000
kr =  4100
ksmps = 10
nchnls = 2
galeft init 0
garight init 0

; This oscillator sweeps over the longest possible period, 0.00025 sec.
; larger values produce 0 value.

instr 2
gklfo	oscil3  1000, 1/3933, 1 
endin

instr 1
idur     		= p3             ; total duration of event
iamp     		= ampdb(p4)      ; amplitude in dB: 0-96
ifreq    		= cpsoct(p5)     ; decimal octaves: 1.00-12.000
iat      		= p6             ; Attack portion of amplitude env
irel     		= p7             ; Release portion of amplitude env
ipanStart 		= p8             ; Start of Pan (0-1 = left to right)
ipanEnd   		= p9             ; End of Pan
ifilter			= p10            ; Filter / waveform selection tool
irevSend  		= p11            ; Reverb Amount
iprnd           	= p12            ; general rnd number
iat2      		= p13            ; Attack portion of modulation env
irel2     		= p14            ; Release portion of modulation env
   
kpan    linseg  ipanStart, idur, ipanEnd   
kAmpEnv linseg  0, iat,  iamp, irel,  0 
kModEnv linseg  0, iat2, iamp, irel2, 0
;kOsc    oscil3  iamp*0.00033,  .15,   1

a2      oscil3  kModEnv*0.1+gklfo,ifreq*iprnd       ,ifilter  
a1      oscil3  kAmpEnv,          (iprnd/3)*ifreq+a2,1

outs    a1 *  kpan, a1 * (1 - kpan)

galeft    =         galeft  +  a1*kpan     * irevSend * 1.2
garight   =         garight +  a1*(1-kpan) * irevSend * 1.2

endin

instr 99                           ; global reverb

irvbtime    =         p4 
aleft,  aleft  reverbsc  galeft,  galeft, irvbtime, 18000, sr, 0.5, 1 
aright, aright reverbsc  garight, garight,irvbtime, 18000, sr, 0.5, 1 
outs   aright,   aleft              
galeft    =    0
garight   =    0 

endin 

'''         

now = datetime.datetime.now()

  
# score 
name 		= "rnd" + now.strftime("%Y%m%d")
start      	= 0
duration   	= 0
events		= 1600*1*1
minfreq 	= 7
devfreq 	= 1	
attack  	= 90
attack2 	= 50
maxdb	 	= 80
mindb	 	= 10
panStart	= 1
panEnd		= 1
total      	= 900*4
revSend 	= 0.3
filter		= 16
revTime 	= 0.9
prnd       	= 7


def RndFreq(): return random.uniform(minfreq,devfreq)

def RndEnvelope():
	global start
	start = random.uniform(0,total)
	global duration
	duration = random.lognormvariate(5,4.9)
	global at   
	global attack
	at  =  random.uniform(0,attack*duration/100)
	global at2 
	global attack2 
	at2 =  random.uniform(0,attack2*duration/100)  
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

def RndDb():          return random.uniform(mindb,maxdb)

def RndpanStart():    return random.uniform(0,panStart) 

def RndpanEnd():      return random.uniform(0,panEnd)

def RndrevSend():     return random.uniform(0,revSend)

def RndfilterWidth(): return int( random.uniform(1,filter) )

def RndPitch():       return int( random.uniform(0,1) * 7 )

scoreHeader = ""

for i in range(1,17):
    scoreHeader += "f" + `i` + " 0 65536 10 " + \
    `round(random.uniform(0,1), 3)` +  " " + `round(random.uniform(0,1), 3)` + " " +  \
    `round(random.uniform(0,1), 3)` +  " " + `round(random.uniform(0,1), 3)` +  " " + \
    `round(random.uniform(0,1), 3)` +  " " + `round(random.uniform(0,1), 3)` + \
    " \n"

scoreHeader +=  ("; Reverb \n"
"; ins     strt dur               revTime \n"
"i99     0 " + `total+revTime*3` + "   " + `revTime` + " \n"
"i2      0 " + `total+revTime*3` + " \n"
"\n \n")

del_P = ("DELETE FROM P") 
add_P = ("INSERT into P (p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15) "
         "VALUES        (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)")
with db:
    c = db.cursor()
    c.execute(del_P)

for i in range(events):
    GenerateEnvelope()
    data_P = (start,duration,RndDb(),RndFreq(),at,release,RndpanStart(),         #1-7       
              RndpanEnd(),RndfilterWidth(),RndrevSend(),RndPitch(),at2,release2) #8-13    
    c.execute(add_P,data_P)
    
get_data = ("SELECT p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15 FROM P "  
            "WHERE p5 > 0 "
            "ORDER BY p3")  

c.execute(get_data)

row = c.fetchone()

scoreData = ""

for row in c:
    scoreData += "i1 " + \
" %4.3f" % row[0] + \
" %4.3f" % row[1] + \
" %4.3f" % row[2] + \
" %4.3f" % row[3] + \
" %4.3f" % row[4] + \
" %4.3f" % row[5] + \
" %4.3f" % row[6] + \
" %4.3f" % row[7] + \
" %4.3f" % row[8] + \
" %4.3f" % row[9] + \
" %4.0f" % row[10] + \
" %4.3f" % row[11] + \
" %4.3f" % row[12] + "\n"

db.commit()
c.close()
db.close()

csd = ""

csd += ("<CsoundSynthesizer> \n" 
"<CsOptions> \n"
"</CsOptions> \n"
"<CsInstruments> \n" 
+ orchestra +
"</CsInstruments> \n"
"<CsScore> \n" 
+ scoreHeader
+ scoreData +
"e \n"
"</CsScore> \n"
"</CsoundSynthesizer>")

f = open(name+ ".csd", 'w')
f.write(csd)
