#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/compiler/plugin.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/io/printer.h>
#include <string>

class AddExportsGenerator : public google::protobuf::compiler::CodeGenerator {
 public:
  bool Generate(const google::protobuf::FileDescriptor* file,
                const std::string& parameter,
                google::protobuf::compiler::GeneratorContext* generator_context,
                std::string* error) const override {
    std::string output;
    for (int i = 0; i < file->message_type_count(); ++i) {
      const google::protobuf::Descriptor* message = file->message_type(i);
      for (int j = 0; j < message->field_count(); ++j) {
        const google::protobuf::FieldDescriptor* field = message->field(j);
        output += "DYDX_V4_PROTO_EXPORT void " + message->name() +
                  "::set_" + field->name() + "();\n";
        std::string temp_output = "DYDX_V4_PROTO_EXPORT ";
        temp_output.append(field->is_repeated() ? "google::protobuf::RepeatedPtrField<std::string>*" : "std::string*");
        temp_output.append(" ");
        temp_output.append(message->name());
        temp_output.append("::mutable_");
        temp_output.append(field->name());
        temp_output.append("();\n");
        output.append(temp_output);
      }
    }

    std::unique_ptr<google::protobuf::io::ZeroCopyOutputStream> stream(
        generator_context->OpenForInsert(file->name() + ".pb.h", "includes"));
    google::protobuf::io::Printer printer(stream.get(), '$');
    printer.Print(output.c_str());

    return true;
  }
};

int main(int argc, char* argv[]) {
  AddExportsGenerator generator;
  return google::protobuf::compiler::PluginMain(argc, argv, &generator);
}
