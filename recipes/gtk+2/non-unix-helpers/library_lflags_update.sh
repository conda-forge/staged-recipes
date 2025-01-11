unique_from_last() {
  # Function to make a list unique from the last occurrence
  # Accept a single space-separated string as input
  local input_string="$1"
  local seen_l=""           # Tracking seen items for -l strings
  local seen_L=""           # Tracking seen items for -L strings
  local l_list=()           # Array for -l strings
  local L_list=()           # Array for -L strings
  local others=()           # Array for other strings

  # Convert the input string into an array
  IFS=' ' read -r -a list <<< "$input_string"

  # Traverse the list from first to last
  for item in "${list[@]}"; do
    if [[ "$item" == -L* || "$item" == -I* ]]; then
      # -L strings processed from first to last occurrence
      if [[ ! " $seen_L " =~ " $item " ]]; then
        L_list+=("$item")
        seen_L="$seen_L $item"
      fi
    elif [[ "$item" == -l* ]]; then
      # -l strings processed from last to first occurrence
      if [[ ! " $seen_l " =~ " $item " ]]; then
        l_list=("$item" "${l_list[@]}")
        seen_l="$seen_l $item"
      fi
    else
      # Other strings are appended in order of appearance
      others+=("$item")
    fi
  done

  # Assemble the final result: -L first -> others -> -l last
  local result="${L_list[*]} ${others[*]} ${l_list[*]}"

  # Trim and print result
  echo "${result% }"
}

replace_l_flags() {
  # Function to replace -lxxx with a specific path/xxx.lib
  local input_string="$1"  # Get the input string containing linker flags

  # Initialize an empty result
  local result=""

  # Convert the input string into an array of words
  IFS=' ' read -r -a flags <<< "$input_string"

  # Process each "flag" in the input string
  for flag in "${flags[@]}"; do
    if [[ "$flag" == -l* ]] && ! [[ " ${system_libs_exclude[*]} " =~ " ${flag#-l} " ]]; then
      # Replace -lxxx with path/xxx.lib
      local lib_name="${flag#-l}"
      if [[ -f "$host_conda_libs/$lib_name.lib" ]]; then
        result+="$host_conda_libs/$lib_name.lib "
      else
        result+="$build_conda_libs/$lib_name.lib "
      fi
    else
      # Keep everything else (unchanged flags)
      result+="$flag "
    fi
  done

  # Return the modified string (trimmed)
  echo "${result% }"
}

_replace_l_flag_in_file() {
  local file="$1"
  local debug="${2:-false}" # Enables debug if DEBUG is set to 'true'

  if [[ -f "$file" ]]; then
    $debug && echo "Processing file: $file"

    # Temporary file for processing
    tmpfile=$(mktemp) || { echo "Error: Failed to create temp file" >&2; exit 1; }
    $debug && echo "  Created temp file: $tmpfile"

    while IFS= read -r line; do
      if [[ "$line" =~ ^[GIL][[:alnum:]_]*IBS ]]; then
        $debug && echo "  Processing matching line (G*, L*, or I*IBS): $line"
        updated_line=""

        for word in $line; do
          if [[ $word == -l* ]]; then
            flag_name=$(echo "$word" | sed -E 's/(-l[[:alnum:]_\-\.]+)/\1/')
            lib_name=$(echo "$word" | sed -E 's/-l([[:alnum:]_\-\.]+)/\1/')
            escaped_flag_name=$(echo "$flag_name" | sed -E 's/[-\.]/\\&/g')

            $debug && echo "    Found linker flag: $flag_name (library: $lib_name)"

            if [[ $lib_name =~ ^($exclude_regex)$ ]]; then
              $debug && echo "      Library '$lib_name' is excluded. Keeping unchanged."
              updated_line+="$word "
            else
              # Verify if the library file exists before replacing
              if [[ -f "$build_conda_libs/${lib_name}.lib" ]]; then
                $debug && echo "      Found in build_conda_libs: $build_conda_libs/${lib_name}.lib"
                updated_line+=$(echo "$word" | sed -E "s|${escaped_flag_name}|$build_conda_libs/${lib_name}.lib|")
                updated_line+=" "
              elif [[ -f "$host_conda_libs/${lib_name}.lib" ]]; then
                $debug && echo "      Found in host_conda_libs: $host_conda_libs/${lib_name}.lib"
                updated_line+=$(echo "$word" | sed -E "s|${escaped_flag_name}|$host_conda_libs/${lib_name}.lib|")
                updated_line+=" "
              else
                $debug && echo "      Warning: Library file not found for '$lib_name'. Keeping unchanged."
                updated_line+="$word "
              fi
            fi
          else
            updated_line+="$word "
          fi
        done

        $debug && echo "    Updated line: $updated_line"
        echo "$updated_line" >> "$tmpfile"
      else
        # $debug && echo "  Non-matching line: $line"
        echo "$line" >> "$tmpfile"
      fi
    done < "$file"

    # Overwrite the original file with the updated content
    cat "$tmpfile" > "$file" || { echo "Error: Failed to replace original file $file with $tmpfile" >&2; exit 1; }
    $debug && echo "  Successfully updated file: $file"
  else
    $debug && echo "Error: File $file does not exist"
  fi
}

