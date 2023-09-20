"""
   Script which is used to run the actual post-packaging tests for the various
   mcstas sub-packages. Refer to meta.yaml for how it is invoked by conda build.
"""

import os
import pathlib
import shutil
import shlex
import subprocess
import contextlib
import tempfile
import platform

def AbsPath( p ):
    return pathlib.Path(p).absolute().resolve()

conda_prefix_dir = AbsPath( os.environ.get('PREFIX','') )
assert conda_prefix_dir.is_dir()
work_dir = AbsPath('.')

@contextlib.contextmanager
def work_in_tmpdir():
    the_cwd = os.getcwd()
    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            os.chdir(tmpdir)
            yield
    finally:
        os.chdir(the_cwd)

def ensure_files_are_installed( file_list ):
    for f in file_list:
        if not conda_prefix_dir.joinpath( *( f.split('/') ) ).exists():
            raise SystemExit(f'Missing file: {f}')

def launch( cmd, **kwargs ):
    print(f'Invoking command: {cmd}')
    res = subprocess.run( shlex.split(cmd), **kwargs )
    if res.returncode != 0:
        raise SystemExit(f'Command "{cmd}" failed!')
    return res

def query_mcrun_showcfgdir( cfgdirname='resourcedir', must_exist = True ):
    cmd = f'mcrun --showcfg {cfgdirname}'
    res = launch(cmd, capture_output = True, text = True )
    p = pathlib.Path(res.stdout.strip())
    if must_exist and not p.is_dir():
        raise SystemExit(f'Directory returned by "{cmd}" does not exist!')
    return p.absolute().resolve() if p.is_dir() else p.absolute()

def ensure_basic_commands_run( cmdlist ):
    for cmd in cmdlist:
        for c in cmdlist:
            with work_in_tmpdir():
                launch(c)

def run_instrument_file( instrumentfile, parameters = '' ):
    print(f'Testing {instrumentfile} {parameters}')
    f = None
    if hasattr(instrumentfile,'startswith'):
        if instrumentfile.startswith('share/mcstas'):
            f = AbsPath( conda_prefix_dir.joinpath(*instrumentfile.split('/')) )
        elif instrumentfile.startswith('src/'):
            src_dir = work_dir / 'src'
            assert src_dir.is_dir()
            f = AbsPath( src_dir.joinpath(*(instrumentfile.split('/')[1:])) )
    if f is None:
        f = AbsPath( instrumentfile )
    if not f.exists():
        raise SystemExit(f'File not found: {instrumentfile} (resolved: {f})')
    with work_in_tmpdir():
        shutil.copy(f,str(AbsPath('.')))
        launch( f'mcstas {f.name}' )
        pars = '' if not parameters else ' %s'%parameters
        launch( f'mcrun -c {f.name}{pars}' )

def common_tests_for_core_and_mcstas_pkgs( take_instr_file_from_src ):
    mcrun_resourcedir = query_mcrun_showcfgdir( 'resourcedir', must_exist = True )
    query_mcrun_showcfgdir( 'libdir', must_exist = False )
    mcrun_bindir = query_mcrun_showcfgdir( 'bindir', must_exist = True )
    assert mcrun_resourcedir == conda_prefix_dir / 'share' / 'mcstas' / 'resources'
    assert mcrun_bindir == conda_prefix_dir / 'bin'

    ensure_files_are_installed( [
        'bin/mcstas',
        'bin/mcrun',
        'bin/mcgui',
        'share/mcstas/tools/Python/mccodelib/__init__.py',
        'share/mcstas/resources/examples/BNL_H8.instr',
    ] )
    ensure_basic_commands_run( [
        'mcstas --help',
        'mcstas --version',
        'mcrun --showcfg bindir',
        'mcrun --showcfg resourcedir',
        'mcrun --showcfg libdir',
    ] )


    instrprefix = 'src/mcstas-comps' if take_instr_file_from_src else 'share/mcstas/resources'
    run_instrument_file( f'{instrprefix}/examples/BNL_H8.instr', 'lambda=2.36 -s1000 -n1e5')
    #FIXME: FAILS RUNTIME: run_instrument_file( f'{instrprefix}/examples/Union_manual_example.instr', '-s1000 -n1e5')

