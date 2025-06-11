#!/bin/sh

# cgi-bin 디렉토리 내부의 모든 파일 및 디렉토리에 실행 권한(755)을 부여합니다.
# 사용자: 읽기/쓰기/실행, 그룹 및 기타: 읽기/실행 권한.
chmod -R 755 /usr/src/app/cgi-bin

# FastCGI 프로세스를 소켓 기반으로 실행합니다.
# -s /tmp/fcgiwrap.socket : UNIX 도메인 소켓을 /tmp 위치에 생성
# -U nginx : fcgiwrap 프로세스를 nginx 사용자로 실행
# -G nginx : fcgiwrap 프로세스를 nginx 그룹으로 실행
# -- /usr/bin/fcgiwrap : 실행할 fcgiwrap 바이너리 지정
spawn-fcgi -s /tmp/fcgiwrap.socket -U nginx -G nginx -- /usr/bin/fcgiwrap

# 소켓이 생성되기 전에 권한 설정을 시도하면 실패할 수 있으므로,
# 약간의 지연을 줘서 소켓 생성 완료를 기다립니다.
sleep 0.5

# 생성된 소켓의 권한을 666으로 변경하여 모든 사용자(nobody 포함)가 읽기/쓰기 가능하게 합니다.
# 이는 nginx가 fcgiwrap 소켓에 접근할 수 있도록 보장합니다.
chmod 666 /tmp/fcgiwrap.socket

# nginx를 포그라운드 모드로 실행하여 Docker 등의 환경에서 컨테이너가 종료되지 않도록 합니다.
nginx -g 'daemon off;'
