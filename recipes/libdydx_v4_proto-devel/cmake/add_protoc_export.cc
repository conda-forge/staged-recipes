#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/compiler/plugin.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <fstream>
#include <string>

class AddExportsGenerator : public google::protobuf::compiler::CodeGenerator {
 public:
  bool Generate(const google::protobuf::FileDescriptor* file,
                const std::string& parameter,
                google::protobuf::compiler::GeneratorContext* generator_context,
                std::string* error) const override {
    std::string output = "#ifdef DYDX_V4_PROTO_EXPORT\n";
    for (int i = 0; i < file->message_type_count(); ++i) {
      const google::protobuf::Descriptor* message = file->message_type(i);
      output += "class DYDX_V4_PROTO_EXPORT " + message->name() + ";\n";
      for (int j = 0; j < message->field_count(); ++j) {
        const google::protobuf::FieldDescriptor* field = message->field(j);
        output += "DYDX_V4_PROTO_EXPORT std::string* " + message->name() +
                  "::mutable_" + field->name() + "();\n";
      }
    }
    output += "#endif  // DYDX_V4_PROTO_EXPORT\n";

    std::string file_name = file->name() + ".pb.h";
    std::unique_ptr<google::protobuf::io::ZeroCopyOutputStream> stream(
        generator_context->OpenForInsert(file_name, "includes"));

    if (stream) {
      google::protobuf::io::Printer printer(stream.get(), '$');
      printer.Print(output.c_str());
    } else {
      *error = "Failed to open file for writing: " + file_name;
      return false;
    }

    return true;
  }
};

int main(int argc, char* argv[]) {
  AddExportsGenerator generator;
  return google::protobuf::compiler::PluginMain(argc, argv, &generator);
}