#!/usr/bin/python
import random
import datetime

""" 
Copyright (c) 1987-2013 by Frank Holger Rothkamm. Forth/Coldfusion/Python
psychostochastics - supersynthesis - humanized uniform random distributions 
------------------------------------------------------------------------------
"""
orchestra = '''

sr = 41000
kr =  4100
ksmps = 10
nchnls = 2
galeft init 0
garight init 0

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
    `round(random.uniform(0,1), 3)` + " " + \
    `round(random.uniform(0,1), 3)` + " " + \
    `round(random.uniform(0,1), 3)` + " " + \
    `round(random.uniform(0,1), 3)` + " " + \
    `round(random.uniform(0,1), 3)` + " " + \
    `round(random.uniform(0,1), 3)` + \
    " \n"

scoreHeader +=  ("; Reverb , LFO \n"
"i99     0 " + `total+revTime*3` + "   " + `revTime` + " \n"
"i2      0 " + `total+revTime*3` + " \n"
"\n \n")


scoreData = ""

for i in range(events):
	GenerateEnvelope()
	scoreData += "i1 " + \
	" %4.3f" % start + \
	" %4.3f" % duration + \
	" %4.3f" % RndDb() + \
	" %4.3f" % RndFreq() + \
	" %4.3f" % at + \
	" %4.3f" % release + \
	" %4.3f" % RndpanStart() + \
	" %4.3f" % RndpanEnd() + \
	" %4.3f" % RndfilterWidth() + \
	" %4.3f" % RndrevSend() + \
	" %2.0f" % RndPitch() + \
	" %4.3f" % at2 + \
	" %4.3f" % release2 + "\n"


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
