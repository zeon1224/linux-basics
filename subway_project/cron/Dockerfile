FROM alpine:latest

# 필요한 패키지 설치: curl, bash, jq, tzdata, xmllint
RUN apk add --no-cache curl bash jq tzdata libxml2-utils busybox \
 && cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime \
 && echo "Asia/Seoul" > /etc/timezone

WORKDIR /usr/src/app

# 스크립트 복사 및 실행 권한 부여
COPY update_subway.sh .
RUN chmod +x update_subway.sh

# crontab 설정: 1분마다 update_subway.sh 실행
RUN echo "* * * * * /usr/src/app/update_subway.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# cron 데몬을 포그라운드로 실행
CMD ["crond", "-f", "-L", "/dev/stdout"]
