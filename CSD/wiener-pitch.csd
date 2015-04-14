sr = 96000
kr =  9600
;sr = 48000
;kr =  4800
;sr = 44100
;kr =  4410
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
iamp     		= p4*0.9 ; amplitude in dB: 0-96
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

   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
                                                         
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      oscil3  30, 0.005, 1,
	
/*	
   vibrato, very slight with the same envelope than the volume
*/
 
	a2      oscil3 k1*0.00006, ifilterwidth*0.03+k2, 1 ; int(ipanstart*3.9)+1
	
;	aLowFreq  =  120;
;	aHalfFreq =  (ifreq+a2)*0.51*0.5
;	aLP max aHalfFreq, aLowFreq
	
	
	a4      oscil3 k1,       (ifreq+a2)     , int(ifilterwidth/29)+1
	a40 	lowpass2 a4, ifreq     +k2+k1, 0.3
	
	a3      oscil3 k1*0.1,  (ifreq+a2)*2.01, int(ifilterwidth/29)+1
    a30 	lowpass2 a3, ifreq*2.01+k2+k1, 0.3

	a3b     oscil3 k1*0.01,  (ifreq+a2)*0.51, int(ifilterwidth/29)+1
	a30b 	clfilt a3b, 120, 1, 40

	a3c     oscil3 k1*0.006,  (ifreq+a2)*4.02, int(ifilterwidth/29)+1
		
    a1  =   a40 + a30b + a30 + a3c

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

