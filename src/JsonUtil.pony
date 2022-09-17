use "json"

class JsonUtil

	fun ref fetch_data_simple(json: JsonObject, key: String): (I64|F64|String|Bool)? =>
		try
			match json.data(key)?
			| let value: (I64|F64|String|Bool) =>
				value
			else
				error
			end
		else
			error	
		end
	
	fun ref fetch_data_i64(json: JsonObject, key: String): I64? =>
		try
			match json.data(key)?
			| let value: I64 =>
				value
			else
				error
			end
		else
			error	
		end
