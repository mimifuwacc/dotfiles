#!/usr/bin/env -S nix shell nixpkgs#nushell --command nu

# Get the latest version from NotchNook's download URL
def get_latest_version [] {
  # For now, the version is hardcoded in the URL
  # You may need to update this manually or scrape from their website
  "1.5.5"
}

# Prefetch SRI hash using nix store prefetch-file
def get_nix_hash [url: string] {
  nix store prefetch-file --hash-type sha256 --json $url
    | from json
    | get hash
}

def generate_sources [] {
  let version = get_latest_version
  let prev_sources = try { open ./sources.json } catch { { version: "" } }

  if $version == $prev_sources.version {
    echo $"Latest version is ($version), no updates found"
    return $version
  }

  # NotchNook URL
  let url = $"https://oqafd6eucpuqjhqx.public.blob.vercel-storage.com/NotchNook-($version).zip"

  # Create sources record
  let sources = {
    version: $version
    url: $url
    hash: (get_nix_hash $url)
  }

  echo $sources | save --force "sources.json"

  echo $"Updated to version ($version)"
  return $version
}

generate_sources
