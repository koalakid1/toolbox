# Bash 스크립트 패턴 및 규칙

Bash 스크립트 작성 시 준수해야 할 패턴과 규칙입니다.

---

## fzf 파이프라인 패턴

### ✅ 올바른 패턴

```bash
# 배열을 fzf로 전달
selected=$({ printf '%s\n' "${array[@]}"; echo "추가옵션"; } | fzf --height 40% --prompt="선택> ")
```

**핵심:**
- `{ ... }` 그룹 명령 사용
- `;` 세미콜론으로 명령 구분
- 전체를 하나의 파이프로 fzf에 전달

### ❌ 잘못된 패턴

```bash
# && 사용 (배열이 제대로 전달 안 됨)
selected=$(printf '%s\n' "${array[@]}" && echo "추가옵션" | fzf)

# 배열을 직접 전달 (작동 안 함)
selected=$("${array[@]}" | fzf)
```

---

## 경로 사용 규칙

### ✅ 올바른 방법

```bash
# $HOME 사용 (어디서 실행하든 동일)
base_dir="$HOME/github"
config_file="$HOME/.gitconfig"
```

### ❌ 잘못된 방법

```bash
# ~ 사용 (bash 변수 할당에서 작동 안 할 수 있음)
base_dir="~/github"  # 문자 그대로 "~/github"로 해석될 수 있음

# 상대 경로 (현재 위치에 따라 달라짐)
base_dir="./github"  # 현재 디렉토리 기준
```

---

## 배열 처리

### mapfile 사용

```bash
# 명령 결과를 배열로 저장
mapfile -t accounts < <(find "$github_base" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)
```

### 배열 순회

```bash
# 안전한 배열 순회
for item in "${array[@]}"; do
    echo "$item"
done

# 배열 길이
echo "${#array[@]}"
```

### 배열 인덱스

```bash
# 첫 번째 요소
echo "${array[0]}"

# 전체 배열
echo "${array[@]}"
```

---

## 조건문

### 파일/디렉토리 체크

```bash
# 파일 존재 확인
if [ -f "$file_path" ]; then
    echo "파일 있음"
fi

# 디렉토리 존재 확인
if [ -d "$dir_path" ]; then
    echo "디렉토리 있음"
fi

# 파일 없음 확인
if [ ! -f "$file_path" ]; then
    echo "파일 없음"
fi
```

### 명령 성공/실패 확인

```bash
# 명령 존재 확인
if command -v git &> /dev/null; then
    echo "git 설치됨"
fi

# 명령 실행 결과 확인
if git clone "$repo"; then
    echo "클론 성공"
else
    echo "클론 실패"
fi
```

### 문자열 비교

```bash
# 같음
if [ "$var" = "value" ]; then
    echo "같음"
fi

# 다름
if [ "$var" != "value" ]; then
    echo "다름"
fi

# 빈 문자열
if [ -z "$var" ]; then
    echo "비어있음"
fi

# 비어있지 않음
if [ -n "$var" ]; then
    echo "값 있음"
fi

# 패턴 매칭
if [[ "$var" == pattern* ]]; then
    echo "패턴 일치"
fi
```

---

## 에러 처리

### 명령 실패 시 종료

```bash
# 명령 실패 시 에러 코드 1로 종료
if ! command; then
    echo "❌ 에러 메시지"
    exit 1
fi

# 또는
command || { echo "❌ 에러"; exit 1; }
```

### 안전한 변수 사용

```bash
# 변수를 항상 큰따옴표로 감싸기
cd "$directory" || exit 1
rm "$file_path"

# 공백이 있는 경로 처리
path="/path/with spaces/file.txt"
cat "$path"  # ✅ 올바름
cat $path    # ❌ 공백 때문에 3개 파일로 인식
```

---

## Heredoc 사용

### 파일 생성

```bash
# 파일에 여러 줄 작성
cat > "$file" << 'EOF'
첫 번째 줄
두 번째 줄
$variable은 확장 안 됨
EOF

# 변수 확장 허용
cat > "$file" << EOF
첫 번째 줄
$variable은 확장됨
EOF
```

### Git 커밋 메시지

```bash
# 여러 줄 커밋 메시지
git commit -m "$(cat <<'EOF'
커밋 제목

커밋 본문
여러 줄
EOF
)"
```

---

## 사용자 입력

### read 사용

```bash
# 기본 입력
read -p "이름을 입력하세요: " name

# 확인 입력
read -p "계속하시겠습니까? (y/N): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "진행"
fi

# yes 입력 확인
read -p "정말 삭제하시겠습니까? (yes/no): " confirm
if [ "$confirm" = "yes" ]; then
    echo "삭제"
fi
```

---

## 출력

### 에코 vs printf

```bash
# 기본 출력
echo "메시지"

# 줄바꿈 없이
echo -n "메시지"

# 색상 출력
echo "✅ 성공"
echo "❌ 실패"
echo "⚠️  경고"

# 포맷팅
printf "%-20s: %s\n" "제목" "내용"
```

---

## 디버깅

### set 옵션

```bash
# 에러 발생 시 즉시 종료
set -e

# 정의되지 않은 변수 사용 시 에러
set -u

# 파이프 에러 전파
set -o pipefail

# 조합
set -euo pipefail
```

### 디버그 출력

```bash
# 실행되는 명령 출력
set -x

# 특정 구간만
set -x
command1
command2
set +x
```

---

## 실행 권한

### 스크립트 시작

```bash
#!/bin/bash
# 항상 첫 줄에 shebang 추가
```

### 권한 설정

```bash
# 실행 권한 부여
chmod +x script.sh

# 파일 권한 확인
ls -la script.sh
```

---

## 정리

이 규칙들은 toolbox의 모든 bash 스크립트에 적용됩니다:
- `git/clone-repo.sh`
- `git/setup-account.sh`
- `git/install-required-tools.sh`

새 스크립트 작성 시에도 이 패턴을 따라야 합니다.
