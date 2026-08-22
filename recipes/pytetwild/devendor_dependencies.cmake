# Injected through CMAKE_PROJECT_TOP_LEVEL_INCLUDES to build against the conda-forge packages
# instead of the copies that fTetWild and libigl download.
#
# The lookups cannot happen here directly. CMAKE_PROJECT_TOP_LEVEL_INCLUDES is processed by
# project() before any language is enabled, and importing a compiled target at that point fails
# with "CMAKE_CXX_COMPILER not set, after EnableLanguage". A dependency provider is called later,
# when FetchContent_MakeAvailable() is reached, so the compilers are configured by then.

cmake_minimum_required(VERSION 3.24)

include(FetchContent)

# FetchContent names used upstream, mapped to the conda-forge CMake package names. The two differ
# in case and in spelling, so FETCHCONTENT_TRY_FIND_PACKAGE_MODE would not resolve them.
set(PYTETWILD_REDIRECTED_DEPENDENCIES
    cli11  CLI11
    fmt    fmt
    json   nlohmann_json
    spdlog spdlog
    tbb    TBB
)

# Not packaged on conda-forge, so these are vendored by the recipe under vendored/ and pointed at
# below. Nothing is downloaded at build time.
set(PYTETWILD_VENDORED_DEPENDENCIES geogram libigl predicates)

# Any dependency a future release adds has neither a conda-forge redirection nor a vendored
# copy, so it fails the build instead of being downloaded silently. This also covers
# FetchContent_Populate(), which the dependency provider below never sees.
set(FETCHCONTENT_FULLY_DISCONNECTED ON CACHE BOOL "" FORCE)

foreach(pytetwild_dependency IN LISTS PYTETWILD_VENDORED_DEPENDENCIES)
    string(TOUPPER "${pytetwild_dependency}" pytetwild_dependency_upper)
    set(FETCHCONTENT_SOURCE_DIR_${pytetwild_dependency_upper}
        "${CMAKE_CURRENT_SOURCE_DIR}/vendored/${pytetwild_dependency}" CACHE PATH "" FORCE)
endforeach()

# Eigen is populated by libigl with FetchContent_Populate(), which no dependency provider
# intercepts. Its recipe returns early when Eigen3::Eigen exists, so the target is defined here.
# Being header only, it can be imported before the languages are enabled.
find_package(Eigen3 CONFIG REQUIRED)

# Called by FetchContent for each dependency: it satisfies the ones conda-forge provides with
# find_package, and rejects anything that is neither redirected nor vendored.
macro(pytetwild_dependency_provider method dependency)
    if("${method}" STREQUAL "FETCHCONTENT_MAKEAVAILABLE_SERIAL")

        string(TOLOWER "${dependency}" pytetwild_dependency)
        list(FIND PYTETWILD_REDIRECTED_DEPENDENCIES "${pytetwild_dependency}" pytetwild_index)

        if(NOT pytetwild_index EQUAL -1)

            math(EXPR pytetwild_index "${pytetwild_index} + 1")
            list(GET PYTETWILD_REDIRECTED_DEPENDENCIES ${pytetwild_index} pytetwild_package)
            find_package(${pytetwild_package} CONFIG REQUIRED)

            # fTetWild links a target named json, which nlohmann_json does not provide.
            if(pytetwild_dependency STREQUAL "json" AND NOT TARGET json)
                add_library(json INTERFACE IMPORTED GLOBAL)
                set_property(TARGET json PROPERTY INTERFACE_LINK_LIBRARIES nlohmann_json::nlohmann_json)
            endif()

            FetchContent_SetPopulated(${dependency})

        else()

            # A new upstream dependency must be an explicit decision, not a silent download.
            # The vendored ones never reach here, since FetchContent skips the provider
            # when FETCHCONTENT_SOURCE_DIR_<name> is set.
            message(FATAL_ERROR
                "Unexpected FetchContent dependency '${dependency}'. Add it to "
                "PYTETWILD_REDIRECTED_DEPENDENCIES when conda-forge packages it, or vendor it in "
                "the recipe and add it to PYTETWILD_VENDORED_DEPENDENCIES otherwise.")

        endif()
    endif()
endmacro()

cmake_language(
    SET_DEPENDENCY_PROVIDER pytetwild_dependency_provider
    SUPPORTED_METHODS FETCHCONTENT_MAKEAVAILABLE_SERIAL
)
