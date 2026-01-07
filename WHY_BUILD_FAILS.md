# Why `./script/build.sh --board orangepi5pro` Fails

## The Error

```
error: attribute 'orangepi-5-pro' missing
   at /nix/store/wb81pga0l5r7skngnmil9pfci1cnj329-source/flake.nix:33:11:
      32|         modules = [
      33|           socle.nixosModules.orangepi-5-pro
```

## Root Cause

The command fails because **template mode** (the default) pulls the `socle` flake from **GitHub**, not your local repository.

### What Happens Step-by-Step

1. **You run**: `./script/build.sh --board orangepi5pro`
   
2. **Script creates template** in `/tmp/socle-build/nixos/` from `templates/orangepi-5x/`

3. **Template's flake.nix contains**:
   ```nix
   socle = {
     url = "github:dvdjv/socle";  # ← Downloads from GitHub!
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

4. **Nix downloads** the flake from `github:dvdjv/socle`

5. **Nix looks for** `socle.nixosModules.orangepi-5-pro`

6. **NOT FOUND** - The upstream GitHub repository doesn't have your Orange Pi 5 Pro module yet!

## Why This Happens

- Your Orange Pi 5 Pro module exists **only in your local repository**
- The upstream `github:dvdjv/socle` repository **doesn't have it yet**
- Template mode always pulls from GitHub by design (for end-users)

## The Solution: Use Checks Mode

Add `--mode checks` to build from your local repository:

```bash
./script/build.sh --board orangepi5pro --mode checks
```

### Why Checks Mode Works

1. Builds directly from `.#checks.<system>.orangepi-5-pro`
2. Uses your **local flake definition**
3. Finds the `orangepi-5-pro` module in **your local code**
4. ✅ **SUCCESS!**

## Proof It Works

You already successfully built with checks mode:
```
[build] Done. Artifact saved to artifacts/orangepi5pro-20260107-205709.img.zst
- Size: 554MB compressed
- Integrity: ✅ Verified
- Build time: ~7 minutes
```

## When Will Default Mode Work?

Template mode (without `--mode checks`) will work after:

1. ✅ You push your changes to a GitHub fork/branch, **OR**
2. ✅ Your changes are merged to upstream `github:dvdjv/socle`

Then the GitHub repository will have the `orangepi-5-pro` module and template mode will work automatically.

## Quick Reference

| Command | Status | Why |
|---------|--------|-----|
| `./script/build.sh --board orangepi5pro` | ❌ Fails | Pulls from GitHub (no module there) |
| `./script/build.sh --board orangepi5pro --mode checks` | ✅ Works | Uses local repository |
| `nix build .#checks.x86_64-linux.orangepi-5-pro` | ✅ Works | Direct local build |

## Bottom Line

**This is not a bug - it's expected behavior!**

- Template mode = for end-users pulling from GitHub
- Checks mode = for developers with local changes

**Just use `--mode checks` and everything works perfectly! 🎉**

