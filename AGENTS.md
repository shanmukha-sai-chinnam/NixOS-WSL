# Repository Agent Guidelines: NixOS-WSL

Guidelines and constraints for AI coding agents developing, testing, and resolving issues in `NixOS-WSL`.

## Strict Operating Context: NixOS-WSL

- **Strict WSL Target**: All commands, edits, git operations, builds, formatters, and tests MUST be executed strictly inside NixOS-WSL (`/home/damathryxx64/`).
- **No Direct Windows Work**: Do NOT modify Windows host files directly unless specifically required for host interoperability testing.
- **Dots-Driven**: The central dots repository (`damathryxx64`) imports this repository via `inputs.nixos-wsl` as the primary driver.

---

## Repository Architecture

| Path | Purpose | Key Details |
|---|---|---|
| `flake.nix` | Flake entry point | Exposes `nixosModules.wsl` (and `.default`), `checks`, `packages`, `devShells` |
| `modules/wsl-distro.nix` | Core WSL distro module | Options: `wsl.enable`, `wsl.defaultUser`, `wsl.extraBin`, `wsl.tarball` |
| `modules/systemd/` | Systemd integration | Native systemd support (`modules/systemd/native/`) and `systemd-shim` |
| `modules/usbip.nix` | USB/IP integration | Auto-attaches Windows host USB devices via `usbipd-win` |
| `modules/recovery.nix` | Recovery shell | `nixos-wsl-recovery` tool launched from the WSL system distribution |
| `modules/docker-desktop.nix`| Docker Desktop bridge | Integration with Docker Desktop WSL engine |
| `modules/interop.nix` | Windows interop | `binfmt_misc`, Windows PATH appending, and `/init` integration |
| `checks/` | Upstream CI validation | `nixpkgs-fmt.nix`, `rustfmt.nix`, `options-doc.nix`, `side-effects.nix`, `username.nix` |
| `utils/` | Rust helper binaries | `systemd-shim`, `nixos-wsl-welcome`, etc. Built via Cargo / `rustPlatform` |
| `tests/` | Integration tests | WSL test suites |

---

## Formatting & Code Quality Standards

> [!WARNING]
> **Formatter Policy**: Upstream `nix-community/NixOS-WSL` uses `nixpkgs-fmt`, NOT `alejandra`.
> Do NOT run `alejandra` on this repository, as it will cause CI check failures in `checks/nixpkgs-fmt.nix`.

- **Nix Formatting**: `nixpkgs-fmt .`
- **Rust Formatting**: `cargo fmt` or `rustfmt`
- **Shell Scripts**: `shfmt -i 2 -ci -w <script>` and verify with `shellcheck`
- **Flake Validation**: `nix flake check` runs all upstream checks in sandbox.

---

## Validation Pipeline Before Committing

Always execute the following validation steps before committing or pushing changes:

```sh
# 1. Format check
nixpkgs-fmt --check .

# 2. Complete upstream checks
nix flake check

# 3. Test system build evaluation
nix build .#nixosConfigurations.default.config.system.build.toplevel --no-link
```

---

## Upstream Contribution & Fork Hygiene

- **Remotes**:
  - `origin`: `https://github.com/shanmukha-sai-chinnam/NixOS-WSL.git` (Your fork)
  - `upstream`: `https://github.com/nix-community/NixOS-WSL.git` (Upstream repo)
- **Branching**:
  - Keep `main` in sync with `upstream/main`.
  - For bugfixes or features intended for upstream PRs, create dedicated branches: `fix/<issue-topic>` or `feat/<feature-topic>`.
- **Commit Messages**: Follow Conventional Commits format (e.g. `fix(recovery): mount /nix before invoking nixos-enter in recovery shell`).
