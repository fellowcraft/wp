<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
</head>


<cfscript>
 
rnd = 1;

function expo(lambda) {
	
result = log(RAND()) / lambda;
// result = RAND() * rnd;
return abs(result);
}



// public static double nextCauchy(RandomEngine randomGenerator) {
//	return Math.tan(Math.PI*randomGenerator.raw());
// }

function cauchy() {
	
result = tan(PI()*RAND());
// result = RAND() * rnd;
return result;
}



</cfscript>

<cfchart FORMAT="PNG" CHARTWIDTH="1000">

<cfchartseries TYPE="SCATTER">
<cfloop from="1" to="1000" index="i">

<cfset x = RAND() * rnd>

<cfchartdata ITEM="#i#" VALUE="#x#">
</cfloop>

</cfchartseries>
</cfchart>

<br />

<cfchart FORMAT="PNG" CHARTWIDTH="1000">

<cfchartseries TYPE="SCATTER">
<cfloop from="1" to="1000" index="i">

<cfset x = expo(2.5) * rnd>

<cfchartdata ITEM="#i#" VALUE="#x#">
</cfloop>

</cfchartseries>
</cfchart>

<br />

<cfchart FORMAT="PNG" CHARTWIDTH="1000">

<cfchartseries TYPE="SCATTER">
<cfloop from="1" to="1000" index="i">

<cfset x = cauchy() * rnd>

<cfchartdata ITEM="#i#" VALUE="#x#">
</cfloop>

</cfchartseries>
</cfchart>



<body>
</body>
</html>