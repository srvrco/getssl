echo %time%
run-test.cmd alpine /etc/nginx/conf.d/default.conf 10
run-test.cmd centos6 /etc/nginx/conf.d/default.conf 11
run-test.cmd debian /etc/nginx/sites-enabled/default 12
run-test.cmd ubuntu /etc/nginx/sites-enabled/default 13
run-test.cmd ubuntu16 /etc/nginx/sites-enabled/default 14
run-test.cmd ubuntu18 /etc/nginx/sites-enabled/default 15
run-test.cmd duckdns /etc/nginx/sites-enabled/default 16 getssl.duckdns.org
