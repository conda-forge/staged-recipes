#include <stdio.h>
#include <mujs.h>

int main(int argc, char **argv)
{
	char line[256];
	js_State *J = js_newstate(NULL, NULL, JS_STRICT);
	while (fgets(line, sizeof line, stdin))
		js_dostring(J, line);
	js_freestate(J);
}
