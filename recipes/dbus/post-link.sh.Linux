if [ ! -f /etc/machine-id ]; then
    echo "dbus post-link :: /etc/machine-id not found .." >> ${PREFIX}/.messages.txt
    if [ ! -d ${PREFIX}/var/lib/dbus ]; then
        mkdir -p ${PREFIX}/var/lib/dbus
    fi
    if [ -f /proc/sys/kernel/random/boot_id ]; then
        echo "dbus post-link :: .. using /proc/sys/kernel/random/boot_id" >> ${PREFIX}/.messages.txt
        cat /proc/sys/kernel/random/boot_id | tr -d '-' > ${PREFIX}/var/lib/dbus/machine-id
    else
        echo "dbus post-link :: .. /proc/sys/kernel/random/boot_id not found either .." >> ${PREFIX}/.messages.txt
        echo "dbus post-link :: .. using /dev/random" >> ${PREFIX}/.messages.txt
        od -N16 -An -tx1 < /dev/random | tr -d '[:space:]' > ${PREFIX}/var/lib/dbus/machine-id
    fi
fi
