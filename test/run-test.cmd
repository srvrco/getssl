@echo off
IF %1.==. GOTO NoOS
set OS=%1

:CheckCommand
IF %2.==. GOTO NoCmd
set COMMAND=%2 %3

:CheckAlias
REM check if OS *contains* staging
IF NOT x%OS:duck=%==x%OS% GOTO duckdns
IF NOT x%OS:dynu=%==x%OS% GOTO dynu
set ALIAS=%OS%.getssl.test
set STAGING=
set GETSSL_OS=%OS%
GOTO Run

:NoOS
set OS=ubuntu
GOTO CheckCommand

:NoCmd
REM set COMMAND=/getssl/test/run-bats.sh
set COMMAND=bats /getssl/test
GOTO CheckAlias

:duckdns
set ALIAS=%OS:-duckdns=%-getssl.duckdns.org
set STAGING=--env STAGING=true --env dynamic_dns=duckdns
set GETSSL_OS=%OS:-duckdns=%
GOTO Run

:dynu
set ALIAS=%OS:-dynu=%-getssl.freeddns.org
set STAGING=--env STAGING=true --env dynamic_dns=dynu
set GETSSL_OS=%OS:-dynu=%

:Run
for %%I in (.) do set CurrDirName=%%~nxI

docker build --rm -f "test\Dockerfile-%OS%" -t getssl-%OS% .
@echo on
docker run -it ^
  --env GETSSL_HOST=%ALIAS% %STAGING% ^
  --env GETSSL_OS=%GETSSL_OS% ^
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
  --network-alias wild-%ALIAS% ^
  --name getssl-%OS% ^
  getssl-%OS% ^
  %COMMAND%
