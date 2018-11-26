import jgo.jgo
import os
import psutil
import sys

__paintera_version__                   = '0.8.2'
__slf4j_version__                      = '1.7.25'

__paintera_show_container__            = '@PainteraShowContainer'

repositories = {
    'saalfeldlab'   : 'https://saalfeldlab.github.io/maven',
    'imagej.public' : 'https://maven.imagej.net/content/groups/public'
    }

def add_jvm_args_as_necessary(argv, set_gc_option=True):
    gc_option = '-XX:+UseConcMarkSweepGC'

    if set_gc_option and not gc_option in argv:
        argv += [gc_option]

    for arg in argv:
        if '-Xmx' in arg:
            return argv

    total_memory  = psutil.virtual_memory().total
    exponent      = 3 if total_memory > 2*1024**3 else 2
    memory_unit   = 'G' if exponent == 3 else 'M'
    max_heap_size = os.getenv(
        'PAINTERA_MAX_HEAP_SIZE',
        '{}{}'.format(max(total_memory // (1024**exponent) // 2, 1), memory_unit))

    argv = ['-Xmx{}'.format(max_heap_size)] + argv

    return argv


def jgo_paintera():
    argv               = sys.argv[1:]
    double_dash_index  = [i for (i, arg) in enumerate(argv) if arg == '--'][0] if '--' in argv else -1
    jgo_and_jvm_argv   = ([] if double_dash_index < 0 else argv[:double_dash_index]) + ['--ignore-jgorc']
    repository_strings = ['-r'] + ['{}={}'.format(k, v) for (k, v) in repositories.items()]
    endpoint           = ['org.janelia.saalfeldlab:paintera:{}+{}'.format(__paintera_version__, os.getenv('PAINTERA_SLF4J_BINDING', 'org.slf4j:slf4j-simple:{}'.format(__slf4j_version__)))]
    paintera_argv      = argv if double_dash_index < 0 else argv[double_dash_index+1:]
    argv               = add_jvm_args_as_necessary(jgo_and_jvm_argv, set_gc_option=True) + repository_strings + endpoint + paintera_argv

    jgo.jgo.jgo_main(argv)

def jgo_paintera_show_container():
    argv               = sys.argv[1:]
    double_dash_index  = [i for (i, arg) in enumerate(argv) if arg == '--'][0] if '--' in argv else -1
    jgo_and_jvm_argv   = ([] if double_dash_index < 0 else argv[:double_dash_index]) + ['--ignore-jgorc']
    repository_strings = ['-r'] + ['{}={}'.format(k, v) for (k, v) in repositories.items()]
    endpoint           = ['org.janelia.saalfeldlab:paintera:{}:{}+{}'.format(__paintera_version__, __paintera_show_container__, os.getenv('PAINTERA_SLF4J_BINDING', 'org.slf4j:slf4j-simple:{}'.format(__slf4j_version__)))]
    paintera_argv      = argv if double_dash_index < 0 else argv[double_dash_index+1:]
    argv               = add_jvm_args_as_necessary(jgo_and_jvm_argv, set_gc_option=True) + repository_strings + endpoint + paintera_argv

    jgo.jgo.jgo_main(argv)

def jgo_paintera_conversion_helper():
    argv                   = sys.argv[1:]
    double_dash_index      = [i for (i, arg) in enumerate(argv) if arg == '--'][0] if '--' in argv else -1
    jgo_and_jvm_argv       = ([] if double_dash_index < 0 else argv[:double_dash_index]) + ['--ignore-jgorc']
    repository_strings     = ['-r'] + ['{}={}'.format(k, v) for (k, v) in repositories.items()]
    endpoint               = ['org.janelia.saalfeldlab:paintera-conversion-helper:{}'.format(__paintera_conversion_helper_version__)]
    spark_master           = ['-Dspark.master={}'.format(os.getenv('SPARK_MASTER', 'local[*]'))]
    conversion_helper_argv = argv if double_dash_index < 0 else argv[double_dash_index+1:]
    argv                   = add_jvm_args_as_necessary(jgo_and_jvm_argv + spark_master, set_gc_option=True) + repository_strings + endpoint + conversion_helper_argv

    jgo.jgo.jgo_main(argv)

