<CsoundSynthesizer>
<CsOptions>
-+rtmidi=portmidi -Ma -odac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

        massign   0, 1 ;assign all MIDI channels to instrument 1
giSine  ftgen     0,0,2^10,10,1 ;a function table with a sine wave

instr 1

iat  = 0.002
irel = 10
 
iAmp    ampmidi  0dbfs * 0.2           		;get the amplitude
k1      linseg  0, iat, iAmp, irel, 0       ;make non-clicking envelope

iCps    cpsmidi   ;get the frequency from the key pressed

aOut    poscil    k1, iCps, giSine 		;generate a sine tone
        outs      aOut, aOut 				;write it to the output
endin

</CsInstruments>
<CsScore>
e 3600
</CsScore>
</CsoundSynthesizer>