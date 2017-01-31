@echo Off
set config=%1
if "%config%" == "" (
   set config=Release
)

set version=
if not "%PackageVersion%" == "" (
   set version=-Version %PackageVersion%
)

REM Build
%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild src/GoldenEye.proj /p:Configuration="Both" /m /v:M /fl /flp:LogFile=msbuild.log;Verbosity=Normal /nr:false  /p:VisualStudioVersion=14.0