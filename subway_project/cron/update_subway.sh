#!/bin/bash

# --------------------------------------
# 실시간 도착정보를 가져와 index.html 생성 및
# 히스토리 html 및 txt 백업 생성, list.html 갱신
# --------------------------------------

API_KEY="525a484c616a6a793536636450436d"
STATION=$(cat /usr/src/app/data/station.txt | tr -d '\r\n' | xargs)
[ -z "$STATION" ] && exit 0

ENCODED=$(echo -n "$STATION" | jq -sRr @uri)
URL="http://swopenapi.seoul.go.kr/api/subway/$API_KEY/xml/realtimeStationArrival/1/5/$ENCODED"
RESPONSE=$(curl -s "$URL")

# 1) 응답 XML 저장
mkdir -p /usr/src/app/html
echo "$RESPONSE" > /usr/src/app/html/response.xml

# 2) index.html 생성
TIMESTAMP=$(TZ=Asia/Seoul date '+%Y-%m-%d %H:%M:%S')
NOW_FILENAME=$(TZ=Asia/Seoul date '+%Y-%m-%d_%H-%M-%S')
TXT_TIMESTAMP=$(TZ=Asia/Seoul date '+%Y-%m-%d_%H_%M_%S')

cat <<EOF > /usr/src/app/html/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${STATION} 도착 정보</title>
  <style>
    body { font-family: sans-serif; padding: 20px; }
    h1 { color: #333; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #999; padding: 8px; text-align: center; }
    th { background-color: #eee; }
  </style>
</head>
<body>
<h1>🚉 ${STATION} 실시간 도착 정보</h1>
<p>🕒 API 요청 시각: ${TIMESTAMP}</p>
EOF

# ─ 상행 열차 테이블
echo "<h2>🚈 상행 열차</h2><table><tr><th>종착역</th><th>도착 예정</th><th>급행 여부</th></tr>" \
  >> /usr/src/app/html/index.html
UP_COUNT=$(echo "$RESPONSE" | xmllint --xpath 'count(//row[updnLine="상행"])' - 2>/dev/null || echo 0)
for i in $(seq 1 $UP_COUNT); do
  DEST=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='상행'][$i]/trainLineNm)" -)
  ARRIVE=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='상행'][$i]/barvlDt)" -)
  EXPRESS=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='상행'][$i]/btrainSttus)" -)
  MSG=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='상행'][$i]/arvlMsg2)" -)

  [ -z "$ARRIVE" ] && continue
  if [ "$ARRIVE" -gt 0 ]; then
    TIMEINFO="$((ARRIVE / 60)) 분 후"
  else
    TIMEINFO="$MSG"
  fi
  EXPRESS_LABEL=$([ "$EXPRESS" = "급행" ] && echo "🚄 급행" || echo "")

  echo "<tr><td>${DEST}</td><td>${TIMEINFO}</td><td>${EXPRESS_LABEL}</td></tr>" \
    >> /usr/src/app/html/index.html
done
echo "</table>" >> /usr/src/app/html/index.html

# ─ 하행 열차 테이블
echo "<h2>🚇 하행 열차</h2><table><tr><th>종착역</th><th>도착 예정</th><th>급행 여부</th></tr>" \
  >> /usr/src/app/html/index.html
DOWN_COUNT=$(echo "$RESPONSE" | xmllint --xpath 'count(//row[updnLine="하행"])' - 2>/dev/null || echo 0)
for i in $(seq 1 $DOWN_COUNT); do
  DEST=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='하행'][$i]/trainLineNm)" -)
  ARRIVE=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='하행'][$i]/barvlDt)" -)
  EXPRESS=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='하행'][$i]/btrainSttus)" -)
  MSG=$(echo "$RESPONSE" | xmllint --xpath "string(//row[updnLine='하행'][$i]/arvlMsg2)" -)

  [ -z "$ARRIVE" ] && continue
  if [ "$ARRIVE" -gt 0 ]; then
    TIMEINFO="$((ARRIVE / 60)) 분 후"
  else
    TIMEINFO="$MSG"
  fi
  EXPRESS_LABEL=$([ "$EXPRESS" = "급행" ] && echo "🚄 급행" || echo "")

  echo "<tr><td>${DEST}</td><td>${TIMEINFO}</td><td>${EXPRESS_LABEL}</td></tr>" \
    >> /usr/src/app/html/index.html
done
echo "</table>" >> /usr/src/app/html/index.html

# 3) 히스토리 보기 링크만 삽입
echo "<p style=\"margin-top:20px;\"><a href=\"/history/list.html\">📜 히스토리 보기</a></p>" \
  >> /usr/src/app/html/index.html
echo "</body></html>" >> /usr/src/app/html/index.html

# 4) 히스토리 html, txt 백업 만들기
mkdir -p /usr/src/app/html/history
mkdir -p /usr/src/app/data

# index.html 내 히스토리 링크 삭제하고 메인으로가기 추가
sed -e '/<p style="margin-top:20px;"><a href="\/history\/list.html">📜 히스토리 보기<\/a><\/p>/d' \
    -e '$a\<p style="margin-top:20px;"><a href="\/search.html">⬅️ 메인으로</a></p>' \
    /usr/src/app/html/index.html \
    > /usr/src/app/html/history/${STATION}_${NOW_FILENAME}.html

# 텍스트 백업
echo "$RESPONSE" > /usr/src/app/data/${STATION}_${TXT_TIMESTAMP}.txt

# 5) 히스토리 목록 list.html 생성/갱신
HISTORY_DIR="/usr/src/app/html/history"
LIST_FILE="$HISTORY_DIR/list.html"

echo "<!DOCTYPE html>
<html>
<head><meta charset='utf-8'><title>히스토리 목록</title></head>
<body>
<h1>📜 히스토리 파일 목록</h1>
<ul>" > "$LIST_FILE"

for file in $(ls -1 $HISTORY_DIR/*.html | grep -v 'list.html' | sort -r); do
  fname=$(basename "$file")
  echo "<li><a href=\"/history/$fname\">$fname</a></li>" >> "$LIST_FILE"
done

echo "</ul>
<p><a href=\"/search.html\">⬅️ 메인으로</a></p>
</body>
</html>" >> "$LIST_FILE"
