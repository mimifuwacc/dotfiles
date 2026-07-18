# File Management Rules

Rules for writing `home.file` entries.

## Preferred: the `storeCopies` / `liveSymlinks` helpers

`_common/file-helpers.nix` exposes two helpers that take a
`{ "target" = "repo/path"; ... }` mapping and expand it into `home.file`
entries. Use them from any home-manager module — both `_common/home.nix` and
each `<hostname>/hosts.nix`:

```nix
inherit (import ../_common/file-helpers.nix { inherit lib config username dotfilesPath; })
  storeCopies liveSymlinks;

home.file =
  storeCopies {          # copied into the Nix store (needs `task apply` to update)
    "Taskfile.yaml" = "Taskfile.yaml";
  }
  // liveSymlinks {       # live symlink to the repo (edits apply immediately)
    ".config/ghostty/config" = "ghostty/config";
  };
```

- **`storeCopies`** - file is copied into the Nix store: immutable, captured in the generation (rollback-able). For rarely-edited files.
- **`liveSymlinks`** - `mkOutOfStoreSymlink` straight to the repo file: edits take effect without a rebuild. For frequently-edited config files.
- **Use `.text` for tiny inline content** - `"file.txt".text = "content"` instead of sourcing a file.

## The `dotfilesPath` function

`dotfilesPath = path: ./../../${path}` (defined in `flake.nix`) resolves a path
relative to the repo root. The `./../../` is anchored to `flake.nix`'s location
at parse time, so it resolves the same **from any module**, including
`hosts.nix` — it does not depend on the caller. `storeCopies` uses it under the
hood, so you rarely call it directly for `home.file`; it is mainly for
`imports` (e.g. `dotfilesPath "zsh/default.nix"`).

## DON'T

- **Don't hand-write repetitive `home.file."x".source = ...`** - Use the helpers above so store-copy vs live-symlink intent stays obvious.
- **Don't assume paths are caller-relative** - Nix path literals are anchored to the file that contains them, not to where a function is called.

## VSCode Settings Management

For VSCode settings that you edit frequently, use `mkOutOfStoreSymlink`:

1. Place settings.json in `vscode/<hostname>/settings.json`
2. In `hosts.nix`:
   ```nix
   home.file."Library/Application Support/Code/User/settings.json".source =
     config.lib.file.mkOutOfStoreSymlink /Users/mimifuwacc/dotfiles/vscode/anemone/settings.json;
   ```
3. Remove existing settings.json before first apply: `rm ~/Library/Application Support/Code/User/settings.json`
4. Run `task apply`

**Benefits:**
- File stays in dotfiles, not copied to Nix store
- Edits take effect immediately without rebuilding
- Changes persist across Nix garbage collection
