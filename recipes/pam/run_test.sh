mkdir -p "$PREFIX/etc/pam.d"
test ! -e "$PREFIX/etc/pam.d/other"

cat <<EOF > "$PREFIX/etc/pam.d/other" 
#%PAM-1.0
auth	 required	pam_deny.so
account	 required	pam_deny.so
password required	pam_deny.so
session	 required	pam_deny.so
EOF

make check
