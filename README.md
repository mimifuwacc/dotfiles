# Dotfiles

macOS (Darwin) dotfiles managed with Nix flakes and nix-darwin.

## Quick Start

```bash
# Apply configuration
task darwin:apply

# Or manually
sudo darwin-rebuild switch --flake ~/dotfiles/nix/darwin --impure
```

## Keyboard Remapping (Kanata)

This setup uses **Kanata** for Caps Lock → Left Control remapping, which requires **Karabiner-Elements**' virtual HID driver.

### First-time Setup (Required)

**macOS requires manual approval for system extensions** - this is a security restriction that cannot be automated.

1. **Apply configuration**
   ```bash
   task darwin:apply
   ```

2. **Approve system extension**
   - Open **System Settings** > **Privacy & Security** > **System Extensions**
   - Click **Allow** next to "Karabiner-DriverKit-VirtualHIDDevice"
   - You may need to click "Modify" or "Allow" in the prompt that appears

3. **Complete driver activation**
   ```bash
   open /Applications/Karabiner-Elements.app
   ```
   - The Karabiner-Elements app will open and complete the driver setup
   - You can close the app after it opens

4. **Restart Kanata service**
   ```bash
   sudo launchctl kickstart -k system/org.nixos.kanata
   ```

### Verify it's working

```bash
# Check if Kanata is running
launchctl list | grep kanata

# Check Kanata logs
cat /tmp/kanata.out.log

# Test: Press Caps Lock - it should act as Control
```

### Troubleshooting

**Kanata fails to start with driver error:**
- Repeat steps 2-4 above
- Make sure you've opened Karabiner-Elements at least once
- Check System Extensions in System Settings

**Caps Lock doesn't work:**
- Verify Kanata is running: `launchctl list | grep kanata`
- Check logs: `cat /tmp/kanata.err.log`
- Try restarting: `sudo launchctl kickstart -k system/org.nixos.kanata`

## Configuration Structure

```
nix/darwin/
├── flake.nix       # Flake inputs and outputs
├── darwin.nix      # System-level config
└── home.nix        # User-level config
```

See [CLAUDE.md](CLAUDE.md) for detailed documentation.

## Requirements

- macOS (Apple Silicon)
- Nix with flakes enabled
- nix-darwin
- Home Manager

## License

MIT
