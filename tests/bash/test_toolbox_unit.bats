#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

# Source the script without executing it
source_toolbox() {
    # Mock some basics to avoid errors during sourcing if any
    export HOME="$TEST_TEMP_DIR"
    source "$PROJECT_ROOT/bin/gemini-toolbox"
}

@test "show_help function prints usage" {
    source_toolbox
    run show_help
    assert_success
    assert_output --partial "Usage: gemini-toolbox"
}

@test "main function runs correctly with --bash" {
    source_toolbox
    mock_docker
    run main --bash
    assert_success
}

@test "setup_worktree function is defined" {
    source_toolbox
    run declare -f setup_worktree
    assert_success
}

@test "main fails with --remote and --no-tmux" {
    source_toolbox
    run main --remote tskey-auth --no-tmux
    assert_failure
    assert_output --partial "Error: --remote and --no-tmux are incompatible"
}

@test "setup_worktree error: not a git repo" {
    source_toolbox
    local not_a_repo="$TEST_TEMP_DIR/not-a-repo"
    mkdir -p "$not_a_repo"
    cd "$not_a_repo"
    # Ensure no .git folder exists in parents by using a completely fresh temp dir
    local isolated_dir
    isolated_dir="$(mktemp -d)"
    cd "$isolated_dir"
    
    run setup_worktree "proj" "branch" "."
    assert_failure
    assert_output --partial "Error: --worktree can only be used within a Git repository"
    rm -rf "$isolated_dir"
}

@test "setup_worktree error: git not found" {
    source_toolbox
    # Mock git to not found
    cat <<EOF > "$TEST_TEMP_DIR/bin/git"
#!/bin/bash
exit 127
EOF
    # Remove from path or ensure it's first
    run setup_worktree "proj" "branch" "."
    # This might be tricky if it uses the real git first.
    # Our setup_test_env puts TEST_TEMP_DIR/bin first.
}

@test "main: image detection logic (local exists)" {
    source_toolbox
    # Mock docker image inspect to return 0
    cat <<EOF > "$TEST_TEMP_DIR/bin/docker"
#!/bin/bash
if [[ "\$1" == "image" && "\$2" == "inspect" ]]; then exit 0; fi
exit 0
EOF
    run main --bash
    # It should use the local tag
    run grep "gemini-cli-toolbox/cli:latest" "$MOCK_DOCKER_LOG"
}

@test "setup_worktree error: empty repository" {
    source_toolbox
    local empty_repo="$TEST_TEMP_DIR/empty-repo"
    mkdir -p "$empty_repo"
    cd "$empty_repo"
    git init -q
    # No commits yet
    run setup_worktree "proj" "branch" "."
    assert_failure
    assert_output --partial "Error: Cannot create a worktree from an empty repository"
}

@test "setup_worktree: folder name sanitization" {
    source_toolbox
    mock_git
    # Use a valid branch name that needs folder sanitization
    run setup_worktree "myproj" "feature/task-123" "."
    assert_success
    # Should sanitize / to -
    run grep "feature-task-123" <<< "$output"
    assert_success
}

@test "main: age-based refresh tip" {
    source_toolbox
    # Force usage of remote tag by failing local inspect
    # And mock age to be old
    cat <<EOF > "$TEST_TEMP_DIR/bin/docker"
#!/bin/bash
if [[ "\$1" == "inspect" && "\$2" == "--format"* ]]; then
    echo "2020-01-01T00:00:00Z"
    exit 0
fi
if [[ "\$1" == "image" && "\$2" == "inspect" ]]; then 
    if [[ "\$3" == "gemini-cli-toolbox/cli:latest"* ]]; then exit 1; fi
    exit 0 
fi
echo "docker \$*" >> "$MOCK_DOCKER_LOG"
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/bin/docker"

    run main --bash
    assert_success
    assert_output --partial "Tip: Your Gemini image is"
}

@test "main: connect command bash session" {
    source_toolbox
    mock_docker
    run main connect gem-proj-bash-1
    assert_success
    run grep "docker exec .* bash" "$MOCK_DOCKER_LOG"
    assert_success
}

@test "main: connect command failure (no tmux)" {
    source_toolbox
    mock_docker
    # Mock docker exec to fail on tmux has-session
    cat <<EOF > "$TEST_TEMP_DIR/bin/docker"
#!/bin/bash
if [[ "\$1" == "exec" && "\$*" == *"tmux has-session"* ]]; then exit 1; fi
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/bin/docker"
    
    run main connect gem-proj-geminicli-1
    assert_failure
    assert_output --partial "Error: Reconnecting to this session is not supported"
}

@test "main: stop-hub command" {
    source_toolbox
    mock_docker
    # Hub script exists in bin/
    run main stop-hub
    assert_success
}

