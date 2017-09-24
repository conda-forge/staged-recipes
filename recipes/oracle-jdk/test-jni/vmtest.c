#include <jni.h>
#include <string.h>


int main(int argc, char** args)
{
	JavaVM *vm;
	JavaVMInitArgs vm_args;
	JNIEnv *env;

	memset(&vm_args, 0, sizeof(vm_args));

	vm_args.version = JNI_VERSION_1_2;

	return JNI_CreateJavaVM(&vm, (void**)&env, &vm_args);
}
