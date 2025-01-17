#!/usr/bin/env python3
import sys
import re


def convert_path(path):
    # Convert backslashes to forward slashes for Linux
    return path.replace('\\', '/')

def process_line(line):
    if include_match := re.search(r'Include="([^"]+)"', line):
        old_path = include_match[1]
        new_path = convert_path(old_path)
        line = line.replace(f'Include="{old_path}"', f'Include="{new_path}"')
    return line

def get_constants(content):
    match = re.search(r'<DefineConstants>(.*?)</DefineConstants>', content)
    return match[1] if match else ''

def convert_project(pkg, dotnet_version, output_file=None):
    # Create new project file
    if pkg == 'generator':
        output_type = 'Exe'
        root_namespace = 'GtkSharp.Generation'
        project_references = []
    else:
        output_type = 'Library'
        root_namespace = f"GtkSharp.{pkg.capitalize()}"
        project_references = [('../glib/glib.csproj', 'glib')] if pkg in ['cairo', 'pango'] else []


    input_file = f"{pkg}/{pkg}.csproj"
    if output_file is None:
        output_file = input_file

    # Read the original content
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    constants = get_constants(content)

    new_content = [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<Project Sdk="Microsoft.NET.Sdk">',
        '  <PropertyGroup>',
        f'    <TargetFramework>net{dotnet_version}</TargetFramework>',
        f'    <OutputType>{output_type}</OutputType>',
        '    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>',
        f'    <RootNamespace>{root_namespace}</RootNamespace>',
        f'    <AssemblyName>{pkg}</AssemblyName>',
        f'    <DefineConstants>{constants}</DefineConstants>' if constants else '',
        '    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>',
        '    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>',
        '    <SignAssembly>true</SignAssembly>',
        '    <AssemblyOriginatorKeyFile>../gtk-sharp.snk</AssemblyOriginatorKeyFile>',
        '    <InvariantGlobalization>true</InvariantGlobalization>',
        '    <NoWarn>$(NoWarn);MSB3243</NoWarn>',
        '  </PropertyGroup>',
        '  <ItemGroup>',
        '    <PackageReference Include="System.Runtime" Version="4.3.1" />    <Reference Include="System" />',
        '    <Reference Include="System.Xml" />',
        '  </ItemGroup>',
    ]

    if project_references:
        new_content.extend(
            (
                '  <ItemGroup>',
                f'    <ProjectReference Include="{project_references[0]}">',
                f'      <Name>{project_references[1]}</Name>',
                '    </ProjectReference>',
                '  </ItemGroup>',
            )
        )
    # Extract all ItemGroup sections with their content
    item_groups = re.findall(r'<ItemGroup>(.*?)</ItemGroup>', content, re.DOTALL)
    for group in item_groups:
        if '<Reference Include="System"' not in group:  # Skip the System references group
            new_content.append('  <ItemGroup>')

            # Split into lines and process each line
            lines = [line.strip() for line in group.strip().split('\n') if line.strip()]
            indent = 4  # Start with base indentation

            for line in lines:
                # Reduce indent for closing tags
                if '</' in line:
                    indent -= 2

                # Add the line with current indentation
                processed_line = process_line(line)
                new_content.append(' ' * indent + processed_line)

                # Increase indent after opening tag that isn't self-closing
                if line.startswith('<') and not line.startswith('</') and not line.endswith('/>'):
                    indent += 2

            new_content.append('  </ItemGroup>')

    new_content.append('</Project>')

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(new_content))


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python script.py input.csproj dotnet_version [output.csproj]")
        sys.exit(1)

    pkg = sys.argv[1]
    dotnet_version = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else None

    convert_project(pkg, dotnet_version, output_file)