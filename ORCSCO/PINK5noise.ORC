; sr = 48000
; kr =  4800
sr = 44100
kr =  4410
ksmps = 10
nchnls = 2
galeft init 0
garight init 0
; gklfo init 0


; instr 2

; gklfo      oscil3  30, 0.005, 1 

; endin


instr 1
idur     		= p3    ; total duration of event
iamp     		= p4*0.82 ; amplitude in dB: 0-96
ifreq    		= p5    ; frequency in Hz: 20-20000 (depending on sr (sample rate)) 
iat      		= p6    ; Attack portion of the AR amplitude envelope 
irel     		= p7    ; Release portion of the AR amplitude envelope                       
						; NOTE: probability is computed for the attack portion, the envelope is:
						; idur - iat = irel 
						; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    ; Start of Pan (0-1 = left to right)
ipanend   		= p9    ; End of Pan
ifilterwidth	= p10   ; Originally the Width of Notch Filter, here used as a uniform random number 1-100
irevsend  		= p11   ; Reverb Amount

   awhite unirand 2.0
   awhite = awhite - 1.0
   
   iArrow =  ((ipanstart + ipanend) * 0.5) + 0.5  
   
   print iArrow
   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
   kasc    linseg  ifreq, idur, ifreq*iArrow
                                                         
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      oscil3  50, 0.05, 1
   
   

	
/*	
   vibrato, very slight with the same envelope than the volume
*/
 		
;	a4      oscil3 k1,       (ifreq+a2)     , int(ifilterwidth/29)+1
;	a40 	lowpass2 p4, ifreq     +k2+k1, 0.3
   
    asig    pinkish awhite, 1, 0, 0, 1
    a2      butterbp asig*k1, ifreq, ifilterwidth*30+k2
    a1      clfilt a2, kasc, 1, 40
		
;    a1  =   a40 + a30b + a30 + a3c

	outs    a1 *  kpan, a1 * (1 - kpan)
    galeft    =         galeft  +  a1*kpan     * irevsend/5.7
    garight   =         garight +  a1*(1-kpan) * irevsend/5.7
endin

instr 99                 ; global reverb
     irvbtime    =         p4 
     aleft        reverb    galeft,  irvbtime
     aright       reverb    garight, irvbtime 
     outs  aright, aleft
     galeft    =    0              ; then clear it
     garight   =    0 
endin 

         
