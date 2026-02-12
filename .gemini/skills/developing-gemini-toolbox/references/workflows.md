# Development Workflows

## Build System

The project uses `make` to manage the multi-stage Docker builds.

### Full Build
```bash
make build
# or parallel
make -j4 build
```

### Component Build
To save time, build only what you are working on:

```bash
# Hub only
make -C images/gemini-hub build

# CLI only (skips base if already built)
make -C images/gemini-cli build
```

## Quality Assurance (CI)

You must run the local CI suite before submitting a PR.

```bash
make local-ci
```
This command runs:
1.  **ShellCheck** on all `.sh` scripts (`bin/*` and `entrypoint.sh`).
2.  **Ruff** on the `gemini-hub` Python code.
3.  **Pytest** on the `gemini-hub` test suite.

## Debugging

### Debugging the Hub
You can run the Hub manually to test changes without full integration:

```bash
docker run --rm -it 
    --net=host 
    --cap-add=NET_ADMIN 
    --device /dev/net/tun 
    -e TAILSCALE_AUTH_KEY=tskey-auth-... 
    gemini-cli-toolbox/hub:latest
```

### Debugging the CLI
Use the `--bash` flag to drop into a raw shell inside the container:

```bash
bin/gemini-toolbox --bash
```

To test the **Preview** image:
```bash
bin/gemini-toolbox --preview --bash
```
