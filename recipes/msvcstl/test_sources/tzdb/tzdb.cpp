// adapted from upstream tests
// https://github.com/gcc-mirror/gcc/blob/releases/gcc-14.1.0/libstdc%2B%2B-v3/testsuite/std/time/tzdb/1.cc
// https://github.com/gcc-mirror/gcc/blob/releases/gcc-14.1.0/libstdc%2B%2B-v3/testsuite/std/time/tzdb/leap_seconds.cc

#include <chrono>
#include <string>
#include <string_view>
#include <stdio.h>
#include <stdlib.h>

// https://github.com/gcc-mirror/gcc/blob/releases/gcc-14.1.0/libstdc%2B%2B-v3/testsuite/util/testsuite_hooks.h#L61-L70
#define VERIFY(fn)                                              \
  do                                                            \
  {                                                             \
    if (! (fn))                                                 \
      {                                                         \
    __builtin_fprintf(stderr,                                   \
        "%s:%d: %s: Assertion '%s' failed.\n",                  \
        __FILE__, __LINE__, __PRETTY_FUNCTION__, #fn);          \
    __builtin_abort();                                          \
      }                                                         \
  } while (false)

using namespace std::chrono;

void
test_version()
{
  const tzdb& db = get_tzdb();
  VERIFY( &db == &get_tzdb_list().front() );

  const char* func;
  try {
    func = "remote_version";
    VERIFY( db.version == remote_version() );
    func = "reload_tzdb";
    const tzdb& reloaded = reload_tzdb();
    if (reloaded.version == db.version)
      VERIFY( &reloaded == &db );
  } catch (const std::exception&) {
    std::printf("std::chrono::%s() failed\n", func);
    // on exception, we fail louder than the upstream reference test
    exit(1);
  }
}

void
test_current()
{
  const tzdb& db = get_tzdb();
  const time_zone* tz = db.current_zone();
  VERIFY( tz == std::chrono::current_zone() );
}

void
test_locate()
{
  const tzdb& db = get_tzdb();
  const time_zone* tz = db.locate_zone("GMT");
  VERIFY( tz != nullptr );
  VERIFY( tz->name() == "Etc/GMT" );
  VERIFY( tz == std::chrono::locate_zone("GMT") );
  VERIFY( tz == db.locate_zone("Etc/GMT") );
  VERIFY( tz == db.locate_zone("Etc/GMT+0") );

  VERIFY( db.locate_zone(db.current_zone()->name()) == db.current_zone() );
}

void
test_all_zones()
{
  const tzdb& db = get_tzdb();

  for (const auto& zone : db.zones)
    VERIFY( locate_zone(zone.name())->name() == zone.name() );

  for (const auto& link : db.links)
    VERIFY( locate_zone(link.name()) == locate_zone(link.target()) );
}

void
test_load_leapseconds()
{
  const auto& db = get_tzdb();
  auto len = db.leap_seconds.size();
  std::printf("found %zu leapseconds\n", len);

  VERIFY( db.leap_seconds.size() == 27 );
}

int main()
{
  test_version();
  test_current();
  test_locate();
  test_load_leapseconds();
}
