#include <visit_struct/visit_struct.hpp>

#include <cassert>
#include <iostream>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

/***
 * Test structures
 */

struct test_struct_one {
  int a;
  float b;
  std::string c;
};

VISITABLE_STRUCT(test_struct_one, a, b, c);

static_assert(visit_struct::traits::is_visitable<test_struct_one>::value, "WTF");
static_assert(visit_struct::field_count<test_struct_one>() == 3, "WTF");

struct test_struct_two {
  bool b;
  int i;
  double d;
  std::string s;
};

VISITABLE_STRUCT(test_struct_two, d, i, b);
// Note the order and that 's' is not registered!

static_assert(visit_struct::traits::is_visitable<test_struct_two>::value, "WTF");
static_assert(visit_struct::field_count<test_struct_two>() == 3, "WTF");

/***
 * Test visitors
 */

using spair = std::pair<std::string, std::string>;

struct test_visitor_one {
  std::vector<spair> result;

  void operator()(const char * name, const std::string & s) {
    result.emplace_back(spair{std::string{name}, s});
  }

  template <typename T>
  void operator()(const char * name, const T & t) {
    result.emplace_back(spair{std::string{name}, std::to_string(t)});
  }
};

struct test_visitor_ptr {
  std::vector<spair> result;

  template <typename C>
  void operator()(const char* name, int C::*) {
    result.emplace_back(spair{std::string{name}, "int"});
  }

  template <typename C>
  void operator()(const char* name, float C::*) {
    result.emplace_back(spair{std::string{name}, "float"});
  }

  template <typename C>
  void operator()(const char* name, std::string C::*) {
    result.emplace_back(spair{std::string{name}, "std::string"});
  }
};

struct test_visitor_type {
  std::vector<spair> result;

  void operator()(const char* name, visit_struct::type_c<int>) {
    result.emplace_back(spair{std::string{name}, "int"});
  }

  void operator()(const char* name, visit_struct::type_c<float>) {
    result.emplace_back(spair{std::string{name}, "float"});
  }

  void operator()(const char* name, visit_struct::type_c<std::string>) {
    result.emplace_back(spair{std::string{name}, "std::string"});
  }
};



using ppair = std::pair<const char * , const void *>;

struct test_visitor_two {
  std::vector<ppair> result;

  template <typename T>
  void operator()(const char * name, const T & t) {
    result.emplace_back(ppair{name, static_cast<const void *>(&t)});
  }
};



struct test_visitor_three {
  int result = 0;

  template <typename T>
  void operator()(const char *, T &&) {}

  void operator()(const char *, int &) {
    result = 1;
  }

  void operator()(const char *, const int &) {
    result = 2;
  }

  void operator()(const char *, int &&) {
    result = 3;
  }

  // Make it non-copyable and non-moveable, apply visitor should still work.
  test_visitor_three() = default;
  test_visitor_three(const test_visitor_three &) = delete;
  test_visitor_three(test_visitor_three &&) = delete;
};


// Some binary visitors for test

struct test_eq_visitor {
  bool result = true;

  template <typename T>
  void operator()(const char *, const T & t1, const T & t2) {
    result = result && (t1 == t2);
  }
};

struct test_pair_visitor {
  bool result = false;

  template <typename T>
  void operator()(const char *, const T &, const T &) {}

  void operator()(const char *, const int & x, const int & y) {
    result = result || (x > y);
  }
};

// Interface for binary visitors
template <typename T>
bool struct_eq(const T & t1, const T & t2) {
  test_eq_visitor vis;
  visit_struct::apply_visitor(vis, t1, t2);
  return vis.result;
}

template <typename T>
bool struct_int_cmp(const T & t1, const T & t2) {
  test_pair_visitor vis;
  visit_struct::apply_visitor(vis, t1, t2);
  return vis.result;
}

// debug_print

struct debug_printer {
  template <typename T>
  void operator()(const char * name, const T & t) const {
    std::cout << "  " << name << ": " << t << std::endl;
  }
};

template <typename T>
void debug_print(const T & t) {
  std::cout << "{\n";
  visit_struct::apply_visitor(debug_printer{}, t);
  std::cout << "}" << std::endl;
}

/***
 * tests
 */

