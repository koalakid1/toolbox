#!/usr/bin/env bash

# Toolbox 설치 스크립트
# Shell 설정, aliases, fzf 통합을 자동으로 설정합니다

set -e  # 오류 시 중지

TOOLBOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_CONFIG=""
SHELL_NAME=""

echo "🚀 koalakid-toolbox 설치"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📂 Toolbox 경로: $TOOLBOX_DIR"
echo ""

# ========================================
# 1. Shell 감지
# ========================================
echo "🔍 Shell 감지 중..."

if [ -n "$ZSH_VERSION" ]; then
    SHELL_NAME="zsh"
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_NAME="bash"
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo "❌ 지원하지 않는 shell입니다: $SHELL"
    echo "   zsh 또는 bash를 사용해주세요."
    exit 1
fi

echo "✅ 감지된 shell: $SHELL_NAME"
echo "   설정 파일: $SHELL_CONFIG"
echo ""

# ========================================
# 2. 백업 생성
# ========================================
create_backup() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        echo "📦 백업 생성: $backup"
    fi
}

# ========================================
# 3. Shell 설정 추가
# ========================================
echo "🔧 Shell 설정 추가 중..."
echo ""

# 백업
create_backup "$SHELL_CONFIG"

# 추가할 내용
ALIASES_LINE="source $TOOLBOX_DIR/.aliases"

# 중복 체크
if grep -q "$ALIASES_LINE" "$SHELL_CONFIG" 2>/dev/null; then
    echo "ℹ️  .aliases 이미 설정됨"
else
    {
        echo ""
        echo "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "# Toolbox Aliases (자동 추가)"
        echo "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$ALIASES_LINE"
        echo ""
    } >> "$SHELL_CONFIG"
    echo "✅ .aliases 설정 추가됨"
fi

# Homebrew bash PATH 설정 (macOS만)
if [[ "$OSTYPE" == "darwin"* ]]; then
    HOMEBREW_BASH_BLOCK='
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Homebrew PATH 설정 (아키텍처 자동 감지)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon Mac
    [[ -d "/opt/homebrew/bin" ]] && export PATH="/opt/homebrew/bin:$PATH"
else
    # Intel Mac
    [[ -d "/usr/local/bin" ]] && export PATH="/usr/local/bin:$PATH"
fi'

    if grep -q "Homebrew PATH 설정" "$SHELL_CONFIG" 2>/dev/null; then
        echo "ℹ️  Homebrew PATH 이미 설정됨"
    else
        echo "$HOMEBREW_BASH_BLOCK" >> "$SHELL_CONFIG"
        echo "✅ Homebrew PATH 설정 추가됨"
    fi
fi

echo ""

# ========================================
# 4. fzf Shell Integration 활성화
# ========================================
echo "🔧 fzf shell integration 설정 중..."

if command -v fzf &> /dev/null; then
    FZF_PREFIX="$(brew --prefix fzf 2>/dev/null || echo /usr/local)"

    # fzf key bindings & auto-completion
    if [[ "$SHELL_NAME" == "bash" ]]; then
        FZF_LINE="source $FZF_PREFIX/opt/fzf/fzf.bash"
    else
        FZF_LINE="source $FZF_PREFIX/opt/fzf/fzf.zsh"
    fi

    if grep -q "fzf" "$SHELL_CONFIG" 2>/dev/null; then
        echo "ℹ️  fzf 이미 설정됨"
    else
        {
            echo ""
            echo "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "# fzf shell integration (자동 추가)"
            echo "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "$FZF_LINE"
            echo ""
        } >> "$SHELL_CONFIG"
        echo "✅ fzf 설정 추가됨"
    fi
else
    echo "⚠️  fzf가 설치되지 않음 (나중에 수동 설정 필요)"
    echo "   설치: brew install fzf"
fi

echo ""

# ========================================
# 5. iTerm2 설정 백업/복원
# ========================================
echo "📱 iTerm2 설정 확인 중..."

ITERM_DIR="$HOME/Library/Application Support/iTerm2"
ITERM_BACKUP_DIR="$TOOLBOX/iterm2/backups"

