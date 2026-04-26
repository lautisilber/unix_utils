You can add the following lines to your ```bashrc``` or ```bash_profile``` files to get easy access to code-server (self-hosted vscode)

```bash
# code-server
alias code-server-install='curl -fsSL https://code-server.dev/install.sh | sh -- --method standalone'
alias code-server-show-password="cat $HOME/.config/code-server/config.yaml"
PATH="$HOME/.local/bin:$PATH"
```

This allows you to install code-server with ```code-server-install``` in your remote machine and run it with ```code-server```. Then, you can use port forwarding to forward the port code-server exposes itself (```8080```by default) with ```ssh -L <local port>:localhost:8080 user@hostname``` or by adding port forwarding to your ```~/.ssh/config``` like so.

```ssh-config
Host <Name>
    HostName <HostName>
    User <User>
    LocalForward <local port> 127.0.0.1:8080
```
