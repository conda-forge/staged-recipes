#include <uuid.h>

int main()
{
    const auto text = "47183823-2574-4bfd-b411-99ed177d3e43";
    const auto parsed = uuids::uuid::from_string(text);
    if (!parsed || uuids::to_string(*parsed) != text || parsed->is_nil())
        return 1;
    if (uuids::uuid::from_string("invalid"))
        return 1;

    std::mt19937 engine{12345};
    const auto random = uuids::uuid_random_generator{engine}();
    if (random.is_nil() || random.as_bytes().size() != 16 ||
        random.version() != uuids::uuid_version::random_number_based ||
        random.variant() != uuids::uuid_variant::rfc)
        return 1;

    const auto dns = uuids::uuid::from_string("6ba7b810-9dad-11d1-80b4-00c04fd430c8");
    if (!dns)
        return 1;
    const auto named = uuids::uuid_name_generator{*dns}("www.widgets.com");
    return uuids::to_string(named) != "21f7f8de-8051-5b89-8680-0195ef798b6a";
}
