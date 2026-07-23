// SPDX-License-Identifier: LGPL-2.1
#include <stdio.h>
#include <string.h>

#include <event-parse.h>
#include <trace-seq.h>

int main(void)
{
	struct tep_handle *tep;
	struct tep_plugin_list *plugins;
	struct trace_seq s;

	tep = tep_alloc();
	if (!tep) {
		fprintf(stderr, "tep_alloc failed\n");
		return 1;
	}

	plugins = tep_load_plugins(tep);
	if (!plugins) {
		fprintf(stderr, "no plugins were loaded\n");
		return 1;
	}

	trace_seq_init(&s);
	trace_seq_printf(&s, "libtraceevent %d", 42);
	trace_seq_terminate(&s);
	if (strcmp(s.buffer, "libtraceevent 42") != 0) {
		fprintf(stderr, "trace_seq mismatch: %s\n", s.buffer);
		return 1;
	}
	trace_seq_destroy(&s);

	tep_unload_plugins(plugins, tep);
	tep_free(tep);
	printf("ok\n");
	return 0;
}
