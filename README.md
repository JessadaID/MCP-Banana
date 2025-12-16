### MCP Server
    For Bananacoding


## Add Azure Devops buildin in claude_desktop_config.json
```
{
  "mcpServers": {
    "mcp-on-rails": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "http://localhost:3000/mcp"
      ]
    },    
    "ado": {
      "command": "npx",
      "args": ["-y", "@azure-devops/mcp", "bananacoding"]
    }
  }
}
```

## Add .env your token
```
ADO_MCP_AUTH_TOKEN=your_token
```