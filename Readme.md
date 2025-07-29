# 🚀 DevCrafe Project Manager

**DevCrafe** is an interactive CLI tool built with [**Devbox**](https://www.jetpack.io/devbox/) and [**Gum**](https://github.com/charmbracelet/gum) to instantly scaffold modern **frontend** and **backend** projects.

It helps developers set up tools, frameworks, and environments using a friendly, branded terminal experience — all while keeping the setup **fully isolated from your operating system** using Devbox.

---

## ⚙️ Prerequisites

Before using `devcrafe`, please ensure you have the following tools installed:

- [**Devbox**](https://www.jetpack.io/devbox/) – for managing environments and packages
- [**Gum**](https://github.com/charmbracelet/gum) – for interactive UI in terminal
- ❗️ These are **not installed automatically** in the current version. Install them first.

### 🔧 Quick install (Ubuntu/macOS)
#### Install Devbox
```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

#### Install Gum using a package manager
```bash
# macOS or Linux
brew install gum

# Arch Linux (btw)
pacman -S gum

# Nix
nix-env -iA nixpkgs.gum

# Flox
flox install gum

# Windows (via WinGet or Scoop)
winget install charmbracelet.gum
scoop install charm-gum
```
# ✨ Features
### 📁 Create full project structure with frontend/ and backend/ folders

#### 💡 Choose from popular frontend frameworks:

- React

- Vue

- Svelte

#### 🔧 Select lightweight backend frameworks:

- Express.js

- Hono.js

- 📦 Uses **Devbox** to manage packages, runtimes, and tools

- 📦 Package manager support: npm, pnpm, yarn

- 🐙 Optional Git + GitHub integration

- ✅ Final summary output and project ready to run

# 📦 Installation
#### 🛠️ Global installation
```bash
sudo curl -fsSL https://raw.githubusercontent.com/ShaharyarShakir/devcraft-project-manager/main/devcraft.sh -o /usr/local/bin/devcraft
```
```bash
sudo chmod +x /usr/local/bin/devcraft
```
#### Run from anywhere using:
```bash
devcraft
```
#### ▶️ Run directly without installing
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ShaharyarShakir/devcraft-project-manager/main/devcraft.sh)
```
## 📂 What DevCrafe Creates
- After walking through the prompts, you'll get:
```bash
your-project/
├── frontend/      # Scaffolds React/Vue/Svelte using Vite
│   ├── index.html
│   ├── main.js/ts
│   └── ...
├── backend/       # Optional Express or Hono API setup
│   └── index.js
├── devbox.json
├── README.md
└── .gitignore
📸 Preview
(Optional GIF or screenshot of terminal UI here)
```
# 📜 License
#### **MIT © Shaharyar Shakir**







