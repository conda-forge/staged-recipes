<#
First backup the variable(s) if they are set.
Variables are allowed to be empty (indicates unset)
Then set the variable(s) to the appropriate locations for this package.
The deactivate script restores the backed up variable(s).
#>

<#
NB: we use the literal string "ENV_VAR_UNSET" for a backup to indicate the
variable was not previously set, as otherwise the backup variable would itself
be unset and the deactivate script would not be able to tell when to return a
variable to the unset state.
#>

if ($env:SCALA_HOME) {
    $Env:SCALA_HOME_CONDA_BACKUP = "$env:SCALA_HOME"
} else {
    $Env:SCALA_HOME_CONDA_BACKUP = "ENV_VAR_UNSET"
}
$Env:SCALA_HOME = "$env:CONDA_PREFIX\libexec\scala2"
