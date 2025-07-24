import logging
import os

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI

# Configure logging
logging.basicConfig(level=logging.INFO)

# System prompt to guide the LLM's behavior
# This is the core of the bot's intelligence.
SYSTEM_PROMPT = """
You are "Qualivita Assistant," an intelligent bot integrated into a team's Slack channel. Your purpose is to increase productivity by selectively responding to messages.

You have two modes of operation:

1.  **DirectAnswer Mode**: Triggered when a message starts with "hey ai", "ask ai", or similar phrases. In this mode, you directly answer the user's query as a helpful assistant.

2.  **CommandGenerator Mode**: Triggered when you detect a user wants to perform an action in an external tool, like adding a task to a project management board (e.g., Monday.com, Jira). In this mode, you do NOT answer the query directly. Instead, you generate the precise, copy-pasteable command for that tool. For example, if the user says "add a task to fix the login bug", you would generate a command like `/monday create-item "Fix the login bug"`.

**Your Response Rules:**

-   You MUST analyze the user's message and decide which mode is appropriate.
-   If the message is just general chatter, casual conversation, or does not fit either mode, you MUST NOT respond.
-   Your entire response must be a single string. Do not add any extra text or formatting unless it's part of the answer or command.
-   For CommandGenerator mode, format the response to be as helpful as possible within Slack, using markdown for code blocks.
-   If the message is not relevant, return the exact string "NO_RESPONSE".

Analyze the following user message from Slack and provide your response based on these rules.
"""

def get_llm_response(user_message: str) -> str | None:
    """
    Analyzes a user's message using the Gemini LLM and returns a response
    if it's relevant, otherwise returns None.

    Args:
        user_message: The message text from Slack.

    Returns:
        A string containing the bot's reply, or None if no reply is needed.
    """
    try:
        # Initialize the LangChain chat model with the specific Gemini model
        llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            google_api_key=os.environ.get("GOOGLE_API_KEY"),
            temperature=0.7,
            max_tokens=None,
            timeout=None,
            max_retries=2
        )

        # Create the prompt template
        prompt = ChatPromptTemplate.from_messages([
            ("system", SYSTEM_PROMPT),
            ("user", "{input}")
        ])

        # Create the chain
        chain = prompt | llm | StrOutputParser()

        logging.info(f"Invoking LLM for message: '{user_message}'")
        response = chain.invoke({"input": user_message})
        logging.info(f"LLM raw response: '{response}'")

        # If the LLM decides not to respond, return None
        if "NO_RESPONSE" in response:
            return None

        return response

    except Exception as e:
        logging.error(f"Error invoking LLM: {e}")
        return "Sorry, I encountered an error while processing your request."