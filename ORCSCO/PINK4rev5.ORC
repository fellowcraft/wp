; sr = 48000
; kr =  4800
sr = 44100
kr =  4410
ksmps = 10
nchnls = 2
galeft init 0
garight init 0

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

   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
                                                         
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
   k2      lfo 30, 0.005, 0
	
/*	
   vibrato, very slight with the same envelope than the volume
*/
	
	a2      oscili k1*0.0001, ifilterwidth*0.05+k2, 1 ; int(ipanstart*3.9)+1
	
;	aLowFreq  =  120;
;	aHalfFreq =  (ifreq+a2)*0.51*0.5
;	aLP max aHalfFreq, aLowFreq
	
	a3      oscili k1*0.09,  (ifreq+a2)*2.01*0.5 , int(ifilterwidth/29)+1
	a3b     oscili k1*0.1,   (ifreq+a2)*0.51*0.5, int(ifilterwidth/29)+1
	a3c     oscili k1*0.04,  (ifreq+a2)*4.02*0.5 , int(ifilterwidth/29)+1
	
	a4      oscili k1,       (ifreq+a2)     *0.5 , int(ifilterwidth/29)+1
	              	    
    a30 lowpass2 a3, ifreq*2.01+k2+k1, 0.3
	a40 lowpass2 a4, ifreq     +k2+k1, 0.3
    
	a30b clfilt a3b, 120, 1, 40

    a1  =   a30b + a30 + a40

	outs    a1 *  kpan, a1 * (1 - kpan)
    galeft    =         galeft  +  a1*kpan     * irevsend/6
    garight   =         garight +  a1*(1-kpan) * irevsend/6
endin

instr 99                 ; global reverb
     irvbtime    =         p4 
     aleft        reverb    galeft,  irvbtime
     aright       reverb    garight, irvbtime 
     outs  aright, aleft
     galeft    =    0              ; then clear it
     garight   =    0 
endin 

         
