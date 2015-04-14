<CsoundSynthesizer>

<CsOptions>
; XO
-+rtmidi=portmidi -M1 -odac -r44100 -k441
; Mac
;-odac0 -+rtmidi=PortMIDI -M1

</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 256
nchnls = 2

cpuprc 1, 2

gisin    ftgen    1, 0, 16384, 10, 1
; wavetable for distortion
gifn ftgen 0,0, 257, 9, .5,1,270,1.5,.33,90,2.5,.2,270,3.5,.143,90,4.5,.111,270

         ctrlinit 1, 73,64, 72,64

instr    1
           ; Scale the amplitude to 32768.
iscale = 0dbfs

iamp     ampmidi  0dbfs
icps     cpsmidi

kfiltfrq    midic7  14,100,2000
kfiltres    midic7  15,.1,1
kreslofreq    midic7   16,20,500
kreshifreq    midic7   17,0,5000
kresonz    midic7   18,1,100
kdistlevel   midic7   19,0,100

imastervol   midic7   29,0,1

kfrqmod       madsr   .1,.3,.5,.2
kampenv     madsr   .01, .2, .6, .5
aosc        vco     kampenv, icps, 1

afilt    moogvcf  aosc, 50+kfiltfrq*kfrqmod, kfiltres, iscale

; hi-pass filter
ahipass  atone afilt, kreshifreq

; lo-pass filter
alopass    rezzy ahipass, kreslofreq, kresonz

; distortion
ar distort alopass, kdistlevel, gifn

         out      ar*iamp, ar*iamp
         endin
          
</CsInstruments>

<CsScore>
f0 360
</CsScore>

</CsoundSynthesizer>
