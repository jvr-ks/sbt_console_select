@rem test_curl_open_close.bat

@echo off

echo open (TEST) with curl, closing it after 20 seconds ...

curl http://localhost:65505/scs?open=(TEST)  

timeout /T 20

curl http://localhost:65505/scs?close=(TEST)  

