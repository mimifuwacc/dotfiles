# Security & Validation Rules

Rules for ensuring safe and correct configuration application.

## HOSTNAME VALIDATION

- **Always check hostname before changes** - Use `hostname -s | tr '[:upper:]' '[:lower:]'`
- **Apply script validates hostname** - Prevents accidental cross-machine configuration
- **Hostnames must match exactly** - Current hostname must equal target hostname

## SAFETY MEASURES

- **Never apply cross-machine configs** - The apply script enforces this
- **Hostname validation is intentional** - It's a safety feature, not a bug

## ERROR EXAMPLE

```
Error: This configuration is for 'anemone', but current hostname is 'nemophila'
```

This means you're on the wrong machine. The configuration is being blocked for your safety.

## ENVIRONMENT VARIABLES

The apply script automatically sets and preserves:
- `_USERNAME` - Current username from `whoami`
- `_HOSTNAME` - Target hostname in lowercase

These are required for proper Nix flake evaluation.
