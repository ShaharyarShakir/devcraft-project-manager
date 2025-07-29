#!/usr/bin/env bash
set -euo pipefail

# 🛠 Auto-install if missing
install_if_missing() {
  local cmd=$1
  local install_cmd=$2
  if ! command -v "$cmd" &>/dev/null; then
    echo "🔧 Installing $cmd..."
    eval "$install_cmd"
  fi
}

install_if_missing "devbox" 'curl -fsSL https://get.jetpack.io/devbox | bash && sudo mv devbox /usr/local/bin/'
if ! command -v gum &>/dev/null; then
  echo "📦 Installing gum globally using devbox..."
  devbox global add gum
  eval "$(devbox global shellenv)"
fi

# 🧢 Branding
gum style \
  --border double \
  --margin "1" \
  --padding "1 2" \
  --foreground 12 \
  "🚀 DevCrafe Project Manager
Created by Shaharyar"

# 📁 Choose project path
PROJECT_PATH=$(gum input --placeholder "Enter full path (leave blank for current dir)")
[[ -n "$PROJECT_PATH" ]] && mkdir -p "$PROJECT_PATH" && cd "$PROJECT_PATH"

# 📦 Project name (validated)
while true; do
  PROJECT_NAME=$(gum input --placeholder "Enter your project name")
  [[ -n "$PROJECT_NAME" ]] && break
  gum style --foreground 196 --border rounded --padding "1 2" "⚠️ Project name cannot be empty."
done
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 📂 Category (validated)
while true; do
  CATEGORY=$(gum choose "Web" "Mobile" "DataScience" "DevOps" || true)
  [[ -n "$CATEGORY" ]] && break
  gum style --foreground 196 --border rounded --padding "1 2" "⚠️ You must select a category."
done

# 🎯 Minimal mode: Just files and folders
if gum confirm "Skip setup and just create folders/files?"; then
  if gum confirm "Create folders?"; then
    FOLDER_NAMES=$(gum input --placeholder "e.g. src assets public" | xargs)
    for folder in $FOLDER_NAMES; do mkdir -p "$folder"; done
  fi

  if gum confirm "Create files?"; then
    FILE_NAMES=$(gum input --placeholder "e.g. README.md index.js" | xargs)
    for file in $FILE_NAMES; do touch "$file"; done
  fi

  if gum confirm "Initialize Git repository?"; then git init; fi
  echo "# $PROJECT_NAME" > README.md

  gum style --border double --padding "1 2" --foreground 10 --border-foreground 112 "✅ Minimal project created."
  exit 0
fi

# 🧠 Language
case "$CATEGORY" in
  Web) LANGUAGE=$(gum choose "JavaScript" "TypeScript" "Python" "Go" "Rust") ;;
  Mobile) LANGUAGE=$(gum choose "React Native" "Flutter" "Kotlin") ;;
  DataScience) LANGUAGE="Python" ;;
  DevOps) LANGUAGE=$(gum choose "Python" "Go" "Rust" "Shell") ;;
esac

# ⚙️ Stack / Framework
FRAMEWORK="None"
PACKAGE_MANAGER=""
USE_EXPO=""
if gum confirm "Do you want to use a framework?"; then
  case "$CATEGORY" in
    Web)
      STACK=$(gum choose "Frontend" "Backend" "Fullstack" "None")
      case "$STACK" in
        Frontend) FRAMEWORK=$(gum choose "React" "Vue" "Svelte" "Angular" "None");;
        Backend)  FRAMEWORK=$(gum choose "Express" "Fastify" "Hono" "None");;
        Fullstack) FRAMEWORK=$(gum choose "Next.js" "SvelteKit" "Nuxt" "None");;
      esac
      [[ "$FRAMEWORK" != "None" ]] && PACKAGE_MANAGER=$(gum choose "npm" "pnpm" "bun" "yarn")
      ;;
    Mobile)
      FRAMEWORK=$(gum choose "React Native" "Flutter" "Kotlin" "None")
      [[ "$FRAMEWORK" == "React Native" ]] && USE_EXPO=$(gum choose "Expo" "Bare React Native") && FRAMEWORK="React Native ($USE_EXPO)"
      ;;
  esac
fi

# 💾 Databases
DATABASES=$(gum choose --no-limit "None" "PostgreSQL" "MongoDB" "MySQL" "SQLite" "Redis")

# 🛠 Git Setup
USE_GIT=false
PUSH_REMOTE=false
GIT_PROVIDER="None"
if gum confirm "Initialize Git?"; then
  USE_GIT=true
  git init
  if gum confirm "Push to remote?"; then
    PUSH_REMOTE=true
    GIT_PROVIDER=$(gum choose "GitHub" "GitLab" "Bitbucket" "Other")
  fi
fi

# 📦 Devbox Packages
DEVBOX_PACKAGES=()
case "$LANGUAGE" in
  JavaScript | TypeScript) DEVBOX_PACKAGES+=("nodejs") ;;
  Python) DEVBOX_PACKAGES+=("python" "uv") ;;
  Go) DEVBOX_PACKAGES+=("go") ;;
  Rust) DEVBOX_PACKAGES+=("rust") ;;
  Flutter) DEVBOX_PACKAGES+=("flutter") ;;
  Kotlin) DEVBOX_PACKAGES+=("kotlin") ;;
esac

