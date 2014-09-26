<cfscript>
/**************************************************************************
This library is part of the Common Function Library Project.
An open source	collection of UDF libraries
designed for ColdFusion 5.0 and higher. For more information,
please see the web site at: http://www.cflib.org

Warning:
You may not need all the functions in this library. If speed
is _extremely_ important, you may want to consider deleting
functions you do not plan on using. Normally you should not
have to worry about the size of the library.

License:
This code may be used freely. You may modify this code as you
see fit, however, this header, and the header for the functions
must remain intact.

This code is provided as is.
We make no warranty or guarantee.
Use of this code is at your own risk.
**************************************************************************/
/**************************************************************************
 Backport of QueryExecute in CF11 to CF9 &amp; CF10

 @param sql_statement      SQL. (Required)
 @param queryParams      Struct of query param values. (Optional)
 @param queryOptions      Query options. (Optional)
 @return Returns a query.
 @author Henry Ho (henryho167@gmail.com)
 @version 1, September 22, 2014
**************************************************************************/

/**
* Result struct is returned to the caller by utilizing URL scope (no prefix needed)
* https://wikidocs.adobe.com/wiki/display/coldfusionen/QueryExecute
* @output false
*/
public query function QueryExecute(required string sql_statement, queryParams=structNew(), queryOptions=structNew()){

	var parameters 	= [];

	if(isArray(arguments.queryParams)){
		for(var param in arguments.queryParams){
			if(isSimpleValue(param))
				arrayAppend(parameters, {value=param});
			else
				arrayAppend(parameters, param);
		}
	}
	else if(isStruct(arguments.queryParams)){
		for(var key in arguments.queryParams){
			if(isSimpleValue(arguments.queryParams[key])){
				arrayAppend(parameters, {name=key, value=arguments.queryParams[key]});
			}
			else{
				var parameter = {name=key};
				structAppend(parameter, arguments.queryParams[key]);
				arrayAppend(parameters, parameter);
			}
		}
	}
	else{
		throw(message="Unexpected type for queryParams");
	}

	// strip scope, not supported
	if(structKeyExists(arguments.queryOptions, "result"))
		arguments.queryOptions.result = listLast(arguments.queryOptions.result, '.');

	var executeResult = new Query(sql=arguments.sql_statement, parameters=parameters, argumentCollection=arguments.queryOptions).execute();

	// workaround for passing result struct value out to the caller by utilizing URL scope (no prefix needed)
	if(structKeyExists(arguments.queryOptions, "result"))
		URL[arguments.queryOptions.result] = executeResult.getPrefix();

	return executeResult.getResult();
}

</cfscript>