@test "main: connect command variants" {
    source_toolbox
    mock_docker
    
    # 1. Connect to bash session
    run main connect gem-proj-bash-123
    assert_success
    run grep "docker exec -it gem-proj-bash-123 gosu 0 bash" "$MOCK_DOCKER_LOG"
    assert_success
    
    # 2. Connect to tmux session (default)
    # We need to mock docker exec ... tmux has-session to succeed
    cat <<EOF > "$TEST_TEMP_DIR/bin/docker"
#!/bin/bash
if [[ "\$*" == *"tmux has-session"* ]]; then exit 0; fi
echo "docker \$*" >> "$MOCK_DOCKER_LOG"
exit 0
EOF
    run main connect gem-proj-geminicli-123
    assert_success
    run grep "docker exec -it gem-proj-geminicli-123 gosu 0 tmux attach -t gemini" "$MOCK_DOCKER_LOG"
    assert_success
}

@test "main: docker-args parsing" {
    source_toolbox
    mock_docker
    run main --docker-args "--link other:other -e KEY=VAL" --bash
    assert_success
    run grep "\-\-link other:other" "$MOCK_DOCKER_LOG"
    assert_success
    run grep "-e KEY=VAL" "$MOCK_DOCKER_LOG"
    assert_success
}

@test "setup_worktree: anonymous exploration (detached HEAD)" {
    source_toolbox
    mock_git
    run setup_worktree "myproj" "" "."
    assert_success
    run grep "exploration-" <<< "$output"
    assert_success
}

@test "setup_worktree: existing branch detection" {
    source_toolbox
    # Mock git to return success for show-ref
    cat <<EOF > "$TEST_TEMP_DIR/bin/git"
#!/bin/bash
if [[ "\$*" == *"show-ref --verify --quiet refs/heads/existing"* ]]; then exit 0; fi
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/bin/git"
    
    run setup_worktree "myproj" "existing" "."
    assert_success
}

@test "setup_worktree error: already in a worktree" {
    source_toolbox
    # Mock git rev-parse --show-toplevel to return a path, 
    # and then simulate a .git file (not directory) there.
    local fake_toplevel="$TEST_TEMP_DIR/fake-wt"
    mkdir -p "$fake_toplevel"
    touch "$fake_toplevel/.git" # File indicates it is a worktree
    
    # We must mock git to return this fake toplevel
    cat <<EOF > "$TEST_TEMP_DIR/bin/git"
#!/bin/bash
case "\$*" in
    *"rev-parse --show-toplevel"*) echo "$fake_toplevel"; exit 0 ;;
    *"rev-parse --is-inside-work-tree"*) exit 0 ;;
    *"rev-parse --verify HEAD"*) exit 0 ;;
    *) exit 0 ;;
esac
EOF
    chmod +x "$TEST_TEMP_DIR/bin/git"

    # Use bash -x to see why it succeeds
    run bash -x -c "source $PROJECT_ROOT/bin/gemini-toolbox; setup_worktree 'proj' 'branch' '.'"
    assert_failure
    assert_output --partial "Error: --worktree is not supported from within another worktree"
}

@test "main fails with both --config and --profile" {
    source_toolbox
    run main --config /tmp/c --profile /tmp/p --bash
    assert_failure
    assert_output --partial "Error: Cannot use both --config and --profile simultaneously."
}

@test "setup_worktree error: git worktree add fails" {
    source_toolbox
    # Mock git to fail specifically on worktree add
    cat <<EOF > "$TEST_TEMP_DIR/bin/git"
#!/bin/bash
if [[ "\$*" == *"worktree add"* ]]; then 
    echo "fatal: already exists" >&2
    exit 1
fi
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/bin/git"
    hash -r
    
    run setup_worktree "proj" "branch" "."
    assert_failure
    assert_output --partial "Error: Failed to create git worktree"
}

@test "main fails with --remote and missing key" {
    source_toolbox
    unset GEMINI_REMOTE_KEY
    run main --remote --bash
    assert_failure
    assert_output --partial "Error: TAILSCALE_KEY is required for --remote mode"
}

@test "main: dynamic branch tagging" {
    source_toolbox
    # Mock git to return a feature branch for the repo root
    # Note: repo_root is resolved from BASH_SOURCE
    cat <<EOF > "$TEST_TEMP_DIR/bin/git"
#!/bin/bash
if [[ "\$*" == *"rev-parse --abbrev-ref HEAD"* ]]; then echo "feature/fix-1"; exit 0; fi
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/bin/git"
    
    # Mock docker to succeed on inspect and log run
    cat <<EOF > "$TEST_TEMP_DIR/bin/docker"
#!/bin/bash
if [[ "\$1" == "image" && "\$2" == "inspect" ]]; then exit 0; fi
if [[ "\$1" == "run" ]]; then echo "docker \$*" >> "$MOCK_DOCKER_LOG"; fi
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/bin/docker"

    run bash -c "source $PROJECT_ROOT/bin/gemini-toolbox; main --bash"
    assert_success
    run grep "gemini-cli-toolbox/cli:latest-feature-fix-1" "$MOCK_DOCKER_LOG"
    assert_success
}

@test "main: preview variant image resolution" {
    source_toolbox
    mock_docker
    run main --preview --bash
    assert_success
    # Should check for local preview tag
    run grep "gemini-cli-toolbox/cli-preview:latest" "$MOCK_DOCKER_LOG"
    assert_success
}

@test "main: detached mode" {
    source_toolbox
    mock_docker
    run main --detached --bash
    assert_success
    run grep "docker run .* -d" "$MOCK_DOCKER_LOG"
    assert_success
}