case "$PACKAGE_MANAGER" in
  pnpm) DEVBOX_PACKAGES+=("pnpm") ;;
  bun) DEVBOX_PACKAGES+=("bun") ;;
  yarn) DEVBOX_PACKAGES+=("yarn") ;;
esac

# 🔌 Extra Devbox Packages
if gum confirm "Add extra devbox packages?"; then
  EXTRA_PACKAGES=$(gum input --placeholder "e.g. curl git jq" | xargs)
  [[ -n "$EXTRA_PACKAGES" ]] && DEVBOX_PACKAGES+=($EXTRA_PACKAGES)
fi

# 📥 Install via npm/pnpm?
PM_PACKAGES=()
if [[ -n "$PACKAGE_MANAGER" ]] && gum confirm "Install extra packages via $PACKAGE_MANAGER?"; then
  PM_PACKAGES=($(gum input --placeholder "e.g. lodash axios" | xargs))
fi

# 🧱 Database Packages
DB_PACKAGES=()
for DB in $DATABASES; do
  case "$DB" in
    PostgreSQL) DB_PACKAGES+=("postgresql") ;;
    MySQL) DB_PACKAGES+=("mysql") ;;
    MongoDB) DB_PACKAGES+=("mongodb") ;;
    SQLite) DB_PACKAGES+=("sqlite") ;;
    Redis) DB_PACKAGES+=("redis") ;;
  esac
done

# 📋 Show Devbox Plan
gum style \
  --border double \
  --padding "1 4" \
  --margin "1" \
  --foreground 205 \
  --border-foreground 212 \
  "📦 Installing Devbox Packages"

if [[ ${#DEVBOX_PACKAGES[@]} -gt 0 ]]; then
  printf "%s\n" "${DEVBOX_PACKAGES[@]}" | sed 's/^/• /' | gum style --padding "1 2" --border rounded --border-foreground 212
else
  gum style --padding "1 2" --border rounded --border-foreground 88 "No packages selected"
fi

# 🔧 Devbox Init + Install
gum spin --title "Initializing Devbox..." -- devbox init
for pkg in "${DEVBOX_PACKAGES[@]}"; do
  gum spin --title "Installing $pkg..." -- devbox add "$pkg"
done

# ➕ PM Package Installs
if [[ ${#PM_PACKAGES[@]} -gt 0 ]]; then
  gum spin --title "Installing with $PACKAGE_MANAGER..." -- $PACKAGE_MANAGER add "${PM_PACKAGES[@]}"
fi

# 💾 Database Installs
for db in "${DB_PACKAGES[@]}"; do
  gum spin --title "Installing DB: $db..." -- devbox add "$db"
done

# 🏗️ Scaffolding
gum spin --title "Scaffolding ($FRAMEWORK)..." -- bash -c "
case \"$FRAMEWORK\" in
  React | Vue | Svelte | Angular)
    npm create vite@latest . -- --template ${FRAMEWORK,,}
    $PACKAGE_MANAGER install
    ;;
  Express)
    mkdir src && echo 'const express = require(\"express\"); const app = express(); app.listen(3000);' > src/index.js
    npm init -y && npm install express
    ;;
  Fastify)
    mkdir src && echo 'import Fastify from \"fastify\"; const fastify = Fastify(); fastify.listen({ port: 3000 });' > src/index.js
    npm init -y && npm install fastify
    ;;
  Hono)
    npm init -y && npm install hono
    echo 'import { Hono } from \"hono\"; const app = new Hono(); app.get(\"/\", (c) => c.text(\"Hello\")); export default app;' > index.js
    ;;
  Next.js)
    $PACKAGE_MANAGER create next-app@latest . -- --typescript
    ;;
  SvelteKit)
    npm create svelte@latest .
    ;;
  Nuxt)
    npx nuxi init . && npm install
    ;;
  React\ Native\ \(*)*)
    [[ \"$USE_EXPO\" == \"Expo\" ]] && npx create-expo-app@latest . || npx react-native init \"$PROJECT_NAME\"
    ;;
  Flutter)
    flutter create .
    ;;
  Kotlin*)
    mkdir -p app/src/main/java/com/example
    echo 'fun main() = println(\"Hello Kotlin\")' > app/src/main/java/com/example/Main.kt
    ;;
esac
"

# 📘 README & .gitignore
echo "# $PROJECT_NAME" > README.md
LANG_IGNORE=$(echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
curl -sL "https://www.toptal.com/developers/gitignore/api/$LANG_IGNORE" -o .gitignore || echo "# No .gitignore available for $LANGUAGE" > .gitignore

# 🐙 Remote Git
if [[ "$USE_GIT" == true && "$PUSH_REMOTE" == true ]]; then
  git add .
  git commit -m "Initial commit"
  gh-create "$PROJECT_NAME"
  git push -u origin main
fi

# ✅ Summary
gum style \
  --border double \
  --border-foreground 212 \
  --margin "1" \
  --padding "1 2" \
  --foreground 12 \
  "✅ Project: $PROJECT_NAME
📂 Category: $CATEGORY
🧠 Language: $LANGUAGE
🧱 Framework: $FRAMEWORK
📦 Package Manager: ${PACKAGE_MANAGER:-None}
📦 Devbox: ${DEVBOX_PACKAGES[*]:-None}
➕ PM Packages: ${PM_PACKAGES[*]:-None}
💾 Databases: ${DATABASES:-None}
📝 Files: README.md, .gitignore"

# 🐚 Devbox Shell
if gum confirm "Enter Devbox shell?"; then
  exec devbox shell
fi

