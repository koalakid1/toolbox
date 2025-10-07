# Toolbox 폴더 관리 규칙

새로운 도구 폴더 추가 시 준수해야 할 규칙과 절차입니다.

---

## 📋 새 도구 폴더 추가 절차

### 1. 폴더 생성

```bash
mkdir -p toolbox/{tool-name}/
```

### 2. 필수 파일 작성

#### 2.1 실행 스크립트
```bash
# 도구의 메인 스크립트
toolbox/{tool-name}/*.sh
```

#### 2.2 기술 문서 (`.claude.md`)
각 스크립트에 대한 개발자/AI용 상세 문서:
```bash
toolbox/{tool-name}/{script-name}.claude.md
```

**포함 내용:**
- 목적
- 주요 기능
- 기술적 세부사항
- 코드 패턴
- 에러 처리 로직

#### 2.3 사용자 가이드 (`README.md`)
```bash
toolbox/{tool-name}/README.md
```

**포함 내용:**
- 빠른 시작
- 사용법
- 예시
- 트러블슈팅

---

## 📝 문서 업데이트

### 3. toolbox 루트 README 업데이트

**파일:** `toolbox/README.md`

**추가 위치:** "포함된 도구" 섹션

**형식:**
```markdown
### 🔧 [{도구명}/]({폴더명}/)
{도구 설명}

- {주요 기능 1}
- {주요 기능 2}
- {주요 기능 3}

**📖 [자세히 보기]({폴더명}/README.md)**
```

**예시:**
```markdown
### 🐳 [docker/](docker/)
Docker 환경 설정 및 컨테이너 관리 도구

- Docker Compose 템플릿 생성
- 컨테이너 자동 배포
- 환경별 설정 관리

**📖 [자세히 보기](docker/README.md)**
```

---

## 🏷️ .claude/context.md 업데이트

### 4. 태그 추가 (필요시)

**파일:** `toolbox/.claude/context.md`

**추가 위치:** "프로세스별 필수 참고 문서" 섹션

**형식:**
```markdown
### [{태그명}]
- `.claude/info/{규칙파일}.md` - {설명}
```

**예시:**
```markdown
### [Docker 설정]
- `.claude/info/docker-rules.md` - Docker 설정 규칙
```

### 5. 도구 목록 업데이트

**파일:** `toolbox/.claude/context.md`

**추가 위치:** "향후 추가 예정" 섹션을 "도구 목록"으로 변경

**형식:**
```markdown
## 📦 포함된 도구

### 활성화된 도구
- `git/` - GitHub 멀티 계정 관리
- `docker/` - Docker 환경 설정
- ...

### 계획 중
- `db/` - 데이터베이스 관리
- `deploy/` - 배포 자동화
- ...
```

---

## 🔧 도구별 규칙 파일 생성 (선택)

### 6. `.claude/info/{tool}-rules.md` 생성

도구가 복잡하거나 특정 규칙이 많은 경우:

```bash
# 예시: Docker 규칙
.claude/info/docker-rules.md
```

**포함 내용:**
- 도구 사용 규칙
- 코딩 패턴
- 베스트 프랙티스
- 주의사항

---

## ✅ 체크리스트

새 도구 폴더 추가 시 다음을 확인:

- [ ] 폴더 생성: `toolbox/{tool-name}/`
- [ ] 스크립트 작성: `{tool-name}/*.sh`
- [ ] 기술 문서: `{tool-name}/*.claude.md`
- [ ] 사용자 가이드: `{tool-name}/README.md`
- [ ] **toolbox/README.md** 업데이트 (도구 설명 추가)
- [ ] **.claude/context.md** 업데이트
  - [ ] 태그 추가 (필요시)
  - [ ] 도구 목록 업데이트
- [ ] `.claude/info/{tool}-rules.md` 생성 (선택)
- [ ] 테스트 및 검증

---

## 📌 실제 예시

### git/ 도구 (참고용)

**구조:**
```
toolbox/git/
├── install-required-tools.sh
├── install-required-tools.claude.md
├── setup-account.sh
├── setup-account.claude.md
├── clone-repo.sh
├── clone-repo.claude.md
├── README.md
├── SSH_GPG_SETUP.md
├── CLONE_GUIDE.md
└── SETUP_GUIDE.md
```

**toolbox/README.md:**
```markdown
### 🔧 [git/](git/)
GitHub 멀티 계정 관리 및 레포지토리 자동 클론 도구

- SSH/GPG 키 자동 생성 및 설정
- 계정별 Git 설정 자동 전환
- 대화형 레포지토리 클론 (fzf 기반)
- 개인/조직 레포 자동 분류

**📖 [자세히 보기](git/README.md)**
```

**.claude/context.md:**
```markdown
### [스크립트 수정]
- `.claude/info/bash-patterns.md` - Bash 스크립트 패턴 및 규칙
```

**.claude/info/bash-patterns.md:**
- fzf 패턴
- 배열 처리
- 경로 사용 등

---

## 🎯 작업 자동화

새 도구 추가 시 Claude에게 다음과 같이 요청:

```
[추가] {도구명} 도구 추가
- 기능: {기능 설명}
- 스크립트: {스크립트 목록}

다음을 자동으로 수행해주세요:
1. toolbox/README.md 업데이트
2. .claude/context.md 업데이트
3. 필요시 규칙 파일 생성
```

Claude가 이 규칙 파일을 참고하여 자동으로 모든 문서를 업데이트합니다.

---

## 🔄 유지보수

### 도구 제거 시

1. 폴더 삭제: `rm -rf toolbox/{tool-name}`
2. `toolbox/README.md`에서 도구 섹션 제거
3. `.claude/context.md`에서 태그 및 목록 제거
4. `.claude/info/{tool}-rules.md` 삭제 (있다면)

### 도구 업데이트 시

1. 기능 추가 시 `README.md` 업데이트
2. 새 스크립트 추가 시 `.claude.md` 작성
3. 중요 규칙 변경 시 `.claude/info/{tool}-rules.md` 업데이트

---

**작성일:** 2025-10-07
**규칙 추가자:** koalakid
