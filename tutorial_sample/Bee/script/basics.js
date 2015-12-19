/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

function isString(expression)
{
	return (typeof expression == "string" || expression instanceof String) ? true : false;
}

function isNumeric(expression)
{
	return (typeof expression == "number" || expression instanceof Number) ? true : false;
}

function isArray(expression)
{
	return (typeof expression == "array" || expression instanceof Array || typeof expression == "object") ? true : false;
}

// Doesn't work for associative arrays
function print_r(expression)
{	
	if(isString(expression) || isNumeric(expression))
	{
		document.write(expression);
		return true;
	}
	else if(expression instanceof Array)
	{
		if(expression.length == 0)
		{
			document.write("Array( )");
			return true;
		}
		else
		{
			document.write("Array(");
			for(var i=0; i<expression.length; i++) // trebuie declarat cu var, ca sa fie reinit. la fiecare recurenta
			{
				document.write(" [" + i + "] => ");
				print_r(expression[i]);
			}	
			document.write(") ");

			return true;
		}

	}
	else return false;
}

function print_o(object, method)
{
	/*
	 * $method = ( ("alert" | "a") | ( "write" | "w" ) )
	 */
	
	var str = new String("");
	
	for (property in object)
	{
		str += "[" + property + "] : " + object[property] + "\n";
	}
	
	if (method == "alert" || method == "a")
		alert(str);
		
	else if (method == "write" || method == "w")
		air.trace(str);
		
	return str; // Return it anyway
}

function emptyObject(object)
{
	for (property in object)
	{
		delete object[property];
	}
	return object;
}