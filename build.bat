set executable=ultrasecurity
set output=./binaries
set input=.

REM disable CGO
set CGO_ENABLED=0

ECHO Building windows binaries...
REM windows-x64
set GOOS=windows
set GOARCH=amd64
go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-windows-amd64.exe %input%
REM windows-arm64
set GOOS=windows
set GOARCH=arm64
go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-windows-arm64.exe %input%
REM windows-x86
set GOOS=windows
set GOARCH=386
go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-windows-386.exe %input%

@ Future...
@REM ECHO Building linux binaries...
@REM REM linux-x64
@REM set GOOS=linux
@REM set GOARCH=amd64
@REM go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-linux-amd64 %input%
@REM REM linux-x86
@REM set GOOS=linux
@REM set GOARCH=386
@REM go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-linux-386 %input%
@REM REM linux-arm64
@REM set GOOS=linux
@REM set GOARCH=arm64
@REM go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-linux-arm64 %input%
@REM REM linux-arm
@REM set GOOS=linux
@REM set GOARCH=arm
@REM go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-linux-arm %input%

@REM ECHO Building darwin (osx) x64 binary...
@REM REM darwin-x64
@REM set GOOS=darwin
@REM set GOARCH=amd64
@REM go build -ldflags="-H=windowsgui -s -w" -o %output%/%executable%-darwin-amd64 %input%