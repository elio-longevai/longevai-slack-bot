# Qualivita Slack Assistant

Qualivita Assistant is an intelligent bot integrated into Slack to boost team productivity. It uses Google's Gemini LLM via LangChain to analyze messages in real-time and provide selective, helpful responses.

## Features

-   **Real-time Analysis**: Listens to messages in its designated channels as they are posted.
-   **Stateless Operation**: Analyzes each message independently without needing conversation history.
-   **Selective Replying**: Intelligently decides whether to reply or stay silent, preventing channel noise.
-   **Direct AI Q&A**: Responds to direct questions when addressed with phrases like "Hey AI...".
-   **Proactive Command Generation**: Detects user intent to perform actions in other tools (e.g., Monday.com) and provides the exact, copy-pasteable command.

## Tech Stack

-   Python 3.13+
-   [slack-bolt](https://slack.dev/bolt-python/): For robust Slack integration.
-   [LangChain](https://www.langchain.com/): For orchestrating the LLM interaction.
-   [Google Gemini](https://ai.google.dev/): The language model powering the bot's intelligence.

## Setup and Installation

### 1. Prerequisites

-   A Slack Workspace where you have permission to add apps.
-   A Google AI API Key.
-   Python 3.13 or higher.

### 2. Create a Slack App

Here's a step-by-step guide to setting up your Slack app:

#### Step 1: Create the App
1. Go to [Your Apps](https://api.slack.com/apps) page on Slack
2. Click **"Create New App"**
3. Select **"From scratch"**
4. Enter app name: `Qualivita Assistant`
5. Select your workspace and click **"Create App"**

#### Step 2: Configure Bot Permissions
1. In your app settings, go to **"OAuth & Permissions"**
2. Scroll to **"Bot Token Scopes"** and add these scopes:
   - `chat:write` (to send messages)
   - `channels:history` (to read messages in public channels)
   - `groups:history` (to read messages in private channels)

#### Step 3: Enable Socket Mode
1. Go to **"Socket Mode"** in your app settings
2. Toggle **"Enable Socket Mode"** to ON
3. Go to **"Basic Information"** → **"App-Level Tokens"**
4. Click **"Generate Token and Scopes"**
5. Token Name: `socket-mode-token`
6. Add scope: `connections:write`
7. Click **"Generate"** and copy the **App-Level Token** (starts with `xapp-`)

#### Step 4: Install and Get Bot Token
1. Go to **"OAuth & Permissions"**
2. Click **"Install to Workspace"**
3. Review permissions and click **"Allow"**
4. Copy the **Bot User OAuth Token** (starts with `xoxb-`)

#### Step 5: Add Bot to Channel
1. In your Slack workspace, go to the channel where you want the bot
2. Type `/invite @Qualivita Assistant` (or use the name you chose)
3. The bot will now listen to messages in that channel

#### Step 6: Get Google AI API Key
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click **"Create API Key"**
3. Copy your API key for the `.env` file

### 3. Configure a Local Environment

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd qualivita-slack-bot
    ```

2.  **Setup and install dependencies:**
    ```bash
    make setup
    ```
    This will create a virtual environment, install all dependencies, and set up git hooks.

3.  **Create your environment file:**
    ```bash
    cp .env.example .env
    ```
    Then edit `.env` and add your tokens:
    ```bash
    SLACK_BOT_TOKEN="xoxb-your-bot-token-here"
    SLACK_APP_TOKEN="xapp-your-app-token-here"  
    GOOGLE_API_KEY="your-google-api-key-here"
    ```

## Running the Bot

Start the bot with:

```bash
make dev
```

You should see the log message `🤖 Qualivita Assistant is running!`. Now, go to the Slack channel where you added the bot and start sending messages!

## Development Commands

This project uses a Makefile for common tasks:

- `make setup` - Initial setup (clean, install deps, git hooks)
- `make dev` - Start the bot
- `make lint` - Check code quality with ruff
- `make format` - Auto-format code with ruff
- `make compile-requirements` - Update requirements.txt from requirements.in
- `make clean` - Clean build artifacts and cache
- `make health` - Check system health and dependencies
- `make help` - Show all available commands

## Testing the Bot

**Example Messages to Try:**

-   `hey ai, what are the best practices for a REST API design?`
-   `I need to add a new task for the Q3 report to the project board`
-   (Send a normal message like "hello everyone" to see that the bot correctly ignores it)

## Project Structure

```
qualivita-slack-bot/
├── .env.example              # Environment variables template
├── .github/workflows/        # GitHub Actions for CI/CD
├── Makefile                  # Development commands
├── README.md                 # This file
├── requirements.in           # Core dependencies
├── requirements-dev.in       # Development dependencies  
├── requirements.txt          # Compiled dependencies
├── requirements-dev.txt      # Compiled dev dependencies
└── src/
    ├── __init__.py          # Package marker
    ├── bot.py               # Main Slack bot application
    └── llm_handler.py       # Google Gemini LLM integration
```