; Initializes SkillBridge in Virtuoso when installed in a Viper environment using Virtue
; http://www.cascode-labs.org/viper/
; http://www.cascode-labs.org/virtue/

printf("Initializing skillbridge\n")

let((file_path dir_path)
	file_path = simplifyFilename(get_filename(piport))
	dir_path = strcat("/" buildString(reverse(cdr(reverse(parseString(file_path "/")))) "/"))
	loadi(strcat( dir_path "/python_server.il"))
)

printf("  Done, Initialized skillbridge\n")