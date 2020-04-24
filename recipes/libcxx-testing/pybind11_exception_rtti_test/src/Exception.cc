#include <cstring>
#include <ostream>
#include <sstream>
#include <string>

#include "Exception.h"

namespace lsst_exceptions {

LSSTException::LSSTException(std::string const& message) : _message(message) {}

LSSTException::~LSSTException(void) noexcept {}

char const* LSSTException::what(void) const noexcept { return _message.c_str(); }

LSSTException* LSSTException::clone(void) const { return new LSSTException(*this); }

}  // namespace exceptions
