#define MCAP_IMPLEMENTATION
#include <mcap/reader.hpp>
#include <mcap/writer.hpp>

#include <cstdio>
#include <string>

// Write a small file with each compression backend and read it back, so both
// lz4 and zstd are actually linked and exercised.
static int roundtrip(mcap::Compression compression, const char* filename)
{
    {
        mcap::McapWriterOptions options("test");
        options.compression = compression;
        options.forceCompression = true;
        mcap::McapWriter writer;
        if (!writer.open(filename, options).ok())
            return 1;
        mcap::Schema schema("Text", "jsonschema", "{}");
        writer.addSchema(schema);
        mcap::Channel channel("/chatter", "json", schema.id);
        writer.addChannel(channel);
        const std::string payload = "{\"data\": \"hello\"}";
        for (uint32_t i = 0; i < 100; ++i)
        {
            mcap::Message msg;
            msg.channelId = channel.id;
            msg.sequence = i;
            msg.logTime = i;
            msg.publishTime = i;
            msg.data = reinterpret_cast<const std::byte*>(payload.data());
            msg.dataSize = payload.size();
            if (!writer.write(msg).ok())
                return 1;
        }
        writer.close();
    }

    mcap::McapReader reader;
    if (!reader.open(filename).ok())
        return 1;
    size_t count = 0;
    for (const auto& view : reader.readMessages())
    {
        if (view.channel->topic != "/chatter")
            return 1;
        ++count;
    }
    reader.close();
    std::printf("%s: read %zu messages\n", filename, count);
    return count == 100 ? 0 : 1;
}

int main()
{
    std::printf("libmcap %s\n", mcap::LibraryVersion);
    if (roundtrip(mcap::Compression::Zstd, "test_zstd.mcap") != 0)
        return 1;
    if (roundtrip(mcap::Compression::Lz4, "test_lz4.mcap") != 0)
        return 1;
    return 0;
}
