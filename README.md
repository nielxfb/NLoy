# NLoy

A simple deployment management tool for Node.js and React applications.

## Features

- 🚀 Deploy React Vite applications
- 📊 Monitor active deployments
- 🔄 Automatic port management
- 🎯 Process management with PIDs
- 🎨 Colorful CLI interface

## Installation

1. Clone the repository:
```bash
git clone https://github.com/nielxfb/NLoy.git
cd NLoy
```

2. Make the script executable:
```bash
chmod +x main.sh
```

3. (Optional) Create an alias for easier access:
```bash
echo "alias nloy='bash /path/to/NLoy/main.sh'" >> ~/.bashrc
source ~/.bashrc
```

## Usage

### Deploy a React Vite Application

Navigate to your React project directory and run:
```bash
nloy deploy react
```

This will:
- Install dependencies
- Build the application
- Start a preview server on an available port
- Track the deployment with a PID

### Check Active Deployments

```bash
nloy ps
```

Shows all active deployments with their PIDs, names, and ports.

### Kill a Deployment

```bash
nloy kill <PID>
```

Replace `<PID>` with the process ID of the deployment you want to stop.

### Get Help

```bash
nloy help
nloy deploy help
```

## Commands

| Command | Description |
|---------|-------------|
| `help` | Show help message |
| `deploy react` | Deploy a React Vite application |
| `ps` | List active deployments |
| `kill <PID>` | Stop a deployment by PID |

## Requirements

- Bash shell
- Node.js and npm
- `lsof` command (for port detection)
- `ss` command (for port availability checking)

## How It Works

NLoy manages deployments by:
1. Finding available ports starting from 3000
2. Running npm commands in the background
3. Storing process information in `/tmp/nloy.pid`
4. Tracking PIDs, deployment types, and ports
