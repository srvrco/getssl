@echo off
IF %1.==. GOTO NoOS
set OS=%1
IF %2.==. GOTO NoNGINX
set NGINX=%2%
IF %3.==. GOTO NoIP
set IP=%3
IF %4.==. GOTO NoAlias
set ALIAS=%4
GOTO Run

:NoOS
    set OS=ubuntu
:NoNGINX
    set NGINX=/etc/nginx/sites-enabled/default
:NoIP
    set IP=13
:NoAlias
    set ALIAS=%OS%.getssl.test

:Run

docker build --rm -f "test\Dockerfile-%OS%" -t getssl-%OS% .
@echo on
docker run -it ^
  --env GETSSL_HOST=%OS%.getssl.test ^
  --env GETSSL_IP=10.30.50.%IP% ^
  --env NGINX_CONFIG=%NGINX% ^
  -v %cd%:/getssl ^
  --network getssl-timkimber_acmenet ^
  --ip 10.30.50.%IP% ^
  --network-alias %ALIAS% ^
  --network-alias a.%OS%.getssl.test ^
  --network-alias b.%OS%.getssl.test ^
  --network-alias c.%OS%.getssl.test ^
  --network-alias d.%OS%.getssl.test ^
  --network-alias e.%OS%.getssl.test ^
  --network-alias f.%OS%.getssl.test ^
  --network-alias g.%OS%.getssl.test ^
  --network-alias h.%OS%.getssl.test ^
  --network-alias i.%OS%.getssl.test ^
  --network-alias j.%OS%.getssl.test ^
  --network-alias k.%OS%.getssl.test ^
  getssl-%OS% ^
  /getssl/test/run-bats.sh
