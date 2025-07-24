### 1. The Knowledge Base: `Slack_connection_kb.md`

This guide will walk anyone on your team through setting up the interactive Slack bot from scratch.

```markdown
# Super-Quick Interactive Slack Bot Setup Guide

This guide explains how to create and run an interactive Slack bot that can read messages from a channel, process them, and reply. This is perfect for integrating an LLM to generate commands or answer questions directly within Slack.

We will use the official `slack_bolt` library and Socket Mode, which is the fastest way to get a bot running for development without needing a public server.

---

### Part 1: Setting Up Your Slack App

First, you need to create a "Bot" identity within your Slack workspace.

**Step 1: Create a Slack App**
1.  Go to the [Slack API dashboard](https://api.slack.com/apps).
2.  Click **Create New App** and choose "From scratch".
3.  Give it a name (e.g., "Qualivita Assistant") and select your workspace. Click **Create App**.

**Step 2: Enable Socket Mode**
1.  In the left sidebar of your new app's settings, click **Socket Mode**.
2.  Toggle **Enable Socket Mode** to ON.
3.  A pop-up will appear. Enter a token name (e.g., "socket-token") and click **Generate**.
4.  **Copy this token (it starts with `xapp-`)...** and save it somewhere safe. This is your `SLACK_APP_TOKEN`.

**Step 3: Add Bot Permissions (Scopes)**
1.  In the left sidebar, click **OAuth & Permissions**.
2.  Scroll down to the **Scopes** section. Under **Bot Token Scopes**, click **Add an OAuth Scope**.
3.  Add the following scopes one by one:
    *   `chat:write`: To let the bot send messages.
    *   `app_mentions:read`: To let the bot see messages that @mention it.
    *   `channels:history`: To let the bot read messages from public channels it's in.
    *   `groups:history`: To let the bot read messages from private channels it's in.

**Step 4: Install the App and Get Bot Token**
1.  Scroll back up on the **OAuth & Permissions** page.
2.  Click **Install to Workspace**, and then click **Allow** on the next screen.
3.  **Copy the Bot User OAuth Token (it starts with `xoxb-`)...** and save it. This is your `SLACK_BOT_TOKEN`.

**Step 5: Add the Bot to a Channel**
1.  Open your Slack workspace.
2.  Go to the channel where you want the bot to operate (e.g., `#qualivita`).
3.  In the message box, type `/add` and select "Add apps to this channel".
4.  Find and add the app you just created.

---

### Part 2: Running the Python Bot

Now let's run the code that brings your bot to life.

**Step 1: Project Setup**
1.  Create a new folder for your project.
2.  Inside that folder, create a file named `interactive_slack_bot.py` and another named `requirements.txt`.

**Step 2: Add Code and Dependencies**
1.  Copy the code from the `interactive_slack_bot.py` file provided into your `interactive_slack_bot.py`.
2.  Add the following lines to your `requirements.txt` file:
    ```
    slack-bolt
    python-dotenv
    ```
3.  Create a file named `.env` in the same directory. This will hold your secret tokens. **Do not commit this file to Git.** Add your tokens to it like this:
    ```
    SLACK_BOT_TOKEN="xoxb-YOUR-BOT-TOKEN-HERE"
    SLACK_APP_TOKEN="xapp-YOUR-APP-TOKEN-HERE"
    ```

**Step 3: Install Dependencies**
Open your terminal in the project folder and run:
```bash
# It's highly recommended to use a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows, use `venv\Scripts\activate`

pip install -r requirements.txt
```

**Step 4: Run the Bot**
Now, simply run the Python script:
```bash
python interactive_slack_bot.py
```
You should see the message: `🤖 Slack bot is running!`

Go to your Slack channel and try sending a message like `Hey AI, what's up?` or `add to monday: design the new dashboard`. The bot will reply!

---

### Part 3: Customization & Next Steps

*   **Integrate an LLM**: The `process_message_for_command` function in the Python script is the perfect place to add your LLM API call. Replace the simple `if/else` logic with a call to your language model to interpret the user's intent.
*   **Trigger on Mentions Only**: To stop the bot from reading every single message, change `@app.message()` to `@app.event("app_mention")` in the script. This will only trigger the bot when it is explicitly tagged with `@`.

```

### 2. The Python Code: `interactive_slack_bot.py`

This script is a self-contained, runnable example that implements the interactive logic you described.

```python
import os
import re
import logging
from dotenv import load_dotenv
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler

# --- Setup ---
# Load environment variables from .env file
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)

# Initialize the Slack Bolt App with the Bot Token
# The SLACK_BOT_TOKEN starts with 'xoxb-'
# The SLACK_APP_TOKEN is for the Socket Mode handler and starts with 'xapp-'
app = App(token=os.environ.get("SLACK_BOT_TOKEN"))


# --- Core Logic ---
def process_message_for_command(text: str) -> str | None:
    """
    Analyzes the message text and returns a helpful reply if a keyword is found.
    This is the function where you would integrate your LLM for advanced processing.
    """
    # Use case-insensitive search to make it user-friendly
    text_lower = text.lower()

    # Example 1: Generate a command for a project management tool (like Monday.com)
    if "add to monday" in text_lower:
        # Simple regex to extract the task description after the trigger phrase
        task_match = re.search(r"add to monday:?\s*(.*)", text, re.IGNORECASE)
        task_description = task_match.group(1).strip() if task_match else "New Task from Slack"

        # Generate the command string the user can copy-paste
        monday_command = f'/monday create-item "{task_description}"'
        reply_text = (
            f"Hi there! I see you want to add something to Monday.com. "
            f"Here is a command you can use:\n"
            f"```\n{monday_command}\n```"
        )
        return reply_text

    # Example 2: Respond to a direct question to the AI
    if text_lower.startswith("hey ai"):
        # This is where you would pass the user's query to an LLM
        # For now, we'll return a placeholder response
        ai_query = text[len("hey ai"):].strip().lstrip(',').strip()
        reply_text = (
            f"Hello! You asked: '{ai_query}'.\n"
            f"_(This is where the LLM would process the query and provide a real answer.)_"
        )
        return reply_text

    # Return None if no keywords are detected, so the bot doesn't reply to everything
    return None


# --- Slack Event Listener ---
# @app.message() listens to *every* message in channels the bot is in.
# This fulfills the "analyze the latest message" requirement without needing chat history.
# For a less noisy bot, you could change this to @app.event("app_mention")
# to only trigger when the bot is @-mentioned.
@app.message()
def handle_message(message: dict, say: callable):
    """
    This function is triggered when a message is posted in a channel.
    """
    user_message = message.get('text', '')
    logging.info(f"Received message: '{user_message}'")

    # Process the message to see if it should trigger a command response
    reply_text = process_message_for_command(user_message)

    # If a response was generated, send it back to the channel.
    # This fulfills the "reply selectively" requirement.
    if reply_text:
        logging.info(f"Sending reply: '{reply_text}'")
        say(text=reply_text)


# --- Start the Bot ---
if __name__ == "__main__":
    # The SocketModeHandler connects to Slack's Events API using a WebSocket.
    # It's great for development as it doesn't require a public-facing URL.
    handler = SocketModeHandler(app, os.environ["SLACK_APP_TOKEN"])
    logging.info("🤖 Slack bot is running!")
    handler.start()
```