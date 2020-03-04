@echo off
IF %1.==. GOTO NoOS
set OS=%1

:CheckCommand
IF %2.==. GOTO NoCmd
set COMMAND=%2 %3

:CheckAlias
IF %OS%==duckdns GOTO duckdns
set ALIAS=%OS%.getssl.test
set STAGING=
GOTO Run

:NoOS
set OS=ubuntu
GOTO CheckCommand

:NoCmd
REM set COMMAND=/getssl/test/run-bats.sh
set COMMAND=bats /getssl/test
GOTO CheckAlias

:duckdns
set ALIAS=getssl.duckdns.org
set STAGING=--env STAGING=true

:Run
for %%I in (.) do set CurrDirName=%%~nxI

docker build --rm -f "test\Dockerfile-%OS%" -t getssl-%OS% .
@echo on
docker run -it ^
  --env GETSSL_HOST=%ALIAS% %STAGING% ^
  -v %cd%:/getssl ^
  --rm ^
  --network %CurrDirName%_acmenet ^
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
  --name getssl-%OS% ^
  getssl-%OS% ^
  %COMMAND%
