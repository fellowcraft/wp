
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
 
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

gklfo      oscil3  30, 0.005, 1 

endin


instr 1
idur     		= p3     		; total duration of event
iamp     		= p4*0.8 		; amplitude in dB: 0-96
ifreq    		= cpsoct(p5)    ; decimal octaves: 1.00-12.000
iat      		= p6    		; Attack portion of the AR amplitude envelope 
irel     		= p7    		; Release portion of the AR amplitude envelope                       
								; NOTE: probability is computed for the attack portion, the envelope is:
								; idur - iat = irel 
								; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    		; Start of Pan (0-1 = left to right)
ipanend   		= p9    		; End of Pan
ifilterwidth	= p10   		; Originally the Width of Notch Filter, here used as a uniform random number 1-100
irevsend  		= p11   		; Reverb Amount
iprnd           = p12   		; general rnd number

   
   kpan    linseg  ipanstart, idur, ipanend             ; panning 0.0-1.0 
                                                         
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      oscil3  2, 0.00005, 1
	 
	a2      oscil3 k1*0.001, ifilterwidth*iprnd+k2, 1 ; int(ipanstart*3.9)+1
	
	a4      oscil3 k1,       (ifreq+a2)     , int(ifilterwidth/29)+1
	a40 	lowpass2 a4, ifreq     +k2+k1, 0.3
	
	a3      oscil3 k1*0.8,  (ifreq+a2)*iprnd, int(ifilterwidth/29)+1
    a30 	lowpass2 a3, ifreq*2.01+k2+k1, 0.3

	a3b     oscil3 k1*0.1,  (ifreq+a2)*iprnd, int(ifilterwidth/29)+1
	a30b 	clfilt a3b, 120, 1, 40

	a3c     oscil3 k1*0.4,  (ifreq+a2)*iprnd, int(ifilterwidth/29)+1
		
    a1  =   a40 + a30b + a30 + a3c

	outs    a1 *  kpan, a1 * (1 - kpan)
    galeft    =         galeft  +  a1*kpan     * irevsend
    garight   =         garight +  a1*(1-kpan) * irevsend
endin

instr 99                 ; global reverb
     irvbtime    =         p4 
;     aleft        reverb    galeft,  irvbtime
;     aright       reverb    garight, irvbtime 
;     outs  aleft, aright 
      aleft,  aleft reverbsc   galeft,  galeft, irvbtime, 12000, sr, 0.5, 1 
     aright, aright reverbsc  garight, garight, irvbtime, 12000, sr, 0.5, 1 
     outs  aright, aleft
     galeft    =    0              ; then clear it
     garight   =    0 
endin 

         

</CsInstruments>
<CsScore>

;  16000 events - total 3600 seconds"
;  6.5 - 8.5 Hz     
;  36.0 - 96.0 dB

   f1 0 65536 10 1 .1                                                     ; Sine     .
   f2 0 65536 10 1 .5 .25 .2 .15 .2 .1 .05 .01                            ; Sawtooth ++
   f3 0 65536 10 1  0  .5  0  .2  0  .2  0  .015  0  .005                 ; Square   +++
   f4 0 65536 10 1 .9 .8 .7                                               ; Pulse    +

; Reverb
; ins     strt dur                					revTime                 
  i99     0    3600.85 .85

;++....time......dur......amp.....freq...attack......rel.....panS.....panE.filterwi..revSend

i1    0.045    1.578   68.107    8.256    0.023    1.555    0.588    0.926   27.722    0.077    4.657 ;   1 













































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































