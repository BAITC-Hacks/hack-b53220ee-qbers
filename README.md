<div align="center">

```
   ██████╗ ██████╗ ███████╗██████╗ ███████╗
  ██╔═══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝
  ██║   ██║██████╔╝█████╗  ██████╔╝███████╗
  ██║▄▄ ██║██╔══██╗██╔══╝  ██╔══██╗╚════██║
  ╚██████╔╝██████╔╝███████╗██║  ██║███████║
   ╚══▀▀═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝
```

### `// HACKALEM · TEAM QBERS · SYSTEM ONLINE`

<img src="https://img.shields.io/badge/STATUS-OPERATIONAL-00f0ff?style=for-the-badge&labelColor=060913" />
<img src="https://img.shields.io/badge/DJANGO-6.1-7c5cff?style=for-the-badge&logo=django&logoColor=white&labelColor=060913" />
<img src="https://img.shields.io/badge/REACT-19-22f0ff?style=for-the-badge&logo=react&logoColor=22f0ff&labelColor=060913" />
<img src="https://img.shields.io/badge/POSTGRES-18%20·%20DOCKER-ff4fd8?style=for-the-badge&logo=docker&logoColor=white&labelColor=060913" />
<img src="https://img.shields.io/badge/GOOGLE-MAPS%20·%20CHARTS%20·%20OAUTH-3cffa5?style=for-the-badge&logo=google&logoColor=white&labelColor=060913" />

<br/>

**One command. Full stack. Same database on every machine.**

</div>

---

## ⚡ `01` — LAUNCH SEQUENCE

You don't need anything installed first — setup installs **Python, Node.js and Docker** for you, then starts our **PostgreSQL 18 database inside Docker** with the same tables, data, username and password as everyone else on the team. Already have some of these? Setup spots them, cheers you on 🎉, and skips ahead.

> [!NOTE]
> **No keys to hunt down.** Our `.env` (API keys, database login) is committed to this **private** repo, so it's already in your clone.

There are only **two steps**: run setup **once**, then use **`npm start`** every time after.

<table>
<tr>
<th width="50%">🍎 &nbsp;macOS &nbsp;·&nbsp; 🐧 Linux</th>
<th width="50%">🪟 &nbsp;Windows (Command Prompt)</th>
</tr>
<tr>
<td valign="top">

Open **Terminal**, then run:

```bash
git clone https://github.com/BAITC-Hacks/hack-b53220ee-qbers.git
cd hack-b53220ee-qbers
./setup.sh
```

</td>
<td valign="top">

Press <kbd>Win</kbd>, type **cmd**, press <kbd>Enter</kbd>, then run:

```bat
git clone https://github.com/BAITC-Hacks/hack-b53220ee-qbers.git
cd hack-b53220ee-qbers
setup.cmd
```

</td>
</tr>
<tr>
<td valign="top">

<sub>Installs Homebrew (or uses apt) → Python, Node, **Docker Desktop**.<br/>You may be asked for your computer password.</sub>

</td>
<td valign="top">

<sub>Uses winget → Python, Node, **Docker Desktop**.<br/>Click **Yes** on any Windows permission pop-ups.</sub>

</td>
</tr>
</table>

### 📟 What you'll see

```
▸ Python ≥ 3.12
  🎉 Already installed: Python 3.14.7
▸ Docker
  ⠼ Downloading Docker...   ██████████░░░░░░░░░░░░  46%  38s
  ✔  Starting Docker engine (12s)                  ███████████████░░░░░░░  68%
```

- **`...` preloader + percentage** on every download and install — the bar is the *overall* setup progress.
- **🎉 in rainbow colours** for anything already on your computer (Homebrew/winget, Python, Node, Docker, a local PostgreSQL, Django).
- **If a step fails**, setup stops right there and shows a red box with the last lines of output and a **How to fix** tip. Fix it and run setup again — finished steps are skipped. Everything is logged to `logs/setup.log`.

### 🐳 During setup you'll be asked

