<CFCOMPONENT >


<cfscript>
function RandR(x,y) {

if(y LT x) z = x-y; else z = y-x;  //Throw(type="InvalidData",message="y must be GT x"); 

result =  z * RAND("SHA1PRNG") + x ;  

return result;
}


function loga() {
	
result = log(RAND()); // / lambda;

return abs(result);
}


function grnd2(a,b) {

result = RandRange(a,b,"SHA1PRNG");
return result; 
}


// x =  2^10;
// freq = 0;
// Irwin–Hall Normal Distribution 
// For (i=1;i LTE 12; i=i+1) {
// freq  = freq + RandRange(minfreq*scale,maxfreq*scale,"SHA1PRNG");
// }
// freq = freq - 6*maxfreq*scale;
// range = maxfreq*scale - minfreq*scale;  


</cfscript>

</CFCOMPONENT>



