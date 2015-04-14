#!/usr/bin/python
import random
import datetime
import os

scriptname = os.path.basename(__file__)

""" 
Copyright (c) 1987-2013 by Frank Holger Rothkamm. Forth/Coldfusion/Python
psychostochastics - supersynthesis - humanized uniform random distributions 
------------------------------------------------------------------------------
"""
orchestra = '''

sr = 48000
kr =  4800
ksmps = 10
nchnls = 2
galeft init 0
garight init 0

instr 2
gklfo	oscil3  500, 1/180, 1
endin

instr 1
idur     		= p3
iamp     		= ampdb(p4)
ifreq    		= cpsoct(p5)
iat      		= p6
irel     		= p7
ipanStart 		= p8
ipanEnd   		= p9
ifilter			= p10
irevSend  		= p11
iprnd           	= p12
iat2      		= p13
irel2     		= p14

kpan    linseg  ipanStart, idur, ipanEnd
kAmpEnv linseg  0, iat,  iamp, irel,  0
kModEnv linseg  0, iat2, iamp, irel2, 0

a2      oscil3  kModEnv*0.005+gklfo,ifreq*iprnd,ifilter
a1      oscil3  kAmpEnv,ifreq+a2,ifilter

outs    a1 *  kpan, a1 * (1 - kpan)

galeft    =         galeft  +  a1*kpan     * irevSend
garight   =         garight +  a1*(1-kpan) * irevSend

endin

instr 99                           ; global reverb

irvbtime    =         p4 
aleft,  aleft  reverbsc  galeft,  galeft, irvbtime, 18000, sr, 0.8, 1 
aright, aright reverbsc  garight, garight,irvbtime, 18000, sr, 0.8, 1 
outs   aright,   aleft              
galeft    =    0
garight   =    0 

endin 

'''         

# now = datetime.datetime.now()
  
# score 
# name 		= scriptname # + now.strftime("%Y%m%d")
start      	= 0
duration   	= 0
events		= 1600*1*8
minfreq 	= 7
devfreq 	= 1	
attack  	= 95
attack2 	= 50
maxdb	 	= 80
mindb	 	= 10
panStart	= 1
panEnd		= 1
total      	= 900*1
revSend 	= 0.3
filTer		= 7 
revTime 	= 0.9
prnd       	= 7


def RndFreq(): return random.gauss(minfreq,devfreq)

def RndEnvelope():
	global start
	#start = random.uniform(0,total)
	start = abs(random.gauss(total/2,total/5))
	global duration
	duration = max(random.gammavariate(0.4,0.3),0.1)
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
	if release < 0.01:
		duration = duration + 0.01
		release =  0.01

def GenerateEnvelope():
    RndEnvelope()     
    while start + duration > total: 
        RndEnvelope()

def RndDb():          return random.uniform(mindb,maxdb)

def RndpanStart():    return random.uniform(0,panStart)

def RndpanEnd():      return random.uniform(0,panEnd)

def RndrevSend():     return random.uniform(0,revSend)

def RndfilterWidth(): return random.randint(1,filTer)

def RndPitch():       return random.randint(1,7)

scoreHeader = "f1 0 65536 10 1 \n"

for i in range(2,8):
    scoreHeader += ("f" + `i` + " 0 65536 10 " +
    `round(random.uniform(0,1), 3)` + " " +
    `round(random.uniform(0,1), 3)` + " " +
    `round(random.uniform(0,1), 3)` + " " +
    `round(random.uniform(0,1), 3)` + " " +
    `round(random.uniform(0,1), 3)` + " " + 
    `round(random.uniform(0,1), 3)` +
    " \n")

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
	" %1.0f" % RndfilterWidth() + \
	" %4.3f" % RndrevSend() + \
	" %1.0f" % RndPitch() + \
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

scorename = scriptname + ".csd"
i = 0
while os.path.isfile(scorename):
	i = i + 1
	scorename = scriptname + "." + `i` + ".csd"

f = open(scorename, 'w')
f.write(csd)
print scorename
