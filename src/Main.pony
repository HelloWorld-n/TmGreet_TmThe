use "time"
use "random"

class Notify is TimerNotify
	let env: Env
	let random: Rand
	new iso create(env': Env) =>
		env = env'
		random = Rand.create(Time.seconds().u64())

	fun ref apply(timer: Timer, count: U64): Bool =>
		var now_fullSeconds = Time.seconds()
		var now = PosixDate(Time.seconds())

		env.out.write(AppUtil.applyTermCoordinates(1, 1) + AppUtil.clearTerm())
		try
			env.out.write(
				(
					AppUtil.applyTermCoordinates(1, 1)
				) + (
					now.format("%Y-%m-%dT%H:%M:%S")? + " "
				) + (
					AppUtil.applyForegroundColor(127, 31, 196) + "(UTC)"
				) + (
					AppUtil.resetTermColor()
				)
			)
		end

		now_fullSeconds = Time.seconds()
		now = PosixDate(now_fullSeconds)
		
		env.out.write(AppUtil.applyTermCoordinates(2, 1) + "[")
		var counter = U8(0)
		while true do 
			env.out.write(random.i8().string())
			counter = counter + 1
			if counter < 8 then
				env.out.write("; ")
			else
				break
			end
		end
		env.out.write("]")
		true

actor Main
	new create(env: Env) =>
		let timers = Timers
		let timer = Timer(Notify(env), 0_000_000_000, 1_000_000_000)
		timers(consume timer)
