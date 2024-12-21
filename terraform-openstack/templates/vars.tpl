# Variable for the MariaDB configuration
mysql_root_password: root

# Variables for the CTFd configuration
ctfd_db_user: ctfd
ctfd_db_password: ctfd
ctfd_db_host: ${db_internal_ip}
ctfd_redis_host: ${redis_internal_ip}
database: MariaDB

# Variables for the Nginx configuration
ctfd_host: ${ctfd_internal_ip}
ctfd_port: 8000
nginx_listen_port: 80
host_port: 8080
