# bash_kernel performs dynamic install of the kernelspec

cat > kernel.json << EOM
{
 "argv": [
  "$PREFIX/bin/python",
  "-m",
  "bash_kernel",
  "-f",
  "{connection_file}"
 ],
 "display_name":"Bash",
 "language":"bash",
 "codemirror_mode":"shell",
 "env": {
  "PS1": "$"
 }
}
EOM

jupyter kernelspec install . --name='bash' --sys-prefix --replace > $PREFIX/.messages.txt