static_assert(std::is_same<decltype(visit_struct::get<0>(std::declval<test_struct_one>())), int &&>::value, "");
static_assert(std::is_same<decltype(visit_struct::get<1>(std::declval<test_struct_one>())), float &&>::value, "");
static_assert(std::is_same<decltype(visit_struct::get<2>(std::declval<test_struct_one>())), std::string &&>::value, "");
static_assert(std::is_same<decltype(visit_struct::get_name<0, test_struct_one>()), const char (&)[2]>::value, "");
static_assert(std::is_same<decltype(visit_struct::get_name<1, test_struct_one>()), const char (&)[2]>::value, "");
static_assert(std::is_same<decltype(visit_struct::get_name<2, test_struct_one>()), const char (&)[2]>::value, "");
static_assert(visit_struct::get_pointer<0, test_struct_one>() == &test_struct_one::a, "");
static_assert(visit_struct::get_pointer<1, test_struct_one>() == &test_struct_one::b, "");
static_assert(visit_struct::get_pointer<2, test_struct_one>() == &test_struct_one::c, "");
static_assert(std::is_same<visit_struct::type_at<0, test_struct_one>, int>::value, "");
static_assert(std::is_same<visit_struct::type_at<1, test_struct_one>, float>::value, "");
static_assert(std::is_same<visit_struct::type_at<2, test_struct_one>, std::string>::value, "");

