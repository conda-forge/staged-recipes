#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/compiler/plugin.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream_impl.h>
#include <iostream>
#include <string>

class AddExportsGenerator : public google::protobuf::compiler::CodeGenerator {
 public:
  bool Generate(const google::protobuf::FileDescriptor* file,
                const std::string& parameter,
                google::protobuf::compiler::GeneratorContext* context,
                std::string* error) const override {
    std::cerr << "AddExportsGenerator: Processing file " << file->name() << std::endl;

    // Generate a single file with all content
    std::string filename = file->name() + ".export.h";
    std::cerr << "AddExportsGenerator: Generating file " << filename << std::endl;

    std::unique_ptr<google::protobuf::io::ZeroCopyOutputStream> output(context->Open(filename));
    if (!output) {
      *error = "Could not open file for writing: " + filename;
      std::cerr << "AddExportsGenerator: Error - " << *error << std::endl;
      return false;
    }

    google::protobuf::io::Printer printer(output.get(), '$');

    // printer.Print("#pragma once\n\n");
    // printer.Print("namespace $package$ {\n\n", "package", file->package());

    for (int i = 0; i < file->message_type_count(); ++i) {
      const google::protobuf::Descriptor* message = file->message_type(i);
      for (int j = 0; j < message->field_count(); ++j) {
        const google::protobuf::FieldDescriptor* field = message->field(j);
        if (field->is_repeated() || field->cpp_type() == google::protobuf::FieldDescriptor::CPPTYPE_STRING) {
          printer.Print("DYDX_V4_PROTO_API $type$* $message$::mutable_$field$();\n",
                        "type", (field->cpp_type() == google::protobuf::FieldDescriptor::CPPTYPE_STRING) ? "std::string" : field->cpp_type_name(),
                        "message", message->name(),
                        "field", field->name());
        }
      }
      printer.Print("\n");
    }

    // printer.Print("} // namespace $package$\n", "package", file->package());

    return true;
  }
};

int main(int argc, char* argv[]) {
  std::cerr << "AddExportsGenerator: Plugin started" << std::endl;
  AddExportsGenerator generator;
  return google::protobuf::compiler::PluginMain(argc, argv, &generator);
}
