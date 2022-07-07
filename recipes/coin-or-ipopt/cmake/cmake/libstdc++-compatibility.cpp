/* ----------------------------------------------------------------------- *//**
 *
 * @file libstdcxx-compatibility.cpp
 *
 * @brief Declarations/definitions for using an "old" libstdc++ with a newer g++
 *
 * This file follows ideas proposed here: http://glandium.org/blog/?p=1901
 * Unfortunately, MADlib seems to use libstdc++ to a greater extend than
 * Firefox 4.0 did, so we need to do a bit more.
 *
 * The declarations and definitions in this file make it possible to build
 * MADlib with the following versions of gcc (please add to the list), while
 * continuing to only rely on libstdc++.so.6.0.8 (which corresponds to
 * gcc 4.1.2, and labels GLIBCXX_3.4.8, CXXABI_1.3.1).
 *
 * As of September 2012, there is still the need to support libstdc++.so.6.0.8,
 * as this is the libstdc++ that shipped with RedHad/CentOS 5.
 *
 * Tested with the following versions of gcc:
 * - gcc 4.4.2
 * - gcc 4.5.4
 * - gcc 4.6.2
 *
 * For a mapping between gcc versions, libstdc++ versions, and symbol versioning
 * on the libstdc++.so binary, see:
 * http://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html
 *
 *//* ----------------------------------------------------------------------- */

#include <ostream>

// The following macro was introduced with this commit:
// http://gcc.gnu.org/viewcvs?diff_format=h&view=revision&revision=173774
#ifndef _GLIBCXX_USE_NOEXCEPT
    #define _GLIBCXX_USE_NOEXCEPT throw()
#endif

#define GCC_VERSION (  __GNUC__ * 10000 \
                     + __GNUC_MINOR__ * 100 \
                     + __GNUC_PATCHLEVEL__)

// CXXABI_1.3.2 symbols

#if (LIBSTDCXX_COMPAT < 40300 && GCC_VERSION >= 40300)

namespace __cxxabiv1 {

/**
 * @brief Virtual destructor for forced-unwinding class
 *
 * We provide an implementation to avoid CXXABI_1.3.2 symbol versions.
 *
 * Older versions of libstdc++ had the problem that POSIX thread cancellations
 * while writing to an ostream caused an abort:
 * http://gcc.gnu.org/bugzilla/show_bug.cgi?id=28145
 *
 * Newer versions have an additional catch block for references of type
 * __cxxabiv1::__forced_unwind, which represents the POSIX cancellation object:
 * http://gcc.gnu.org/onlinedocs/libstdc++/manual/using_exceptions.html
 * See, e.g., file <bits/ostream.tcc> included from <ostream>. Catching
 * exceptions of this type requires its \c type_info object. However, this
 * object is not normally present in the current binary, as explained in the
 * following.
 *
 * The type __cxxabiv1::__forced_unwind was only introduced in May 2007 (see
 * attachments to the previous bug report) and thus after the release of
 * gcc 4.1.2 (Feb 13, 2007, see http://gcc.gnu.org/releases.html).
 *
 * As http://gcc.gnu.org/onlinedocs/gcc/Vague-Linkage.html explains:
 * <blockquote>
 *     If the class declares any non-inline, non-pure virtual functions, the
 *     first one is chosen as the "key method" for the class, and the vtable is
 *     only emitted in the translation unit where the key method is defined.
 * <blockquote>
 *
 * And later on the same page:
 * <blockquote>
 *     For polymorphic classes (classes with virtual functions), the
 *     \c type_info object is written out along with the vtable [...].
 * <blockquote>
 *
 * Hence, to include a vtable, we need a definition for the key method, which is
 * the constructor. See the declaration here:
 * http://gcc.gnu.org/viewcvs/trunk/libstdc%2B%2B-v3/libsupc%2B%2B/cxxabi_forced.h
 */
__forced_unwind::~__forced_unwind() _GLIBCXX_USE_NOEXCEPT { }

} // namespace __cxxabiv1

#endif // (LIBSTDCXX_COMPAT < 40300 && GCC_VERSION >= 40300)


// GLIBCXX_3.4.9 symbols

#if (LIBSTDCXX_COMPAT < 40200 && GCC_VERSION >= 40200)