int main() {
  // Test version string
  std::cout << VISIT_STRUCT_VERSION_STRING << std::endl;

  std::cout << __FILE__ << std::endl;

  {
    test_struct_one s{ 5, 7.5f, "asdf" };

    debug_print(s);

    // Test getters

    assert(visit_struct::field_count(s) == 3);
    assert(visit_struct::get<0>(s) == 5);
    assert(visit_struct::get<1>(s) == 7.5f);
    assert(visit_struct::get<2>(s) == "asdf");
    assert(visit_struct::get_name<0>(s) == std::string{"a"});
    assert(visit_struct::get_name<1>(s) == std::string{"b"});
    assert(visit_struct::get_name<2>(s) == std::string{"c"});
    assert(visit_struct::get_accessor<0>(s)(s) == visit_struct::get<0>(s));
    assert(visit_struct::get_accessor<1>(s)(s) == visit_struct::get<1>(s));
    assert(visit_struct::get_accessor<2>(s)(s) == visit_struct::get<2>(s));

    // Test visitation

    test_visitor_one vis1;
    visit_struct::apply_visitor(vis1, s);

    assert(vis1.result.size() == 3);
    assert(vis1.result[0].first == "a");
    assert(vis1.result[0].second == "5");
    assert(vis1.result[1].first == "b");
    assert(vis1.result[1].second == "7.500000");
    assert(vis1.result[2].first == "c");
    assert(vis1.result[2].second == "asdf");

    test_visitor_two vis2;
    visit_struct::apply_visitor(vis2, s);

    assert(vis2.result.size() == 3);
    assert(vis2.result[0].second == &s.a);
    assert(vis2.result[1].second == &s.b);
    assert(vis2.result[2].second == &s.c);

    test_struct_one t{ 0, 0.0f, "jkl" };

    debug_print(t);

    assert(visit_struct::field_count(t) == 3);
    assert(visit_struct::get<0>(t) == 0);
    assert(visit_struct::get<1>(t) == 0.0f);
    assert(visit_struct::get<2>(t) == "jkl");
    assert(visit_struct::get_name<0>(t) == std::string{"a"});
    assert(visit_struct::get_name<1>(t) == std::string{"b"});
    assert(visit_struct::get_name<2>(t) == std::string{"c"});

    test_visitor_one vis3;
    visit_struct::for_each(t, vis3);

    assert(vis3.result.size() == 3);
    assert(vis3.result[0].first == "a");
    assert(vis3.result[0].second == "0");
    assert(vis3.result[1].first == "b");
    assert(vis3.result[1].second == "0.000000");
    assert(vis3.result[2].first == "c");
    assert(vis3.result[2].second == "jkl");

    test_visitor_two vis4;
    visit_struct::apply_visitor(vis4, t);

    assert(vis4.result.size() == 3);
    assert(vis4.result[0].first == vis2.result[0].first);
    assert(vis4.result[0].second == &t.a);
    assert(vis4.result[1].first == vis2.result[1].first);
    assert(vis4.result[1].second == &t.b);
    assert(vis4.result[2].first == vis2.result[2].first);
    assert(vis4.result[2].second == &t.c);

    // test get_name
    assert(std::string("test_struct_one") == visit_struct::get_name(s));
    assert(std::string("test_struct_one") == visit_struct::get_name(t));
    assert(std::string("test_struct_one") == visit_struct::get_name<test_struct_one>());
  }

  {
    test_struct_two s{ false, 5, -1.0, "foo" };

    debug_print(s);

    assert(visit_struct::get<0>(s) == -1.0f);
    assert(visit_struct::get<1>(s) == 5);
    assert(visit_struct::get<2>(s) == false);
    assert(visit_struct::get_name<0>(s) == std::string{"d"});
    assert(visit_struct::get_name<1>(s) == std::string{"i"});
    assert(visit_struct::get_name<2>(s) == std::string{"b"});


    test_visitor_one vis1;
    visit_struct::apply_visitor(vis1, s);

    assert(vis1.result.size() == 3);
    assert(vis1.result[0].first == std::string{"d"});
    assert(vis1.result[0].second == "-1.000000");
    assert(vis1.result[1].first == std::string{"i"});
    assert(vis1.result[1].second == "5");
    assert(vis1.result[2].first == std::string{"b"});
    assert(vis1.result[2].second == "0");

    test_visitor_two vis2;
    visit_struct::apply_visitor(vis2, s);

    assert(vis2.result.size() == 3);
    assert(vis2.result[0].second == &s.d);
    assert(vis2.result[1].second == &s.i);
    assert(vis2.result[2].second == &s.b);


    test_struct_two t{ true, -14, .75, "bar" };

    debug_print(t);

    test_visitor_one vis3;
    visit_struct::apply_visitor(vis3, t);

    assert(vis3.result.size() == 3);
    assert(vis3.result[0].first == std::string{"d"});
    assert(vis3.result[0].second == "0.750000");
    assert(vis3.result[1].first == std::string{"i"});
    assert(vis3.result[1].second == "-14");
    assert(vis3.result[2].first == std::string{"b"});
    assert(vis3.result[2].second == "1");

    test_visitor_two vis4;
    visit_struct::apply_visitor(vis4, t);

    assert(vis4.result.size() == 3);
    assert(vis4.result[0].first == vis2.result[0].first);
    assert(vis4.result[0].second == &t.d);
    assert(vis4.result[1].first == vis2.result[1].first);
    assert(vis4.result[1].second == &t.i);
    assert(vis4.result[2].first == vis2.result[2].first);
    assert(vis4.result[2].second == &t.b);

    // test get_name
    assert(std::string("test_struct_two") == visit_struct::get_name(s));
    assert(std::string("test_struct_two") == visit_struct::get_name(t));
    assert(std::string("test_struct_two") == visit_struct::get_name<test_struct_two>());
  }

  // Test move semantics
  {
    test_struct_one s{0, 0, ""};

    test_visitor_three vis;

    visit_struct::apply_visitor(vis, s);
    assert(vis.result == 1);

    const auto & ref = s;
    visit_struct::apply_visitor(vis, ref);
    assert(vis.result == 2);

    visit_struct::apply_visitor(vis, std::move(s));
    assert(vis.result == 3);
  }

  // Test visiting with no instance
  {
    test_visitor_ptr vis;

    visit_struct::visit_pointers<test_struct_one>(vis);
    assert(vis.result.size() == 3u);
    assert(vis.result[0].first == "a");
    assert(vis.result[0].second == "int");
    assert(vis.result[1].first == "b");
    assert(vis.result[1].second == "float");
    assert(vis.result[2].first == "c");
    assert(vis.result[2].second == "std::string");
  }

  {
    test_visitor_type vis;

    visit_struct::visit_types<test_struct_one>(vis);
    assert(vis.result.size() == 3u);
    assert(vis.result[0].first == "a");
    assert(vis.result[0].second == "int");
    assert(vis.result[1].first == "b");
    assert(vis.result[1].second == "float");
    assert(vis.result[2].first == "c");
    assert(vis.result[2].second == "std::string");
  }

  // Test visiting two instances
  {
    test_struct_one s1{0, 0, ""};
    test_struct_one s2{1, 1, "a"};
    test_struct_one s3{2, 0, ""};
    test_struct_one s4{3, 4, "b"};

    assert(struct_eq(s1, s1));
    assert(struct_eq(s2, s2));
    assert(struct_eq(s3, s3));
    assert(struct_eq(s4, s4));

    assert(!struct_eq(s1, s2));
    assert(!struct_eq(s1, s3));
    assert(!struct_eq(s1, s4));
    assert(!struct_eq(s2, s3));

    assert(struct_int_cmp(s2, s1));
    assert(!struct_int_cmp(s1, s2));
    assert(struct_int_cmp(s3, s1));
    assert(!struct_int_cmp(s1, s3));
    assert(struct_int_cmp(s4, s1));
    assert(!struct_int_cmp(s1, s4));
  }
}
