<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	44100
ksmps	=	1
nchnls	=	2
0dbfs	=	1

gisine ftgen 1, 0, 4096, 10, 1

instr 1
iamp = p4
a1 rand iamp 
aenv expseg 1, p3, 0.001
outs a1*aenv, a1*aenv
endin

instr 2	
iamp = p4
a1 rand iamp 
aenv linseg 1, p3, 0.001
outs a1*aenv, a1*aenv
endin

instr 3	
iamp = p4
ifrq = p5
a1 foscil iamp, ifrq, 1, 1, 40000, 1
aenv expseg 1, p3, 0.001
outs a1*aenv, a1*aenv
endin

instr 4	
iamp = p4
ifrq = p5
a1 foscil iamp, ifrq, 1, 1, 40000, 1
aenv linseg 1, p3, 0.001
outs a1*aenv, a1*aenv
endin


</CsInstruments>
; ==============================================
<CsScore>

;linear vs exponential white noise

i1 0 .3 .2 

i2 1 .3 .2 

;longer
i1 2 .5 .2

i2 3 .5 .2


;lin/exp FM noise

i3 4 .3 .2 100

i4 5 .3 .2 100

;lower frequency 

i3 6 .3 .2 10

i4 7 .3 .2 10

;longer FM noise

i3 8 .7 .2 100

i4 9 .7 .2 100

i3 10 .7 .2 10

i4 11 .7 .2 10

</CsScore>
</CsoundSynthesizer>
