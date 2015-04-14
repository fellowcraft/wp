
<CsOptions>
</CsOptions>
<CsInstruments>
 
  
; sr =  48000
; kr =   4800	    
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
idur     		= p3    ; total duration of event
iamp     		= p4*1  ; amplitude in dB: 0-96
ifreq    		= p5    ; frequency in Hz: 20-20000 (depending on sr (sample rate)) 
iat      		= p6    ; Attack portion of the AR amplitude envelope 
irel     		= p7    ; Release portion of the AR amplitude envelope                       
				; NOTE: probability is computed for the attack portion, the envelope is:
				; idur - iat = irel 
				; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    ; Start of Pan (0-1 = left to right)
ipanend   		= p9    ; End of Pan
ifilterwidth	        = p10   ; Originally the Width of Notch Filter, here used as a uniform random number 1-100
irevsend  		= p11   ; Reverb Amount
iup                     = 0.5
   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
  ; klfo    
                                                        
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      poscil  k1, 0.03, 1,
	
           
 
	a2      poscil iamp*iup, ifilterwidth*0.3, 1 ; int(ipanstart*3.9)+1
	             
	a4      poscil k1,       (ifreq)     , int(ifilterwidth/29)+1
	a40 	lowpass2 a4*a2*iup,  ifreq    +k2, .5
	 
	a3      poscil k1*0.08,  (ifreq)*2.01, int(ifilterwidth/29)+1
        a30 	lowpass2 a3+a2,  ifreq*2.01+k2, .5

	a3b     poscil k1*0.01,  (ifreq)*0.51, int(ifilterwidth/29)+1
	a30b 	clfilt a3b+a2, 120, 1, 40

	a3c     poscil k1*0.004,  (ifreq)*4.02, int(ifilterwidth/29)+1
		
         a1  =  a40 + a30b + a30 + a3c

    outs     a1 *  kpan, a1 * (1 - kpan)
 
   garight    =       galeft  +  a1*kpan     * irevsend 
   galeft     =       garight +  a1*(1-kpan) * irevsend
endin

instr 99                 ; global reverb
;-------
irvbtime    =         p4 
aleft,  aleft  reverbsc  galeft,  galeft, irvbtime, 12000, sr, 0.7, 1 
aright, aright reverbsc  garight, garight,irvbtime, 12000, sr, 0.7  1 
outs  aleft, aright
galeft    =    0
garight   =    0 

endin 

         

</CsInstruments>
<CsScore>

;  18000 events - total 3600 seconds"
;  50.0 - 800.0 Hz     
;  36.0 - 96.0 dB

   f1 0 65536 10 1                                                        ; Sine     .
   f2 0 65536 10 1 .5 .25 .2 .15 .2 .1 .05 .01                            ; Sawtooth ++
   f3 0 65536 10 1  0  .5  0  .2  0  .2  0  .015  0  .005                 ; Square   +++
   f4 0 65536 10 1 .9 .8 .7                                               ; Pulse    +

; Reverb
; ins     strt dur                					revTime                 
  i99     0    3600.85 .85

; Osc	start	dur	amp	freq	attack	rel	panS	panE 	filterwidth		revSend

i1	0.116 2.141 76.0 67.4 0.724 1.417 0.69 0.5 98 0.8 
i1	0.277 1.592 -1.1 236.2 1.545 0.047 0.98 0.09 97 0.1 

