<CsoundSynthesizer>
<CsOptions>
; -odac6 -Ma -d -r48000 -k480
</CsOptions>
<CsInstruments> 
; MIDI subtractive synthesizer 
; Victor Lazzarini, 1998 
;  
; takes the oscillator frequency from  
; MIDI note + pitch bend messages,  
; amplitude from MIDI velocity and 
; filter frequency from modulation wheel 
 sr = 44100   
 kr = 441 
 ksmps = 100 
 nchnls = 1  
   
instr 1 
iq = 50                 ; filter Q  
ifmin = 400             ; min filter freq 
ifmax = 4000            ; max filter freq 
iamp ampmidi  0dbfs ; amplitude (scaled from 0 – 0dbfs, which is set 
                     ;                   to 32767 by default) 
kcps  cpsmidib 2     ; cps + pitch bend (range = 2 semitones) 
kmod  midictrl 1     ; modulation control   
                          
; scale MIDI modulation values (between ifmin and ifmax) 
; using a logarithmic (equal-interval) scale 
kmod   =  ifmin + (ifmax - ifmin)*(powoftwo(kmod/127) - 1) 
kmp linenr  iamp, .05, .5, .01     ; envelope  
a1 oscil kmp, kcps, 1            ; oscillator  
aout  reson   a1, kmod, kmod/iq, 1 ; filter  
 out  aout 
   
      endin
</CsInstruments> 
<csScore>
; midisynth.sco 
; function table initialisation  
; oscillator wave 

f1 0 1024 10 1 .8 .7 .6 .5 .4 .3 .2 .1 .08 .07 .06 .05 .04 .03 .02   

; listen to MIDI for 600 secs (10 minutes) 
f0 600   
e
</CsScore>
</CsoundSynthesizer>