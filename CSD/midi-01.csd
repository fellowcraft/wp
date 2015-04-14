<CsoundSynthesizer>
<CsOptions>
-odac -Ma -d -r48000 -k48000
</CsOptions>
<CsInstruments>
nchnls	=	2
; 0dbfs                   =                       32000

massign 1, 222

ctrlinit 1, 13,100, 14,10, 15,2, 16,5, 17,1, 18,1

instr	222

ifmin = 1
ifmax = 100  

icps	cpsmidi

iamp    ampmidi 0dbfs * 0.2

; iampS = ifmin + (ifmax - ifmin)*(powoftwo(iamp/127) - 1) 

iampC	midic7	13, 0, 10000
kcar	midic7	14, 0, 10
kmod	midic7	15, 0, 10

iattack   	 midic7  17, 0.001, 0.5
idecay	     midic7  18, 0.1, 4


kindx	midic7	16, 0, 20



amgate	linsegr	0.001, iattack, iamp, idecay, 0.001

iRndPitch random 1, 1.1
asig	foscil	amgate, icps*iRndPitch, (kcar), (kmod), kindx, 1

; a1 moogvcf2 asig, kfco, krez

ipan    random 0, 1
outs    asig * ipan, asig * (1 - ipan)


endin
</CsInstruments>
<CsScore>
f1	0	8192	10	1
f2  0 1024 7 	-1 1024 1
f0	3600
</CsScore>
</CsoundSynthesizer>