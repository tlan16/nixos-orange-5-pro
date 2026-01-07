# Build Mode Troubleshooting

## Template Mode Error: "attribute 'orangepi-5-pro' missing"

### Problem
When running:
```bash
./script/build.sh --board orangepi5pro
```

You get an error:
```
error: attribute 'orangepi-5-pro' missing
   at /nix/store/wb81pga0l5r7skngnmil9pfci1cnj329-source/flake.nix:33:11:
      32|         modules = [
      33|           socle.nixosModules.orangepi-5-pro
         |           ^
```

### Why This Happens

Template mode (the default) materializes the flake template from `templates/orangepi-5x/`, which contains:

```nix
socle = {
  url = "github:dvdjv/socle";  # <-- Pulls from GitHub!
  inputs.nixpkgs.follows = "nixpkgs";
};
```

The template references the upstream GitHub repository (`github:dvdjv/socle`), not your local changes. Since the Orange Pi 5 Pro module hasn't been merged upstream yet, the GitHub version doesn't have `nixosModules.orangepi-5-pro`.

### Solution: Use Checks Mode

The **checks mode** builds directly from your local repository, where the Orange Pi 5 Pro module exists:

```bash
./script/build.sh --board orangepi5pro --mode checks
```

This works because it builds from `.#checks.<system>.orangepi-5-pro`, which uses the local flake definition.

### Comparison

| Mode | Source | Status | Use Case |
|------|--------|--------|----------|
| **Template** | `github:dvdjv/socle` | ❌ Fails (module not upstream) | After merge |
| **Checks** | Local repository | ✅ Works | Development & testing |

### When Will Template Mode Work?

Template mode will work after:
1. Your changes are pushed to a fork or branch
2. You update the template's `socle.url` to point to your fork/branch, OR
3. Your changes are merged to the upstream `github:dvdjv/socle` repository

### Workaround: Local Template Override

If you really need to use template mode with local changes, you can modify the template after materialization:

```bash
# Materialize the template
nix flake new -t .#orangepi-5x nixos
cd nixos

# Edit flake.nix to use local socle
sed -i 's|url = "github:dvdjv/socle"|url = "path:/Users/frank.lan/Projects/nixos-orange-5-pro"|' flake.nix

# Now build
nix build .#nixosConfigurations.orangepi5pro.config.system.build.sdImage
```

But this is more complex than just using checks mode.

### Recommended Workflow

**For local development and testing:**
```bash
./script/build.sh --board orangepi5pro --mode checks
```

**For production after upstream merge:**
```bash
./script/build.sh --board orangepi5pro
# (template mode is the default)
```

### Summary

✅ **Use `--mode checks` for local builds** - it works with your local changes
⏳ **Template mode requires upstream merge** - it pulls from GitHub

The error is expected and doesn't indicate a problem with your integration. Your Orange Pi 5 Pro support is complete and working correctly in checks mode!

