# koalakid-toolbox

개발 환경 설정 및 자동화를 위한 개인 도구 모음

---

## 📦 도구 목록

### 🔧 [git/](git/)
GitHub 멀티 계정 관리 및 레포지토리 자동 클론 도구

**주요 기능:**
- SSH/GPG 키 자동 생성 및 설정
- 계정별 Git 설정 자동 전환
- 대화형 레포지토리 클론 (fzf 기반)
- 개인/조직 레포 자동 분류

**스크립트:**
- `install-required-tools.sh` - 필수 도구 설치 안내
- `setup-account.sh` - 계정 설정 자동화
- `clone-repo.sh` - 레포지토리 대화형 클론

**📖 [자세히 보기](git/README.md)**

---

## 🚀 빠른 시작

### Git 멀티 계정 설정
```bash
cd ~/github/koalakid1/toolbox/git
./install-required-tools.sh  # 1. 필수 도구 설치
./setup-account.sh           # 2. 계정 설정
./clone-repo.sh              # 3. 레포 클론
```

---

## 💡 Alias 설정 (선택사항)

스크립트를 어디서든 실행하려면 `~/.bashrc` 또는 `~/.zshrc`에 추가:

```bash
# koalakid-toolbox aliases
alias install-tools='~/github/koalakid1/toolbox/git/install-required-tools.sh'
alias setup-account='~/github/koalakid1/toolbox/git/setup-account.sh'
alias clone-repo='~/github/koalakid1/toolbox/git/clone-repo.sh'
```

적용:
```bash
source ~/.bashrc  # 또는 source ~/.zshrc
```

---

## 📂 디렉토리 구조

```
toolbox/
├── README.md           # 이 파일
├── git/                # GitHub 멀티 계정 관리
│   ├── README.md
│   ├── install-required-tools.sh
│   ├── setup-account.sh
│   ├── clone-repo.sh
│   ├── SSH_GPG_SETUP.md
│   ├── CLONE_GUIDE.md
│   └── SETUP_GUIDE.md
└── ...                 # 향후 추가될 도구들
```

---

## 🛠️ 향후 추가 예정

- `docker/` - Docker 환경 설정 및 관리 도구
- `db/` - 데이터베이스 설정 및 백업 스크립트
- `deploy/` - 배포 자동화 스크립트
- `backup/` - 백업 및 복원 도구

---

## 📝 라이선스

MIT License

---

## 👤 작성자

koalakid

**최종 수정:** 2025-10-07
