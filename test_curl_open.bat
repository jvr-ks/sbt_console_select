@rem test_curl_open.bat

@echo off

echo open (TEST) with curl ...

rem curl http://localhost:65505/scs?open=(TEST)
"curl.exe" http://localhost:65505/scs?open=(TEST)
rem curl http://127.0.0.1:65505/scs?open=(TEST)  

