primitive AppUtil
	fun applyBackgroundColor(red: U8, green: U8, blue: U8): String => 
		"\e[48;2;" + red.string() + ";" + green.string() + ";" + blue.string() + "m"
	
	fun applyForegroundColor(red: U8, green: U8, blue: U8): String => 
		"\e[38;2;" + red.string() + ";" + green.string() + ";" + blue.string() + "m"

	fun resetTermColor(): String => 
		"\e[0m"

	fun applyTermCoordinates(row: U16, column: U16): String =>
		"\e[" + row.string() + ";" + column.string() + "H"

	fun clearTerm(): String => 
		"\e[0J"