_sample_data_files = ['share/mcstas/resources/data/Be.laz']

def tests_for_pkg_data():
    ensure_files_are_installed( _sample_data_files )

    forbidden_files = [ 'bin/mcstas',
                        'bin/mcrun',
                        'bin/mcgui',
                       ]

    for f in forbidden_files:
        if conda_prefix_dir.joinpath( *( f.split('/') ) ).exists():
            raise SystemExit(f'Forbidden file installed by for mcstas-data: {f}')

    sharedir = conda_prefix_dir / 'share' / 'mcstas'
    datadir = sharedir / 'resources' / 'data'
    ndata = 0
    for f in ( sharedir ).glob('**/*'):
        if f.is_dir() and ( f in datadir.parents or f == datadir ):
            continue#ignore <prefix>/share/mcstas[/resources[/data]]
        if datadir in f.parents:
            ndata += 1
        else:
            raise SystemExit(f'Forbidden file installed by mcstas-data pkg: {f}')
    if ndata < 20 or ndata > 2000:
        raise SystemExit(f'Unexpected number ({ndata}) of data files installed')


def tests_for_pkg_core():
    if ( conda_prefix_dir / 'share' / 'mcstas' / 'resources' / 'data' ).exists():
        raise SystemExit('share/mcstas/resources/data should not be created by mcstas-core')
    common_tests_for_core_and_mcstas_pkgs( take_instr_file_from_src = True )

def tests_for_pkg_mcstas():

    ensure_files_are_installed( _sample_data_files )

    common_tests_for_core_and_mcstas_pkgs( take_instr_file_from_src = False )

    mcrun_resourcedir = query_mcrun_showcfgdir( 'resourcedir', must_exist = True )
    f_Be_laz = ( mcrun_resourcedir / 'data' / 'Be.laz' ).absolute().resolve()
    if not f_Be_laz.exists():
        raise SystemExit('Did not find Be.laz in expected location')

    if platform.system().lower()=='windows':
        print('Windows detected - skipping NCrystal/MCPL/mpi tests')
        return

    #MPI test:
    run_instrument_file( 'share/mcstas/resources/examples/BNL_H8.instr', 'lambda=2.36 -s1000 -n1e5 --mpi=2')

    #MCPL test:
    run_instrument_file( 'share/mcstas/resources/examples/Test_MCPL_input.instr', '-s1000 repeat=1')
    run_instrument_file( 'share/mcstas/resources/examples/Test_MCPL_output.instr', '-s1000 Ncount=1e3')

    #NCrystal test with NCrystal-shipped data:
    run_instrument_file( 'share/mcstas/resources/examples/NCrystal_example.instr','sample_cfg=Al_sg225.ncmat -s1000 -n1e5' )

    #NCrystal test with data from mcstas-data package:
    #  FIXME: skipped for now since  .laz/.lau/.nxs support no longer enabled by default in NCrystal (requires custom plugin):
    #  run_instrument_file( 'share/mcstas/resources/examples/NCrystal_example.instr','sample_cfg=%s -s1000 -n1e5'%shlex.quote(f_Be_laz) )

    #NCrystal+Union test:
    run_instrument_file( 'share/mcstas/resources/examples/Union_NCrystal_example.instr','-s1000 -n1e5' )


if __name__=='__main__':
    import sys
    name = sys.argv[1] if len(sys.argv)==2 else ''
    if name=='mcstas':
        tests_for_pkg_mcstas()
    elif name=='core':
        tests_for_pkg_core()
    elif name=='data':
        tests_for_pkg_data()
    else:
        raise SystemExit('Please provide a single valid package name (got: %s)'%sys.argv[1:])
