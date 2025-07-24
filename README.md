# Qualivita Slack Assistant

Qualivita Assistant is an intelligent bot integrated into Slack to boost team productivity. It uses Google's Gemini LLM via LangChain to analyze messages in real-time and provide selective, helpful responses.

## Features

-   **Real-time Analysis**: Listens to messages in its designated channels as they are posted.
-   **Stateless Operation**: Analyzes each message independently without needing conversation history.
-   **Selective Replying**: Intelligently decides whether to reply or stay silent, preventing channel noise.
-   **Direct AI Q&A**: Responds to direct questions when addressed with phrases like "Hey AI...".
-   **Proactive Command Generation**: Detects user intent to perform actions in other tools (e.g., Monday.com) and provides the exact, copy-pasteable command.

## Tech Stack

-   Python 3.9+
-   [slack-bolt](https://slack.dev/bolt-python/): For robust Slack integration.
-   [LangChain](https://www.langchain.com/): For orchestrating the LLM interaction.
-   [Google Gemini](https://ai.google.dev/): The language model powering the bot's intelligence.

## Setup and Installation

### 1. Prerequisites

-   A Slack Workspace where you have permission to add apps.
-   A Google AI API Key.
-   Python 3.9 or higher.

### 2. Create a Slack App

Follow the [official Slack guide](https://api.slack.com/authentication/basics) to create a new Slack App. During setup, you will need to:

1.  **Enable Socket Mode**: In your app's settings, go to "Socket Mode" and enable it. Generate an App-Level Token (starts with `xapp-`).
2.  **Add Bot Scopes**: Go to "OAuth & Permissions" and add the following **Bot Token Scopes**:
    -   `chat:write` (to send messages)
    -   `channels:history` (to read messages in public channels)
    -   `groups:history` (to read messages in private channels)
3.  **Install to Workspace**: Install the app to your workspace. This will generate a Bot User OAuth Token (starts with `xoxb-`).
4.  **Add Bot to a Channel**: In your Slack client, go to the desired channel and use `/add` to add your newly created bot.

### 3. Configure a Local Environment

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd qualivita-slack-bot
    ```

2.  **Set up a virtual environment (recommended):**
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Create your environment file:**
    -   Copy the example file: `cp .env.example .env`
    -   Open the `.env` file and fill in your secret keys:
        -   `SLACK_BOT_TOKEN` (the `xoxb-` token)
        -   `SLACK_APP_TOKEN` (the `xapp-` token)
        -   `GOOGLE_API_KEY` (your key from Google AI Studio)

## Running the Bot

With your virtual environment activated and your `.env` file configured, simply run the bot:

```bash
python -m src.bot
```

You should see the log message `🤖 Qualivita Assistant is running!`. Now, go to the Slack channel where you added the bot and start sending messages!

**Example Messages to Try:**

-   `hey ai, what are the best practices for a REST API design?`
-   `I need to add a new task for the Q3 report to the project board`
-   (Send a normal message like "hello everyone" to see that the bot correctly ignores it)