<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

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
	
	a2      oscili k1*0.1, ifilterwidth*0.05+k2, 1 ; int(ipanstart*3.9)+1
	
	a3      oscili k1*0.09,  (ifreq+a2)*2.01*0.5 , int(ifilterwidth/29)+1
	a4      oscili k1,       (ifreq+a2)     *0.5 , int(ifilterwidth/29)+1
	              	    
    a30 lowpass2 a3, ifreq*2.01+k1+k2, 0.3
	a40 lowpass2 a4, ifreq     +k1+k2, 0.3

    a1  =   a30 + a40 

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

         
</CsInstruments>
<CsScore>

   f1 0 65536 10 1 .1                                                     ; Sine     .
   f2 0 65536 10 1 .5 .25 .2 .15 .2 .1 .05 .01                            ; Sawtooth ++
   f3 0 65536 10 1  0  .5  0  .2  0  .2  0  .015  0  .005                 ; Square   +++
   f4 0 65536 10 1 .9 .8 .7                                               ; Pulse    +
 
; Reverb
; ins     strt dur                revTime                 
  i99     0    7 5

;   st	dur		amp		freq	attack	rel		panS	panE 	fw		revSend

i1 	1	8.379	92.3	1800	0.240	7.139	0.10	0.67	 1  	0.8 
;i1 	3	5.379	92.3	1800	0.240	4.139	0.40	0.67	 40  	0.8 		
;i1 	4	5.379	92.3	1800	0.240	4.139	0.60	0.67	 60  	0.8 	
;i1 	2	5.379	92.3	1800	0.240	4.139	0.89	0.67	 99  	0.8 	

;i1 	3	3.542	80.4	862.7	0.003	3.539	0.64	0.26	 43  	0.2 	
;i1 	4	1.747	86.7	335.1	0.446	1.301	0.37	0.93	 37  	0.6
;i1 	5	3.067	80.4	185.6	1.198	1.869	0.89	0.21	 28  	0.1 	 	
;i1 	6	1.329	87.3	50 		0.545	0.784	0.77	0.39	 72  	0.4 
e
</CsScore>
</CsoundSynthesizer>