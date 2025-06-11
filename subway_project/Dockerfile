# Nginx를 기반 이미지로 사용하는 Alpine 기반의 경량 웹 서버 이미지
FROM nginx:alpine

# 필요한 패키지 설치:
# - fcgiwrap: CGI 스크립트를 FastCGI로 실행
# - spawn-fcgi: 소켓 바인딩 도구
# - bash: start.sh 및 기타 스크립트 실행
# - tzdata: 타임존 설정
# - libxml2-utils: xmllint 포함 (XML 파싱용)
# 서울 시간대로 설정
# 시스템 타임존 지정
RUN apk add --no-cache fcgiwrap spawn-fcgi bash tzdata libxml2-utils \
    && cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime \   
    && echo "Asia/Seoul" > /etc/timezone                    
# Nginx 설정파일과 CGI 스크립트, 실행 스크립트 복사
# 사용자 정의 Nginx 설정
# CGI 스크립트 디렉토리
# fcgiwrap + nginx 실행 스크립트
COPY nginx.conf /etc/nginx/nginx.conf           
COPY cgi-bin /usr/src/app/cgi-bin               
COPY start.sh /start.sh                         

# 실행 권한 부여:
# - Subway_search: CGI 실행 파일
# - start.sh: 컨테이너 시작 시 실행되는 엔트리포인트
RUN chmod +x /usr/src/app/cgi-bin/Subway_search \
    && chmod +x /start.sh

# 컨테이너 시작 시 start.sh 실행 (fcgiwrap + nginx 시작)
CMD ["/start.sh"]