if [ -d "$ITERM_DIR" ]; then
    echo "ℹ️  iTerm2 설치됨"

    # 백업 폴더 생성
    mkdir -p "$ITERM_BACKUP_DIR"

    # DynamicProfiles 백업
    if [ -f "$ITERM_DIR/DynamicProfiles/SSH Profiles.json" ]; then
        cp "$ITERM_DIR/DynamicProfiles/SSH Profiles.json" \
           "$ITERM_BACKUP_DIR/SSH-Profiles.json.backup.$(date +%Y%m%d_%H%M%S)"
        echo "📦 iTerm2 SSH Profiles 백업 완료"
    fi

    echo "💡 iTerm2 설정 백업 위치: $ITERM_BACKUP_DIR"
else
    echo "ℹ️  iTerm2 미설치 (건너뜀)"
fi

echo ""

# ========================================
# 6. dotfiles symbolic link (선택 사항)
# ========================================
echo "🔗 dotfiles symbolic link 생성 (선택 사항)"
echo ""

# 예시: .gitconfig, .vimrc 등
DOTFILES=(
    # ".gitconfig:$TOOLBOX/dotfiles/.gitconfig"
    # ".vimrc:$TOOLBOX/dotfiles/.vimrc"
    # ".tmux.conf:$TOOLBOX/dotfiles/.tmux.conf"
)

if [ ${#DOTFILES[@]} -eq 0 ]; then
    echo "ℹ️  dotfiles 설정 없음 (건너뜀)"
else
    for dotfile in "${DOTFILES[@]}"; do
        target="${dotfile%%:*}"
        source="${dotfile##*:}"

        if [ -f "$source" ]; then
            # 기존 파일 백업
            if [ -f "$HOME/$target" ] && [ ! -L "$HOME/$target" ]; then
                mv "$HOME/$target" "$HOME/$target.backup.$(date +%Y%m%d_%H%M%S)"
            fi

            # symbolic link 생성
            ln -sf "$source" "$HOME/$target"
            echo "✅ $target → $source"
        fi
    done
fi

echo ""

# ========================================
# 7. 색상 테마 적용 (선택 사항)
# ========================================
echo "🎨 색상 테마 적용 (선택 사항)"
echo ""

# LS_COLORS (Linux/macOS)
if command -v dircolors &> /dev/null; then
    if [[ "$SHELL_NAME" == "bash" ]]; then
        LS_COLORS_LINE='eval "$(dircolors -b $TOOLBOX/dotfiles/.dircolors)"'
    else
        LS_COLORS_LINE='eval "$(dircolors -b $TOOLBOX/dotfiles/.dircolors)"'
    fi

    if grep -q "LS_COLORS" "$SHELL_CONFIG" 2>/dev/null; then
        echo "ℹ️  LS_COLORS 이미 설정됨"
    else
        echo "⚠️  LS_COLORS 설정 파일 없음 (선택 사항)"
        echo "   필요시: $TOOLBOX/dotfiles/.dircolors 생성 후 추가"
    fi
fi

echo ""

# ========================================
# 8. 완료 안내
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Toolbox 설치 완료!"
echo ""
echo "📝 다음 단계:"
echo ""
echo "1️⃣  Shell 설정 다시 로드:"
if [[ "$SHELL_NAME" == "zsh" ]]; then
    echo "   source ~/.zshrc"
else
    echo "   source ~/.bashrc"
fi
echo ""
echo "2️⃣  또는 터미널을 완전히 새로 열기 (⌘+N)"
echo ""
echo "3️⃣  설치 확인:"
echo "   which bash    # /opt/homebrew/bin/bash 또는 /usr/local/bin/bash"
echo "   fzf --version"
echo "   gh --version"
echo ""
echo "4️⃣  사용 가능한 alias:"
echo "   gclone        # GitHub 레포지토리 클론"
echo "   gsetup        # GitHub 계정 설정"
echo "   ginstall      # 필수 도구 설치"
echo "   s3setup       # S3 설정 생성"
echo "   issh          # iTerm2 SSH Profile 생성"
echo ""
echo "📂 Toolbox 경로: $TOOLBOX_DIR"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
