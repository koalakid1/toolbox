# info/ 폴더 설명

이 폴더는 프로젝트별 상세 규칙을 저장하는 공간입니다.

---

## 📋 용도

### context.md vs info/*.md

**context.md:**
- 간결한 개요와 참조
- 태그 정의
- 규칙 프로세스 설명

**info/*.md:**
- 상세한 규칙 내용
- 구체적인 패턴
- 예시 코드
- 베스트 프랙티스

---

## 🎯 사용 방법

### 새 규칙 파일 생성 시

```
[규칙 추가] {카테고리} - {규칙 내용}
```

Claude가 자동으로 `.claude/info/{카테고리}.md` 생성

### 파일명 규칙

- 소문자 사용
- 하이픈으로 단어 구분
- 카테고리-주제.md 형식

**예시:**
- `coding-rules.md`
- `git-workflow.md`
- `testing-guide.md`
- `api-standards.md`

---

## 📁 템플릿 기본 파일

### init-integration-guide.md
`/init` 명령어 후 통합 가이드

새 프로젝트에서 공통으로 사용되는 전역 규칙입니다.

---

## 🔄 프로젝트 시작 시

### 1. 템플릿 복사

```bash
# context.md와 info/ 모두 복사
cp claude-template/context.md.template your-project/.claude/context.md
cp -r claude-template/info your-project/.claude/info
```

### 2. 불필요한 파일 제거

프로젝트에 필요없는 규칙 파일 제거:

```bash
# 예: /init 사용 안 하는 경우
rm your-project/.claude/info/init-integration-guide.md
```

### 3. 프로젝트별 규칙 추가

```
[규칙 추가] {카테고리} - {규칙 내용}
```

---

## 💡 Best Practices

### ✅ 좋은 예

**명확한 파일명:**
- `react-component-rules.md`
- `database-query-guidelines.md`

**구조화된 내용:**
```markdown
# 제목

## 규칙 1
- 설명
- 예시
- 안티패턴

## 규칙 2
...
```

### ❌ 나쁜 예

**모호한 파일명:**
- `rules.md` (무슨 규칙?)
- `temp.md` (임시?)

**너무 긴 파일:**
- 하나의 파일에 모든 규칙 몰아넣기
- → 카테고리별로 분리 권장

---

## 📌 참고

- **RULE-SYSTEM-GUIDE.md** - 규칙 시스템 전체 가이드
- **context.md** - 태그 정의 및 규칙 프로세스
