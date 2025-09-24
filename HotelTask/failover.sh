docker exec -i mysql-secondary mysql -uroot -prootpassword -e "SET GLOBAL read_only = OFF;"