replace_l_flag_in_file() {
  local file="$1"
  local exclude_regex="$2"
  local debug="${3:-false}"
  local host_dir="${4:-${PREFIX}/Library/lib}"
  local build_dir="${5:-${BUILD_PREFIX}/Library/lib}"

  if [[ -f "$file" ]]; then
    $debug && echo "Processing file: $file"

    perl -e '
      use strict;
      use warnings;

      # Read variables passed from the command line arguments
      my $debug = shift @ARGV eq "true" ? 1 : 0;
      my $build_dir = shift @ARGV;
      my $host_dir = shift @ARGV;
      my $exclude_regex = shift @ARGV;

      # Read the file line by line
      while (<>) {
        chomp; # Remove trailing newline
        my $line = $_;

        # Process lines starting with G*, I*, or L* followed by IBS
        if ($line =~ /^[GIL][[:alnum:]_]*IBS/) {
          debug("Processing matching line: $line");
          $line =~ s/-l/ -l/g;
          debug("Processing matching line: $line");

          # Split the line into words and process each word
          my @words = split /\s+/;
          my @updated_line;

          foreach my $word (@words) {
            # If a linker flag (-l*), process it
            if ($word =~ /^-l(.+)/) {
              my $lib_name = $1; # Extract the library name
              debug("  Found linker flag: $word (library: $lib_name)");

              # Check for exclusions or replacements
              if ($lib_name =~ /^($exclude_regex)$/) {
                debug("    Library \"$lib_name\" is excluded. Keeping unchanged.");
                push @updated_line, $word;
              } elsif (-f "$build_dir/$lib_name.lib") {
                debug("    Found in build_conda_libs: $build_dir/$lib_name.lib");
                push @updated_line, "$build_dir/$lib_name.lib";
              } elsif (-f "$host_dir/$lib_name.lib") {
                debug("    Found in host_conda_libs: $host_dir/$lib_name.lib");
                push @updated_line, "$host_dir/$lib_name.lib";
              } else {
                print STDERR "Error: Library \"$lib_name\" not found in any directory.\n";
                exit 1;
                push @updated_line, $word;
              }
            }
            # For non-linker flags, add them unchanged
            else {
              push @updated_line, $word;
            }
          }

          foreach my $word (@updated_line) {
            if ($word =~ /^-l(.+)/) {
              my $lib_name = $1; # Extract library name
              if ($lib_name !~ /$exclude_regex/) {
                # Error out if there is an unresolved -lxxx flag not matching exclude_regex
                print STDERR "Error: Unresolved library \"$word\" found in the updated line and is not excluded.\n";
                exit 1;
              }
            }
          }

          # Print the updated line
          debug("Processed line: " . join(" ", @updated_line));
          print join(" ", @updated_line), "\n";
        }

        # Non-matching lines are printed as-is
        else {
          print $line, "\n";
        }
      }

      # Debugging helper to print messages conditionally
      sub debug {
        my $msg = shift;
        print STDERR "$msg\n" if $debug;
      }
    ' "$debug" "$build_dir" "$host_dir" "$exclude_regex" "$file" > "${file}.tmp" || {
      echo "Error: Failed to process file $file" >&2
      exit 1
    }

    # Overwrite the original file with the updated content
    if [[ -f "${file}.tmp" ]]; then
      cat "${file}.tmp" > "$file" || {
        echo "Error: Failed to replace original file $file with ${file}.tmp" >&2
        exit 1
      }
      # For exit of the script, let's not return 'false' to be able to use set -e
      if [[ "$debug" == "true" ]]; then
        echo "Successfully updated file: $file"
      fi
    else
      if [[ "$debug" == "true" ]]; then
        echo "Not modified fpr -lxxx: $file"
      fi
    fi
  else
    echo "Error: File $file does not exist"
  fi
}

replace_l_flag_in_files() {
  local exclude_regex="$1"
  shift 1
  local files=("$@")
  for file in "${files[@]}"; do
    echo "   Updating: $file"
    replace_l_flag_in_file "$file" "$exclude_regex"
  done
}
