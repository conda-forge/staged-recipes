#!/bin/bash -e
# -e exits on error

# load global shared environment variables
source ./bash-utils/.env
# load global shared bash utility functions into memory
source ./bash-utils/bash_util.sh
# load project specific environment variables
source .env

# ahhhhh yeah ascii art
cat << EOF





                  ###    ########     ###     ######  ##     ## ########
                 ## ##   ##     ##   ## ##   ##    ## ##     ## ##
                ##   ##  ##     ##  ##   ##  ##       ##     ## ##
               ##     ## ########  ##     ## ##       ######### ######
               ######### ##        ######### ##       ##     ## ##
               ##     ## ##        ##     ## ##    ## ##     ## ##
               ##     ## ##        ##     ##  ######  ##     ## ########







               ###    #### ########  ######## ##        #######  ##      ##
              ## ##    ##  ##     ## ##       ##       ##     ## ##  ##  ##
             ##   ##   ##  ##     ## ##       ##       ##     ## ##  ##  ##
            ##     ##  ##  ########  ######   ##       ##     ## ##  ##  ##
            #########  ##  ##   ##   ##       ##       ##     ## ##  ##  ##
            ##     ##  ##  ##    ##  ##       ##       ##     ## ##  ##  ##
            ##     ## #### ##     ## ##       ########  #######   ###  ###






                                                                    dddddddd
        CCCCCCCCCCCCC                                               d::::::d
     CCC::::::::::::C                                               d::::::d
   CC:::::::::::::::C                                               d::::::d
  C:::::CCCCCCCC::::C                                               d:::::d
 C:::::C       CCCCCC   ooooooooooo   nnnn  nnnnnnnn        ddddddddd:::::d   aaaaaaaaaaaaa
C:::::C               oo:::::::::::oo n:::nn::::::::nn    dd::::::::::::::d   a::::::::::::a
C:::::C              o:::::::::::::::on::::::::::::::nn  d::::::::::::::::d   aaaaaaaaa:::::a
C:::::C              o:::::ooooo:::::onn:::::::::::::::nd:::::::ddddd:::::d            a::::a
C:::::C              o::::o     o::::o  n:::::nnnn:::::nd::::::d    d:::::d     aaaaaaa:::::a
C:::::C              o::::o     o::::o  n::::n    n::::nd:::::d     d:::::d   aa::::::::::::a
C:::::C              o::::o     o::::o  n::::n    n::::nd:::::d     d:::::d  a::::aaaa::::::a
 C:::::C       CCCCCCo::::o     o::::o  n::::n    n::::nd:::::d     d:::::d a::::a    a:::::a
  C:::::CCCCCCCC::::Co:::::ooooo:::::o  n::::n    n::::nd::::::ddddd::::::dda::::a    a:::::a
   CC:::::::::::::::Co:::::::::::::::o  n::::n    n::::n d:::::::::::::::::da:::::aaaa::::::a
     CCC::::::::::::C oo:::::::::::oo   n::::n    n::::n  d:::::::::ddd::::d a::::::::::aa:::a
        CCCCCCCCCCCCC   ooooooooooo     nnnnnn    nnnnnn   ddddddddd   ddddd  aaaaaaaaaa  aaaa









               PPPPPPPPPPPPPPPPP   kkkkkkkk
               P::::::::::::::::P  k::::::k
               P::::::PPPPPP:::::P k::::::k
               PP:::::P     P:::::Pk::::::k
                 P::::P     P:::::P k:::::k    kkkkkkkggggggggg   ggggg
                 P::::P     P:::::P k:::::k   k:::::kg:::::::::ggg::::g
                 P::::PPPPPP:::::P  k:::::k  k:::::kg:::::::::::::::::g
                 P:::::::::::::PP   k:::::k k:::::kg::::::ggggg::::::gg
                 P::::PPPPPPPPP     k::::::k:::::k g:::::g     g:::::g
                 P::::P             k:::::::::::k  g:::::g     g:::::g
                 P::::P             k:::::::::::k  g:::::g     g:::::g
                 P::::P             k::::::k:::::k g::::::g    g:::::g
               PP::::::PP          k::::::k k:::::kg:::::::ggggg:::::g
               P::::::::P          k::::::k  k:::::kg::::::::::::::::g
               P::::::::P          k::::::k   k:::::kgg::::::::::::::g
               PPPPPPPPPP          kkkkkkkk    kkkkkkk gggggggg::::::g
                                                               g:::::g
                                                   gggggg      g:::::g
                                                   g:::::gg   gg:::::g
                                                    g::::::ggg:::::::g
                                                     gg:::::::::::::g
                                                       ggg::::::ggg
                                                          gggggg








EOF

: '
--------------------------------------------------------------------------------
usage documentation:

  ./bash_util.sh -h

parameters
  $1 - help
       valid values: help, --help, -help, h, --h, -h

usage:
- display bash_util usage documentation:
./bash_util.sh -h

- load bash_util script functions into memory:
source bash_util.sh

- display usage documentation for a specific function:
-     <function_name> -h
conda_shazam -h
--------------------------------------------------------------------------------
'

# special parameter "$@" - which will expand to the
# arguments of the command line you specify,
# when used alone the shell will try to call the
# command line arguments verbatim enabling supplying
# a function name as the first argument to execute the function.
# Example:  bash bash_util.sh dags_publish
"$@"
