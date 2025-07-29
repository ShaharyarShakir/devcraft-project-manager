#!/bin/bash
set -euo pipefail

# 🧢 Branding
gum style --border double --margin "1" --padding "1 2" --foreground 12 \
	"🚀 DevCrafe Project Manager
Created by Shaharyar"

# 📁 Project name
while true; do
	PROJECT_NAME=$(gum input --placeholder "Enter your project name")
	[[ -n "$PROJECT_NAME" ]] && break
	gum style --foreground 196 --padding "1 2" "⚠️ Project name is required."
done

mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME"

# 📦 Initialize Devbox
gum spin --title "Initializing Devbox..." -- devbox init
devbox add git github-cli

# 📦 Choose package manager
PACKAGE_MANAGER=$(gum choose "npm" "pnpm" "yarn")
if [[ "$PACKAGE_MANAGER" == "npm" ]]; then
	devbox add nodejs
else
	devbox add "$PACKAGE_MANAGER"
fi

# 🧱 Choose frontend framework
FRONTEND=$(gum choose "react" "vue" "svelte")

# 🔧 Scaffold frontend project
gum style --padding "1 2" --margin "1" --foreground 33 \
	"📦 Scaffolding frontend project: $FRONTEND"

mkdir frontend

# Use correct vite create command based on package manager

if [[ "$PACKAGE_MANAGER" != "npm" ]]; then
	devbox run "$PACKAGE_MANAGER" create vite frontend -- --template "$FRONTEND"
else
	devbox run bash -c "npm create vite@latest frontend -- --template $FRONTEND"
fi

# 🧠 Backend setup


if gum confirm "Do you want to add a backend?"; then
	BACKEND=$(gum choose "Express.js" "Hono.js")
	mkdir -p backend

	# 🔧 Initialize backend (clean per-package-manager logic)
	case "$PACKAGE_MANAGER" in
		npm)
			devbox run npm init -y --prefix backend
			;;
		yarn)
			devbox run yarn init -y --cwd backend
			;;
		pnpm)
			# pnpm does not support -y, run interactively in backend dir
			(cd backend && devbox run pnpm init)
			;;
		bun)
			devbox run bun init --yes --cwd backend
			;;
		*)
			echo "⚠️ Unsupported package manager for init: $PACKAGE_MANAGER"
			;;
	esac

	# 🧱 Choose package to install
	case "$BACKEND" in
		"Express.js") PKG_NAME="express" ;;
		"Hono.js") PKG_NAME="hono" ;;
		*) echo "⚠️ Unsupported backend"; exit 1 ;;
	esac

	# 📦 Install backend framework into backend/
	case "$PACKAGE_MANAGER" in
		npm | pnpm)
			devbox run "$PACKAGE_MANAGER" add "$PKG_NAME" --prefix backend
			;;
		yarn | bun)
			devbox run "$PACKAGE_MANAGER" add "$PKG_NAME" --cwd backend
			;;
		*)
			echo "⚠️ Unsupported package manager for install: $PACKAGE_MANAGER"
			;;
	esac
fi

# 🛢️ Choose database(s)
if gum confirm "Do you want to add a database?"; then
	DBS=$(gum choose --no-limit "PostgreSQL" "MySQL" "MongoDB" "SQLite" "Redis")
	for db in $DBS; do
		case "$db" in
		PostgreSQL) devbox add postgresql ;;
		MySQL) devbox add mysql ;;
		MongoDB) devbox add mongodb ;;
		SQLite) devbox add sqlite ;;
		Redis) devbox add redis ;;
		esac
	done
fi

# 📄 Create README + Gitignore
echo "# $PROJECT_NAME" >README.md
curl -sL "https://www.toptal.com/developers/gitignore/api/node" -o .gitignore || echo "# No .gitignore found" >.gitignore

# 🐙 Git + GitHub Setup
if gum confirm "Initialize Git repository?"; then
	git init
	git add .
	git commit -m "Initial commit"

	if gum confirm "Create GitHub repo & push?"; then
		gh repo create "$PROJECT_NAME" --private --source=. --remote=origin
		git push -u origin main
		gh browse
	fi
fi

# ✅ Summary
gum style --border double --padding "1 2" --foreground 10 --border-foreground 112 \
	"✅ $PROJECT_NAME Ready!

🧱 Frontend: $FRONTEND
📦 Package Manager: $PACKAGE_MANAGER
🧠 Backend: ${BACKEND:-None}
💾 Database(s): ${DBS:-None}
📁 Structure:
  - frontend/
  - backend/ (if selected)
"

# 🐚 Devbox shell
if gum confirm "Enter Devbox shell now?"; then
	exec devbox shell
fi
