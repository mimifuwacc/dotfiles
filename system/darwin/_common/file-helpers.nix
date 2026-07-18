# Helpers for writing home.file entries as { "target" = "repo/path"; ... }
# mappings. Both take that mapping and expand to home.file entries; the only
# difference is how each file is linked into $HOME.
#
# Usage (from any home-manager module):
#   inherit (import ./file-helpers.nix { inherit lib config username dotfilesPath; })
#     storeCopies liveSymlinks;
{ lib, config, username, dotfilesPath }:
{
  # Store copy: files are copied into the Nix store, so they're immutable and
  # captured in the generation (rollback-able). Updates need `task apply`.
  storeCopies = lib.mapAttrs (_: path: { source = dotfilesPath path; force = true; });

  # Live symlink: points straight at the repo file, so edits take effect
  # immediately without a rebuild. Not captured in the generation.
  liveSymlinks = lib.mapAttrs (_: path: {
    source = config.lib.file.mkOutOfStoreSymlink "/Users/${username}/dotfiles/${path}";
    force = true;
  });
}
