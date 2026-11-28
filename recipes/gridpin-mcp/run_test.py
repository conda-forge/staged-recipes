"""Start the server in-process with the MCP SDK client, without any country file or network.

Checks that the installed mcp SDK and the gridpin engine fit together: the tools are listed,
and a query for a country that is not downloaded returns a tool error that names the fix.
"""
import asyncio
import os
import tempfile

os.environ["GRIDPIN_HOME"] = tempfile.mkdtemp()  # empty sheet cache: nothing is downloaded

from mcp import Client  # noqa: E402

from gridpin_mcp import server  # noqa: E402

EXPECTED = {"list_countries", "download_sheet", "geocode", "reverse", "batch"}


async def main():
    async with Client(server.build_server()) as client:
        names = {tool.name for tool in (await client.list_tools()).tools}
        missing = await client.call_tool("geocode", {"query": "Via Roma 1, Torino", "country": "it"})
    return names, missing


names, missing = asyncio.run(main())
assert names == EXPECTED, names
assert missing.is_error
text = missing.content[0].text
assert "gridpin-fetch it" in text, text
print("tools:", sorted(names))
print("missing sheet:", text)
