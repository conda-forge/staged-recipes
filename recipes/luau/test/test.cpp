#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <lua.h>
#include <lualib.h>
#include <luacode.h>
#include <luacodegen.h>

int main()
{
    const char* source = "local s = 0 for i = 1, 10 do s += i end return s";
    size_t bytecodeSize = 0;
    char* bytecode = luau_compile(source, std::strlen(source), nullptr, &bytecodeSize);

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    if (luau_codegen_supported())
        luau_codegen_create(L);

    int rc = luau_load(L, "=test", bytecode, bytecodeSize, 0);
    std::free(bytecode);
    if (rc != 0 || lua_pcall(L, 0, 1, 0) != 0)
    {
        std::printf("error: %s\n", lua_tostring(L, -1));
        return 1;
    }
    int result = int(lua_tointeger(L, -1));
    lua_close(L);
    std::printf("sum = %d\n", result);
    return result == 55 ? 0 : 1;
}
