@echo off
IF %1.==. GOTO NoOS
SET OS=%1

:CheckCommand
IF %2.==. GOTO NoCmd
SET COMMAND=%2 %3

:CheckAlias
REM check if OS *contains* staging
IF NOT x%OS:duck=%==x%OS% GOTO duckdns
IF NOT x%OS:dynu=%==x%OS% GOTO dynu
IF NOT x%OS:bash=%==x%OS% GOTO bash
SET ALIAS=%OS%.getssl.test
SET IDN=%OS%.xn--t-r1a81lydm69gz81r.test
SET STAGING=
SET GETSSL_OS=%OS%
GOTO Run

:NoOS
SET OS=ubuntu
GOTO CheckCommand

:NoCmd
REM SET COMMAND=/getssl/test/run-bats.sh
SET COMMAND=bats /getssl/test --timing
GOTO CheckAlias

:duckdns
SET ALIAS=%OS:-duckdns=%-getssl.duckdns.org
SET STAGING=--env STAGING=true --env dynamic_dns=duckdns
SET GETSSL_OS=%OS:-duckdns=%
GOTO Run

:dynu
SET ALIAS=%OS:-dynu=%-getssl.freeddns.org
SET STAGING=--env STAGING=true --env dynamic_dns=dynu
SET GETSSL_OS=%OS:-dynu=%
GOTO Run

:bash
SET ALIAS=%OS%.getssl.test
SET STAGING=
SET GETSSL_OS=alpine

:Run
FOR %%I in (.) DO SET CurrDirName=%%~nxI

docker build --pull --rm -f "test\Dockerfile-%OS%" -t getssl-%OS% .
IF %ErrorLevel% EQU 1 GOTO End
@echo on
docker run -it ^
  --env GETSSL_HOST=%ALIAS% %STAGING% ^
  --env GETSSL_OS=%GETSSL_OS% ^
  -v %cd%:/getssl ^
  --rm ^
  --network %CurrDirName%_acmenet ^
  --network-alias %ALIAS% ^
  --network-alias %IDN% ^
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

:End
