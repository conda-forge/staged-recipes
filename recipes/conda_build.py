import os
import click

packages = ['circos', 'hiveplot', 'pandoc-attributes',
            'pandoc-fignos', 'pandoc-xnos', 'pandocfilters',
            'twine', 'lektor']

# for f in os.listdir(os.getcwd()):
#     if ".sh" in f:
#         os.system("bash {0}".format(f))


@click.group()
def cli():
    pass


@click.command()
# @click.option('--name', help="the package to build")
@click.argument('name')
def build(name):
    os.system('rm -r {0}'.format(name))
    os.system('conda skeleton pypi {0}'.format(name))
    os.system('conda build {0}'.format(name))


@click.command()
def build_all():
    click.echo('Building the following packages...')
    click.echo(packages)
    for name in packages:
        build(name=name)


cli.add_command(build)
cli.add_command(build_all)

if __name__ == '__main__':
    cli()