| Prompt | What to do |
|:--|:--|
| **Docker Desktop window opens** (first install only) | Accept the terms. Skip the sign-in screen if you like. Leave it running. On Windows it may ask to install WSL or restart — do it, then run setup again. |
| `Log in to Docker Hub? [y/N]` | Optional. Type **y** and enter your Docker Hub username + password (or access token) to avoid download limits — or press <kbd>Enter</kbd> to skip. Your password goes straight to Docker; the script never stores it. |
| Computer password (macOS/Linux) | Needed to install Homebrew / apt packages. |

### ⬆️ Versions

| Tool | What setup does |
|:--|:--|
| **PostgreSQL** | Always the **latest 18.x** image (re-checked every setup run). Older team databases (e.g. 16) are **upgraded automatically** with your data kept. A PostgreSQL you installed yourself is left untouched. |
| **Django + Python packages** | Upgraded to the **latest** release every run (Django 6.1.x today). |
| **Python** | Needs **3.12+**. Older → installs **3.14** alongside it. |
| **Node.js** | Needs **22.12+**. Older → updates to the latest. |
| **Docker** | Installs the latest Docker Desktop if missing; updates it if it's too old for this project. |

When setup finishes, your browser opens **[`http://localhost:5173`](http://localhost:5173)** on its own. 🚀

### ↻ Every time after that

Make sure **Docker Desktop is open** (the app starts it for you if it can), then from the project folder in any terminal — Terminal, cmd, or PowerShell:

```bash
npm start
```

<sub>Using pnpm? `pnpm start` works the same way.</sub>

Press <kbd>Ctrl</kbd> + <kbd>C</kbd> to stop the web servers. The database container keeps running quietly in Docker, so your data is still there next time.

### ⌘ Command cheat-sheet

| I want to… | npm | pnpm | macOS / Linux | Windows cmd |
|:--|:--|:--|:--|:--|
| **Install everything** (first time) | `npm run setup` * | `pnpm run setup` * | `./setup.sh` | `setup.cmd` |
| **Start the app** | `npm start` | `pnpm start` | `./run.sh` | `npm start` |
| **Stop the app** | <kbd>Ctrl</kbd>+<kbd>C</kbd> | <kbd>Ctrl</kbd>+<kbd>C</kbd> | <kbd>Ctrl</kbd>+<kbd>C</kbd> | <kbd>Ctrl</kbd>+<kbd>C</kbd> |
| **Start only the database** | `npm run db:up` | `pnpm run db:up` | ← same | ← same |
| **Share my data with the team** | `npm run db:snapshot` | `pnpm run db:snapshot` | ← same | ← same |
| **Reload the team's data** (wipes mine) | `npm run db:reset` | `pnpm run db:reset` | ← same | ← same |
| **Open a SQL prompt** | `npm run db:shell` | `pnpm run db:shell` | ← same | ← same |
| **Fix "Virtualization support not detected"** | — | — | — | `fix-docker.cmd` |

<sub>\* Only if Node.js is already installed. On a brand-new computer, use `./setup.sh` or `setup.cmd`, which install Node for you. It's `pnpm run setup`, not `pnpm setup` — that one is a built-in pnpm command.</sub>

<details>
<summary><b>🪟 &nbsp;Windows notes</b></summary>

<br/>

- **Don't have Git?** Install it with `winget install Git.Git`, or download the ZIP from GitHub (green **Code** button → *Download ZIP*), unzip it, and double-click **`setup.cmd`**.
- **No `winget`?** It ships with Windows 10/11 as *App Installer* from the Microsoft Store. Update it, then run `setup.cmd` again.
- **"… not found" right after installing:** Windows only refreshes PATH in new windows. Close cmd, open a new one, `cd` back into the folder, and run `setup.cmd` again. It picks up where it left off.
- **Docker Desktop needs WSL 2.** If it asks to install WSL or restart, do it, reopen Docker Desktop, wait for *Engine running*, then run `setup.cmd` again.
- **Docker says "Virtualization support not detected"?** Installing WSL fixes it — double-click **`fix-docker.cmd`** (runs `wsl --install` for you), or see [the full fix below](#virtualization-support-not-detected-windows). Setup detects this and offers the fix automatically; `npm start` detects it and points you to `fix-docker.cmd`.
- **Prefer Git Bash?** `./setup.sh` works there too.

</details>

<details>
<summary><b>🐧 &nbsp;Linux notes</b></summary>

<br/>

Debian/Ubuntu (apt) is automated. Docker Engine is installed with Docker's official script and you're added to the `docker` group — until you log out and back in, the scripts use `sudo docker` automatically.

</details>

---

## 🛰️ `02` — WHAT SETUP DOES

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  [1] CONFIG      reads .env (+ your .env.local) — DB login, ports, keys     │
│  [2] PKG MGR     Homebrew  ─or─  winget  ─or─  apt   (installs if missing)  │
│  [3] RUNTIME     Python 3.12+ · Node 22.12+ · Docker  (skipped if present)  │
│  [4] DOCKER      starts the engine, optional Docker Hub login               │
│  [5] DATABASE    pulls latest Postgres 18.x → port check → upgrade → up     │
│                  first run loads db/init/01-snapshot.sql (team data)        │
│  [6] BACKEND     .venv → pip install --upgrade (latest Django) → migrate    │
│  [7] FRONTEND    npm install  (React + Vite)                                │
│  [8] IGNITION    npm start → free ports picked → browser opens              │
└─────────────────────────────────────────────────────────────────────────────┘
```

It's **safe to re-run** — every step skips what's already installed.

---

## 🧬 `03` — ARCHITECTURE

```mermaid
flowchart LR
    B([🌐 Browser<br/>localhost:5173]) -->|React UI| V[⚛️ Vite dev server]
    V -->|/api proxy| D[🐍 Django<br/>:8000]
    D -->|127.0.0.1:55432| P
    subgraph Docker
      P[(🐘 PostgreSQL 18<br/>hackalem-db)]
    end
    B -.->|Maps JS · Charts · GIS| G{{☁️ Google APIs}}
    D -.->|verify ID token| G
```

| Layer | Tech | Job |
|:--|:--|:--|
| <samp>UI</samp> | **React 19 + Vite** | Landing page, components, Google widgets |
| <samp>API</samp> | **Django** | Forms, auth, site actions (`/api/*`, `/admin`) |
| <samp>DATA</samp> | **PostgreSQL 18 in Docker** | Waitlist sign-ups, chart metrics, map pins, users |
| <samp>CLOUD</samp> | **Google** | Maps, Charts, Sign-In with Google, Analytics |
| <samp>CLOUD</samp> | **AWS** | Hosting / services (coming soon) |
| <samp>STYLE</samp> | **Font Awesome · Rubik · EB Garamond** | Icons and typography |

---

## 🐘 `04` — THE TEAM DATABASE

Everyone runs the **same** Postgres, defined once in [`docker-compose.yml`](docker-compose.yml) and configured from `.env`:

| Setting | Value (from `.env`) |
|:--|:--|
| Host | `127.0.0.1` |
| Version | PostgreSQL `18` (latest 18.x patch) |
| Port | `55432` <sub>(unusual on purpose; if it's still taken, you get the next free one — see below)</sub> |
| Database | `hackalem` |
| User / password | `hackalem` / `hackalem` |
| Container / volume | `hackalem-db` / `hackalem-pgdata-18` |

Connect with any SQL tool (TablePlus, DBeaver, pgAdmin, DataGrip) using those values, or run `npm run db:shell`.

**How the data stays in sync:**

1. The first time your container starts with an empty volume, it loads **`db/init/01-snapshot.sql`** — so you get exactly the tables and rows in the repo.
2. Changed data you want everyone to have? Run **`npm run db:snapshot`**, commit `db/init/01-snapshot.sql`, and push.
3. Teammates pull, then run **`npm run db:reset`** to replace their local data with the new snapshot.
4. Schema changes still go through Django: `python backend/manage.py makemigrations` → commit → teammates' `npm start` runs `migrate` automatically.

### 🔌 When a port is already taken

Every port the app uses falls back automatically, so the site still runs:

| Port | If something else is using it… |
|:--|:--|
| **55432** database | Setup / `npm start` names what's using it (e.g. *Docker container some-db*), moves to the next free port, and saves it to **`.env.local`** so it stays the same for you. Django and your SQL tools use that port — the team `.env` isn't touched. |
| **8000** Django | Uses the next free port for this run. |
| **5173** web app | Uses the next free port (e.g. `5174`) and prints the URL. ⚠️ *Sign in with Google* only works on `5173`. |

`.env.local` is personal and gitignored. Delete it to go back to the team port.

### ⬆️ Upgrading PostgreSQL

`POSTGRES_VERSION` in `.env` picks the major version (currently **18**). When it changes, the next setup or `npm start`:

1. exports your old database with its **own** version (Postgres can't read another major version's files),
2. starts the new version on a fresh volume (`hackalem-pgdata-18`) and imports your data,
3. keeps the old volume and a backup file (`logs/backup-pg16.sql`) just in case.

Once you're happy, free the space with `docker volume rm hackalem-pgdata`.

> [!WARNING]
> `npm run db:reset` deletes your local database volume. Snapshot first if you have data you care about.

---

## 🗂️ `05` — FILE MAP

```
hackalem/
├── .env                   ⟶  ALL config: API keys, DB login, ports (committed — private repo)
├── .env.local             ⟶  your personal overrides, e.g. a moved port (gitignored, auto-created)
├── docker-compose.yml     ⟶  PostgreSQL container, reads .env
├── db/init/               ⟶  01-snapshot.sql — team data loaded on first start
├── package.json           ⟶  npm start · npm run setup · npm run db:*  (pnpm works too)
├── setup.sh               ⟶  one-time installer — macOS / Linux / Git Bash
├── setup.cmd · setup.ps1  ⟶  one-time installer — Windows Command Prompt
├── fix-docker.cmd         ⟶  Windows: fixes Docker's "Virtualization support not detected"
├── run.sh                 ⟶  shortcut for `npm start`
├── logs/                  ⟶  setup.log · django.log · upgrade backups (gitignored)
├── scripts/
│   ├── start.js           ·  Docker DB → migrate → Django → Vite → browser
│   ├── db.js              ·  up / pull / snapshot / reset / shell
│   ├── lib/               ·  .env reader · port finder · Docker + upgrade helpers
│   └── windows/           ·  docker-doctor.ps1 — virtualization checks + fixes
├── backend/               ⟶  Django project
│   ├── config/            ·  settings.py reads everything from .env
│   └── core/              ·  models, forms, API views, migrations
└── frontend/              ⟶  React (Vite)
    ├── index.html         ·  loads the Font Awesome kit from .env
    └── src/
        ├── lib/env.js     ·  the only place the UI reads .env
        └── components/    ·  MapCard · ChartCard · WaitlistForm · SignIn · StatusGrid
```

---

## 🔐 `06` — ENVIRONMENT VARIABLES

All config lives in **one** root-level [`.env`](.env). Django, React, Docker Compose and the setup scripts all read it — change a value there and everything follows.
Only variables prefixed **`VITE_`** reach the browser.

| Variable | Used by | Purpose |
|:--|:--|:--|
| `POSTGRES_DB` · `POSTGRES_USER` · `POSTGRES_PASSWORD` | Docker + Django | Database name and login |
| `POSTGRES_HOST` · `POSTGRES_PORT` | Docker + Django | Where Postgres listens (`127.0.0.1:55432`) |
| `POSTGRES_VERSION` | Docker | Postgres major version (`18`); change it to upgrade |
| `GOOGLE_API_KEY` | React | Google Maps + Charts |
| `GOOGLE_OAUTH_CLIENT_ID` | React + Django | "Sign in with Google" |
| `GOOGLE_OAUTH_CLIENT_SECRET` | Django only | OAuth server-side flows |
| `GA_MEASUREMENT_ID` | React | Google Analytics 4 (`G-XXXXXXX`, optional) |
| `DJANGO_SECRET_KEY` · `DJANGO_DEBUG` | Django | Framework settings |
| `AWS_*` | Django | AWS console details + future IAM access keys |
| `VITE_FONTAWESOME_KIT_URL` | React | Font Awesome icon kit |
| `VITE_FONT_SANS` / `VITE_FONT_SERIF` | React | Google Fonts — `Rubik` / `EB Garamond` |

Need a personal override without changing the team file? Put it in **`.env.local`** (gitignored) — the scripts create it for you when a port has to move. Priority: shell environment → `.env.local` → `.env`.

> [!CAUTION]
> **This repo must stay private.** `.env` contains live Google and AWS credentials. Never make the repo public, fork it publicly, or paste `.env` anywhere outside the team.

---

## 🧪 `07` — VERIFY IT WORKS

The landing page has live status tiles. All four should glow green:

| Tile | Proves |
|:--|:--|
| <i>React</i> | the frontend rendered |
| <i>Django</i> | the API is reachable through the Vite proxy |
| <i>PostgreSQL</i> | Django queried the Docker database (shows `PostgreSQL 18… (Debian…)`) |
| <i>Google keys</i> | `.env` was loaded |

Then scroll down: the **map** pins and **chart** bars come from Postgres tables, and the **waitlist form** saves a row through a Django form. View rows at **[`/admin`](http://localhost:5173/admin/)** after creating an admin user:

```bash
.venv/bin/python backend/manage.py createsuperuser
```

```bat
.venv\Scripts\python backend\manage.py createsuperuser
```

<sub>First line: macOS / Linux. Second line: Windows cmd.</sub>

---

## 🛠️ `08` — TROUBLESHOOTING

### "Virtualization support not detected" (Windows)

Docker Desktop shows this when Windows can't use your CPU's virtualization — Docker needs it to run Linux containers like our database.

> [!TIP]
> **The fix that works for most people: install WSL.** Open **Command Prompt as administrator** (<kbd>Win</kbd> → type `cmd` → *Run as administrator*), run the command below, then **restart Windows**:
>
> ```bat
> wsl --install
> ```
>
> After the restart, open Docker Desktop, wait for *Engine running*, and run `setup.cmd` again.

**You usually don't have to type that yourself.** On Windows, setup spots the problem three ways and offers to run `wsl --install` for you (one admin prompt, then a restart). `npm start` runs the same checks and tells you to run `fix-docker.cmd`:

- before starting Docker — virtualization / WSL checks fail,
- while waiting for Docker — its log shows *"Virtualization support not detected"* or a WSL error,
- after Docker fails to start — even when every check passes, it offers to (re)install WSL.

Or run the same fixer any time:

```bat
fix-docker.cmd
```

It checks six things and tells you exactly which one is wrong:

```
   [ok] CPU virtualization enabled in BIOS/UEFI   Intel(R) Core(TM) i7-1165G7
   [!!] Windows feature: Virtual Machine Platform
   [!!] Windows feature: Windows Subsystem for Linux
   [!!] Windows hypervisor running
   [!!] WSL 2 installed and working
   [!!] Docker Desktop log free of virtualization/WSL errors
```

| What's wrong | What happens |
|:--|:--|
| **WSL missing / Windows features off / hypervisor off** (most common) | ✅ **Fixed automatically.** Say **Y**, click **Yes** on the admin prompt, then restart. It runs **`wsl --install`** (installs WSL 2 and turns on *Virtual Machine Platform* + *Windows Subsystem for Linux*), sets the hypervisor to start at boot, and updates WSL. |
| **Everything looks on, but Docker still shows the error** | ✅ **Offers to reinstall WSL** with `wsl --install` — the same fix. |
| **Virtualization off in BIOS/UEFI** | 🔧 **You flip one switch** (Windows can't do it for you). The tool offers to **restart straight into the BIOS** for you. |
| **Windows is itself a virtual machine** | 🔧 The host must enable *nested virtualization* (instructions are printed). |

<details>
<summary><b>Manual steps: turn on virtualization in BIOS/UEFI</b></summary>

<br/>

1. **Open the BIOS/UEFI settings.** Either
   - *Settings → System → Recovery → Advanced startup → **Restart now** → Troubleshoot → Advanced options → **UEFI Firmware Settings** → Restart*, or
   - tap the key while the PC starts: **Dell** F2 · **HP** Esc then F10 · **Lenovo** F1/F2 · **ASUS / MSI** F2 or Del · **Acer** F2 · **Surface** hold Volume Up + Power.
2. **Find the setting** — usually under *Advanced*, *CPU Configuration*, or *Security*:
   - Intel: **Intel Virtualization Technology** / **VT-x** / **Intel VT**
   - AMD: **SVM Mode** / **AMD-V**
3. Set it to **Enabled** → **Save & Exit** (often F10).
4. Back in Windows, run **`fix-docker.cmd`** again to finish the Windows side, then **`setup.cmd`**.

> Work or school laptop with a BIOS password? That's what Docker means by *"contact your IT admin"* — they need to enable virtualization for you.

</details>

<details>
<summary><b>Manual steps: turn on the Windows side yourself</b></summary>

<br/>

Open **Command Prompt as administrator** (<kbd>Win</kbd> → type `cmd` → *Run as administrator*) and run:

```bat
wsl --install
```

That's normally enough — restart and you're done. If `wsl --install` fails (older Windows 10), turn the pieces on one by one instead:

```bat
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

```bat
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

```bat
bcdedit /set hypervisorlaunchtype auto
```

```bat
wsl --update
```

Restart Windows, open Docker Desktop → **Settings → General** → tick **Use the WSL 2 based engine** → *Apply & restart*. Wait for *Engine running*, then run `setup.cmd`.

</details>

<details>
<summary><b>Setup stopped with a red ✖</b></summary>

The red box shows the step that failed, its last lines of output and a **How to fix** tip. The full output is in `logs/setup.log` (`logs\setup.log` on Windows). Fix the issue and run setup again — it skips everything that already worked.
</details>

<details>
<summary><b>"Docker did not start" / PostgreSQL tile is red</b></summary>

Open **Docker Desktop** and wait until it shows *Engine running*, then `npm start` again. Still stuck? See what the database says:

```bash
docker compose logs db
```
</details>

<details>
<summary><b>"Port 55432 is already used by …"</b></summary>

That's handled for you — the message tells you what's using it and which port you got instead (saved in `.env.local`). Point your SQL tool at the new port. To force a specific port, set `POSTGRES_PORT=…` in `.env.local`.
</details>

<details>
<summary><b>Web app opened on 5174 (not 5173)</b></summary>

Something — often another copy of the app — is on 5173, so the next free port was used. Everything works except *Sign in with Google*. Stop the other copy with <kbd>Ctrl</kbd>+<kbd>C</kbd>, or find it:

```bash
lsof -i :5173 -i :8000
```

```bat
netstat -ano | findstr :5173
```

<sub>Django also moves off 8000 automatically when it's busy.</sub>
</details>

<details>
<summary><b>My data doesn't match the team's</b></summary>

The snapshot only loads into an **empty** volume. To throw away your local data and reload the snapshot from the repo:

```bash
npm run db:reset
```
</details>

<details>
<summary><b>Map shows "Sorry! Something went wrong" (<code>ApiNotActivatedMapError</code>)</b></summary>

In Google Cloud Console (the project that owns `GOOGLE_API_KEY`) go to **APIs & Services → Library**, enable **Maps JavaScript API**, and make sure billing is on. If the key has referrer restrictions, allow `http://localhost:5173/*`. Reload the page. No restart needed.
</details>

<details>
<summary><b>"Sign in with Google" button missing or errors</b></summary>

In Google Cloud Console → **Credentials** → your OAuth client, add `http://localhost:5173` and `http://localhost` to **Authorized JavaScript origins**.
</details>

<details>
<summary><b>Django won't start</b></summary>

Check the log:

```bash
tail -50 logs/django.log
```
</details>

---

<div align="center">

<sub>`▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓`</sub>

**QBERS** · built at HackAlem · `EOF`

</div>
