@echo off
IF %1.==. GOTO NoOS
set OS=%1

:CheckCommand
IF %2.==. GOTO NoCmd
set COMMAND=%2 %3

:CheckAlias
IF %OS%==duckdns GOTO duckdns
set ALIAS=%OS%.getssl.test
GOTO Run

:NoOS
set OS=ubuntu
GOTO CheckCommand

:NoCmd
set COMMAND=/getssl/test/run-bats.sh
GOTO CheckAlias

:duckdns
set ALIAS=%OS%.duckdns.org

:Run

docker build --rm -f "test\Dockerfile-%OS%" -t getssl-%OS% .
@echo on
docker run -it ^
  --env GETSSL_HOST=%OS%.getssl.test ^
  -v %cd%:/getssl ^
  --network getssl-timkimber_acmenet ^
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
  %COMMAND%
