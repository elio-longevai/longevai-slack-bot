import os
import logging
from dotenv import load_dotenv
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler
from src.llm_handler import get_llm_response

# --- Setup ---
# Load environment variables from .env file
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)

# Initialize the Slack Bolt App
app = App(token=os.environ.get("SLACK_BOT_TOKEN"))

# --- Slack Event Listener ---
@app.message()
def handle_message(message: dict, say: callable):
    """
    This function is triggered by any new message in a channel the bot is in.
    It analyzes the message and replies selectively using the LLM.
    """
    user_message = message.get('text', '')
    channel_id = message.get('channel')
    
    # Ignore messages from bots or without text
    if message.get('bot_id') or not user_message:
        return

    logging.info(f"Received message in channel {channel_id}: '{user_message}'")

    # Get a potential response from the LLM handler
    bot_reply = get_llm_response(user_message)

    # If the LLM provided a response, send it to the channel
    if bot_reply:
        logging.info(f"Sending reply: '{bot_reply}'")
        say(text=bot_reply)

def start():
    """Starts the Slack bot using Socket Mode."""
    try:
        # The SocketModeHandler connects to Slack's Events API using a WebSocket.
        handler = SocketModeHandler(app, os.environ["SLACK_APP_TOKEN"])
        logging.info("🤖 Qualivita Assistant is running!")
        handler.start()
    except Exception as e:
        logging.critical(f"🔴 CRITICAL ERROR: Could not start the bot. Check your tokens. Error: {e}")

if __name__ == "__main__":
    start()