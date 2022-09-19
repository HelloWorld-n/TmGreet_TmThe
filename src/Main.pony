use "time"
use "random"
use "files"
use "json"


class Notify is TimerNotify
	let env: Env
	let random: Rand
	let data_keys: Array[String] = [
		"CLICK"
		"LEVEL"
		"XP"
	]

	let termColor_basicText: String = (
		AppUtil.applyBackgroundColor(0, 0, 0) + AppUtil.applyForegroundColor(127, 189, 189)
	)
	let termColor_key: String = (
		AppUtil.applyBackgroundColor(0, 0, 0) + AppUtil.applyForegroundColor(235, 189, 64)
	)
	let termColor_value: String = (
		AppUtil.applyBackgroundColor(0, 0, 0) + AppUtil.applyForegroundColor(189, 64, 235)
	)
	let termColor_end: String = AppUtil.resetTermColor()

	var data: JsonObject
	var data_click: I64 = 1
	var data_level: I64 = 0
	var data_xp: I64 = 0

	fun goal(level: I64): I64 =>
		(16 * (level * level * level)) + (8 * 8 * 8)
	
	

	fun ref load()? =>
		let path = FilePath(FileAuth(env.root), "./.data.json")
		var json_string = ""
		let json_doc = JsonDoc
		match OpenFile(path)
		| let file: File =>
			while file.errno() is FileOK do
				json_string = json_string + file.read_string(1024)
			end
		else
			env.err.print("Unable to load!")
		end
		
		json_string = json_string


		try
			json_doc.parse(json_string)?
		end
		
		env.err.print(json_string)

		var json_object: JsonObject = (
			match json_doc.data
			| let obj: JsonObject =>
				obj
			else
				error
			end
		)

		for key in data_keys.values() do
			data.data.update(key, JsonUtil.fetch_data_simple(json_object, key)?)
		end	


	fun save() =>
		let path = FilePath(FileAuth(env.root), "./.data.json")
		match File(path)
		| let file: File =>
			let string''' = data.string("\t", true)
			file.write(string''')
			file.set_length(string'''.size())
			file.flush()
			consume file
		end

	fun ref improve() =>
		try
			data.data.update(
				"XP", 
				JsonUtil.fetch_data_i64(data, "XP")? + JsonUtil.fetch_data_i64(data, "CLICK")?
			)
			while JsonUtil.fetch_data_i64(data, "XP")? >= goal(JsonUtil.fetch_data_i64(data, "LEVEL")?) do
				data.data.update(
					"XP", 
					JsonUtil.fetch_data_i64(data, "XP")? - goal(JsonUtil.fetch_data_i64(data, "LEVEL")?)
				)
				data.data.update(
					"LEVEL", 
					JsonUtil.fetch_data_i64(data, "LEVEL")? + I64(1)
				)
			end
		else
			env.out.write(AppUtil.applyBackgroundColor(127, 0, 0))
		end
	

	new iso create(env': Env) =>
		env = env'
		random = Rand.create(Time.seconds().u64())
		data = JsonObject()


		try
			load()?
		else
			data.data.update("CLICK", data_click)
			data.data.update("LEVEL", data_level)
			data.data.update("XP", data_xp)
		end

	fun write_timeNowUtc() =>
		var now_fullSeconds = Time.seconds()
		var now = PosixDate(Time.seconds())

		try
			env.out.write(
				(
					termColor_value + now.format("%Y-%m-%dT%H:%M:%S")?
				) + (
					termColor_key + " (UTC)"
				) + (
					termColor_end + "\n"
				)
			)
		end

	fun ref maybeImproveClick() =>
		env.out.write(termColor_basicText)
		env.out.write("[")
		var counter = U8(0)
		var countPositives = U8(0)
		while true do 
			let randomValue = random.i8()
			env.out.write(termColor_value + randomValue.string() + termColor_basicText)
			counter = counter + 1
			if randomValue >= 0 then
				countPositives = countPositives + 1
			end
			if counter < 8 then
				env.out.write(", ")
			else
				if countPositives == counter then
					try
						data.data.update("CLICK", JsonUtil.fetch_data_i64(data, "CLICK")? + 1)
					end
				end
				break
			end
		end
		consume counter
		env.out.write("]" + termColor_end)

	fun ref write_data() =>
		try
			env.out.write(termColor_basicText + "\n\n{\n")
			for data_key in data_keys.values() do
				env.out.write(
					"\t" + (
						termColor_key + "\"" + data_key + "\"" + termColor_basicText
					) + ": " + (
						termColor_value + JsonUtil.fetch_data_simple(data, data_key)?.string() + termColor_basicText
					) + ",\n"
				)
			end
			env.out.write(
					"\t" + (
						termColor_key + "\"GOAL\"" + termColor_basicText
					) + ": " + (
						termColor_value + goal(JsonUtil.fetch_data_i64(data, "LEVEL")?).string() + termColor_basicText
					) + ",\n"
				)
			env.out.write("}\n\n" + termColor_end)
		end
		

	fun ref apply(timer: Timer, count: U64): Bool =>
		env.out.write(AppUtil.applyTermCoordinates(1, 1) + AppUtil.clearTerm())
		write_timeNowUtc()
		maybeImproveClick()
		improve()
		write_data()
		save()
		true

actor Main
	new create(env: Env) =>
		let timers = Timers
		let timer = Timer(Notify(env), 0_000_000_000, 1_000_000_000)
		timers(consume timer)
