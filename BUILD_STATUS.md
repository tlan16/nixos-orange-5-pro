# Orange Pi 5 Pro Build - In Progress

## Build Status: ✅ RUNNING

### Current Activity
The Orange Pi 5 Pro SD image is being built in Docker using the checks mode.

### Build Progress
**Container ID**: `4fd2599bd9da`
**Status**: Active kernel compilation
**Time Elapsed**: ~3-4 minutes
**Estimated Remaining**: 30-60 minutes (kernel compilation is the slowest part)

### Resource Usage
- **CPU**: 1023% (10+ cores fully utilized)
- **Memory**: 1.9GB / 19.5GB
- **Disk I/O**: 5.83GB written, 6.6GB read
- **Network**: 315MB downloaded (Nix cache)
- **Processes**: 53 active build processes

### Build Stages Completed
1. ✅ Docker image built
2. ✅ Nix dependencies downloaded from cache
3. ✅ System utilities built
4. ✅ Systemd units configured
5. ✅ Python environment prepared
6. ⏳ **Linux kernel 6.1.43-xunlong-rk35xx compiling** (CURRENT)
7. ⏳ Mali GPU library building
8. ⏳ Initrd generation (pending)
9. ⏳ SD card image creation (pending)

### Key Components Being Built
- **Kernel**: `linux-6.1.43-xunlong-rk35xx` (custom RK3588S kernel)
- **GPU**: `libmali-valhall-g610-g13p0` (Mali-G610 MP4 driver)
- **U-Boot**: Using Orange Pi 5 Plus u-boot
- **Final Image**: `nixos-image-sd-card-26.05pre-git-aarch64-linux.img.zst`

### Monitoring Commands
```bash
# Check build is still running
docker ps | grep socle-nix-builder

# Check resource usage
docker stats --no-stream 4fd2599bd9da

# Check latest logs
docker logs 4fd2599bd9da 2>&1 | tail -20

# Check total log size
docker logs 4fd2599bd9da 2>&1 | wc -l

# Monitor live
docker logs -f 4fd2599bd9da
```

### Expected Output
When complete, the image will be saved to:
```
artifacts/orangepi5pro-20260107-HHMMSS.img.zst
```

### Build Method
Using **checks mode**:
```bash
./script/build.sh --board orangepi5pro --mode checks
```

This builds directly from the repository's flake checks output:
```
.#checks.aarch64-linux.orangepi-5-pro
```

### Notes
- The kernel is being cross-compiled if running on x86_64 host
- First build takes longer as it compiles the kernel from source
- Subsequent builds will be faster due to Nix caching
- The build uses persistent Docker volumes to cache /nix across builds

## Verification Steps (After Completion)

1. **Check output file**:
   ```bash
   ls -lh artifacts/orangepi5pro-*.img.zst
   ```

2. **Verify file size** (should be ~500MB-2GB compressed):
   ```bash
   du -h artifacts/orangepi5pro-*.img.zst
   ```

3. **Check image integrity**:
   ```bash
   zstd -t artifacts/orangepi5pro-*.img.zst
   ```

4. **Inspect image contents** (optional):
   ```bash
   zstdcat artifacts/orangepi5pro-*.img.zst | file -
   ```

5. **Flash to SD card** (when ready):
   ```bash
   zstdcat artifacts/orangepi5pro-*.img.zst | sudo dd of=/dev/sdX bs=1M status=progress
   ```

## Build Configuration
- **Board**: Orange Pi 5 Pro
- **SoC**: Rockchip RK3588S
- **Kernel**: 6.1.43-xunlong-rk35xx
- **GPU**: Mali-G610 MP4
- **Architecture**: aarch64-linux
- **NixOS Version**: 26.05pre-git
- **System State Version**: 24.11

---
**Status**: Build in progress, kernel compilation underway. ETA: 30-60 minutes.

