mkdir -p "${CONDA_PREFIX}/var/run/redis"
mkdir -p "${CONDA_PREFIX}/var/db/redis"

sed -i -e "s:/var/run/redis_6379.pid:${CONDA_PREFIX}/var/run/redis.pid:g" "${CONDA_PREFIX}/etc/redis.conf"
sed -i -e "s:dir ./:dir ${CONDA_PREFIX}/var/db/redis/:g" "${CONDA_PREFIX}/etc/redis.conf"