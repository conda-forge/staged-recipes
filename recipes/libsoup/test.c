#include <libsoup/soup.h>

int main(int argc, char *argv[]) {
  g_debug("Entering main");
  SoupMessage *msg = soup_message_new("GET", "https://conda-forge.org");
  SoupSession *session = soup_session_new();
#ifdef G_OS_WIN32
  gchar *ca_file = g_build_filename(g_getenv("CONDA_PREFIX"), "Library", "ssl", "cacert.pem", NULL);
  GError *error = NULL;
  GTlsDatabase *db = g_tls_file_database_new(ca_file, &error);
  if (error) {
    g_warning("Could not create TLS database for %s -> %s", ca_file, error->message);
    g_error_free(error);
  }
  else {
    g_object_set(session, "tls-database", db, "ssl-use-system-ca-file", FALSE, NULL);
    g_object_unref(db);
  }
  g_free(ca_file);
#endif
  soup_session_send_message(session, msg); // blocks
  g_assert_true(SOUP_STATUS_IS_SUCCESSFUL(msg->status_code));
  g_object_unref(msg);
  g_object_unref(session);
  return 0;
}

