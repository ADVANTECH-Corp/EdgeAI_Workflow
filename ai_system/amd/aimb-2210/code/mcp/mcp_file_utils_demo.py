"""
FastMCP File Utility Example

Provides platform-agnostic file and directory tools with structured output.
Tested on both Windows and Linux.
"""

# Import FastMCP from the mcp.server.fastmcp package
from mcp.server.fastmcp import FastMCP
import os
import sys

# Create an instance of FastMCP with the name "Local File Agent Helper"
mcp = FastMCP("Local File Agent Helper")

# Define a tool for the MCP server
# This tool will list the contents of a given directory
@mcp.tool()
def list_dir(path: str) -> str:
    """
    List the contents of a directory.
    
    Args:
        path: The directory to list.  
    """
    # Log the execution to stderr for debugging purposes
    print(f"Executing: list_dir {path}", file=sys.stderr)
    try:
        # Get all entries (files and folders) in the directory
        entries = os.listdir(path)
        # Join them into a single string separated by newlines
        result = "\n".join(entries)
        # Log the result to stderr for debugging
        print(f"Directory contents ({path}):\n{result}", file=sys.stderr)
        return result
    except Exception as e:
        # If an error occurs, log it to stderr and return an error message
        print(f"Error listing directory {path}: {str(e)}", file=sys.stderr)
        return f"Error: {str(e)}"

# Define a tool for reading a file's content
@mcp.tool()
def read_file(path: str) -> str:
    """
    Read the contents of a file.
    
    Args:
        path: The file to read.
    """
    # Log the execution to stderr for debugging
    print(f"Executing: read_file {path}", file=sys.stderr)
    try:
        # Open the file in read mode with UTF-8 encoding
        with open(path, "r", encoding="utf-8") as f:
            # Read the entire content of the file
            content = f.read()
            # Log the first 100 characters as a preview (avoid huge logs)
            print(f"File preview ({path}):\n{content[:100]}...", file=sys.stderr)
            # Return the full file content
            return content
    except Exception as e:
        # If an error occurs (e.g., file not found, permission denied), log and return the error
        print(f"Error reading file {path}: {str(e)}", file=sys.stderr)
        return f"Error: {str(e)}"

# Define a tool for reading a file's content
@mcp.tool()
def write_file(path: str, content: str) -> str:
    """
    Write text to a file.
    
    Args:
        path: The file to write to.
        content: The text to write.
    """
    # Log the execution to stderr for debugging
    print(f"Executing: write_file {path}", file=sys.stderr)
    try:
        # Open the file in write mode with UTF-8 encoding
        with open(path, "w", encoding="utf-8") as f:
            # Write the given content into the file
            f.write(content)
            # Log a success message
            print(f"Successfully wrote to {path}", file=sys.stderr)
            return "success"
    except Exception as e:
        # If an error occurs (e.g., permission denied, invalid path), log and return the error
        print(f"Error writing file {path}: {str(e)}", file=sys.stderr)
        return f"Error: {str(e)}"
    
# Entry point of the program
if __name__ == "__main__":
    # Log server startup message to stderr
    print("Starting FastMCP server...", file=sys.stderr)
    # Run the MCP server using stdio as the transport
    mcp.run(transport='stdio')