namespace std {

/**
 * @brief Write a value to an ostream
 *
 * In recent versions of libstdc++, \c _M_insert contains the implementation for
 * the various operator<<() overloads. Now, as http://glandium.org/blog/?p=1901
 * explains, newer libstdc++ versions contain various instantiations for
 * \c _M_insert, even though <bits/ostream.tcc> contains a general (template)
 * definition.
 *
 * Older versions of libstdc++ did not contain implementations for \c _M_insert,
 * so we instantiate them here. See this change:
 * http://gcc.gnu.org/viewcvs/trunk/libstdc%2B%2B-v3/include/bits/ostream.tcc?r1=109235&r2=109236&
 */
template ostream& ostream::_M_insert(bool);
// The following four lines are not needed and commented out. Specialized
// implementations exist for ostream<<([unsigned] {short|int}).
// template ostream& ostream::_M_insert(short);
// template ostream& ostream::_M_insert(unsigned short);
// template ostream& ostream::_M_insert(int);
// template ostream& ostream::_M_insert(unsigned int);
template ostream& ostream::_M_insert(long);
template ostream& ostream::_M_insert(unsigned long);
#ifdef _GLIBCXX_USE_LONG_LONG
template ostream& ostream::_M_insert(long long);
template ostream& ostream::_M_insert(unsigned long long);
#endif
template ostream& ostream::_M_insert(float);
template ostream& ostream::_M_insert(double);
template ostream& ostream::_M_insert(long double);
template ostream& ostream::_M_insert(const void*);

/**
 * @brief Write a sequence of characters to an ostream
 *
 * This function was only added with this commit:
 * http://gcc.gnu.org/viewcvs?view=revision&revision=123692
 */
template ostream& __ostream_insert(ostream&, const char*, streamsize);

} // namespace std

#endif // (LIBSTDCXX_COMPAT < 40200 && GCC_VERSION >= 40200)


// GLIBCXX_3.4.11 symbols

#if (LIBSTDCXX_COMPAT < 40400 && GCC_VERSION >= 40400)

namespace std {

/**
 * @brief Initialize an internal data structure of ctype<char>
 *
 * This was previously an inline function and moved out of line with this
 * commit:
 * http://gcc.gnu.org/viewcvs?view=revision&revision=140238
 *
 * See also this bug report:
 * http://gcc.gnu.org/bugzilla/show_bug.cgi?id=37455
 *
 * std::ctype<char>::_M_widen_init() is a function added to libstdc++ by
 * Jerry Quinn with revision 74662 on Dec 16, 2003:
 * http://gcc.gnu.org/viewcvs?diff_format=h&view=revision&revision=74662
 *
 * With explicit permission by Jerry Quinn from Oct 9, 2012, we include a
 * verbatim copy of _M_widen_init() here. However, a static_cast was added to
 * avoid a warning.
 *
 * Revision 74662 of the libstdc++-v3 file include/bits/locale_facets.h, where
 * std::ctype<char>::_M_widen_init() has been copied from, also included the
 * following notice in the file header:
 * http://gcc.gnu.org/viewcvs/trunk/libstdc%2B%2B-v3/include/bits/locale_facets.h?diff_format=h&view=markup&pathrev=74662
 *
 * <blockquote>
 *     As a special exception, you may use this file as part of a free software
 *     library without restriction. [...]
 * <blockquote>
 */
void
ctype<char>::_M_widen_init() const {
    char __tmp[sizeof(_M_widen)];
    for (unsigned __i = 0; __i < sizeof(_M_widen); ++__i)
        __tmp[__i] = static_cast<char>(__i);
    do_widen(__tmp, __tmp + sizeof(__tmp), _M_widen);

    _M_widen_ok = 1;
    // Set _M_widen_ok to 2 if memcpy can't be used.
    for (unsigned __i = 0; __i < sizeof(_M_widen); ++__i)
        if (__tmp[__i] != _M_widen[__i]) {
            _M_widen_ok = 2;
            break;
        }
}

} // namespace std

#endif // (LIBSTDCXX_COMPAT < 40400 && GCC_VERSION >= 40400)


// GLIBCXX_3.5.15 symbols

#if (LIBSTDCXX_COMPAT < 40600 && GCC_VERSION >= 40600)

#include <stdexcept>

namespace std {

/**
 * @brief Empty dtors for standard exceptions
 *
 * Later versions of libstdc++ added destructors to some standard exceptions.
 * Definitions for these are missing in older versions of libstdc++.
 *
 * Of course, additing destructors is potentially dangerous and can change the
 * ABI. However, these classes derived from \c runtime_error and \c logic_error
 * before and therefore have always had virtual members.
 *
 * The first commit that added these destructors is:
 * http://gcc.gnu.org/viewcvs?diff_format=h&view=revision&revision=170975
 * This commit was included already in the first gcc 4.6.0 release:
 * http://gcc.gnu.org/viewcvs/tags/gcc_4_6_0_release/libstdc%2B%2B-v3/src/stdexcept.cc
 */
domain_error::~domain_error() _GLIBCXX_USE_NOEXCEPT { }
invalid_argument::~invalid_argument() _GLIBCXX_USE_NOEXCEPT { }
length_error::~length_error() _GLIBCXX_USE_NOEXCEPT { }
out_of_range::~out_of_range() _GLIBCXX_USE_NOEXCEPT { }
runtime_error::~runtime_error() _GLIBCXX_USE_NOEXCEPT { }
range_error::~range_error() _GLIBCXX_USE_NOEXCEPT { }
overflow_error::~overflow_error() _GLIBCXX_USE_NOEXCEPT { }
underflow_error::~underflow_error() _GLIBCXX_USE_NOEXCEPT { }

} // namespace std

#endif // (LIBSTDCXX_COMPAT < 40600 && GCC_VERSION >= 40600)
