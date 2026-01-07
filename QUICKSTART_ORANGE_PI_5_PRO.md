# Quick Start: Orange Pi 5 Pro

## Build SD Image with Docker (Easiest)

```bash
# Build Orange Pi 5 Pro image using checks mode
./script/build.sh --board orangepi5pro --mode checks

# Output: artifacts/orangepi5pro-YYYYMMDD-HHMMSS.img.zst
```

**Note**: Use `--mode checks` for local builds. Template mode (without `--mode`) requires upstream repository merge.

## Build SD Image with Nix Template (After Upstream Merge)

```bash
# This will work once changes are merged to github:dvdjv/socle
nix flake new -t github:dvdjv/socle nixos
cd nixos

# Build the image
nix build .#nixosConfigurations.orangepi5pro.config.system.build.sdImage

# Output: result/sd-image/*.img.zst
```

## Flash to SD Card

```bash
# Decompress and write to SD card
zstdcat result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=1M status=progress

# Replace /dev/sdX with your SD card device (check with lsblk or diskutil list)
```

## Customize Configuration

Edit `orangepi5pro.nix`:

```nix
{ ... }: {
  # Enable/disable hardware features
  board.hardware.enabled = {
    # WiFi/Bluetooth (AP6256 module)
    wifi-ap6275p = true;
    
    # Disable status LEDs
    leds = false;
    
    # Enable M.2 NVMe/SATA
    ssd-sata0 = true;
    
    # Enable 8K HDMI output
    hdmi2-8k = true;
    
    # Enable CAN bus
    can0-m0 = true;
    can1-m0 = true;
    
    # Enable additional UART ports
    uart6-m1 = true;
    uart7-m2 = true;
    
    # Enable SPI
    spi0-m2-cs0-spidev = true;
  };
  
  networking.hostName = "orangepi5pro";
}
```

## Default Login

- **Username**: nixos
- **Password**: nixos
- **Note**: User has sudo access (wheel group)

## Network Configuration

The Orange Pi 5 Pro has:
- Gigabit Ethernet (onboard)
- WiFi 5 (802.11ac, 2.4/5GHz dual-band) - requires `wifi-ap6275p = true;`
- Bluetooth 5.0 - included with WiFi module

## Available Hardware Overlays

### CAN Bus
- `can0-m0`, `can1-m0`

### I2C
- `i2c2-m0`, `i2c2-m4`, `i2c4-m3`, `i2c5-m3`, `i2c8-m2`

### UART
- `uart1-m1`, `uart3-m1`, `uart4-m2`, `uart6-m1`, `uart7-m2`, `uart8-m1`

### SPI
- `spi0-m2-cs0-spidev`, `spi0-m2-cs1-spidev`, `spi0-m2-cs0-cs1-spidev`
- `spi4-m1-cs0-spidev`, `spi4-m1-cs1-spidev`, `spi4-m1-cs0-cs1-spidev`
- `spi4-m2-cs0-spidev`

### PWM
- `pwm0-m0`, `pwm0-m2`, `pwm1-m0`, `pwm1-m2`
- `pwm11-m0`, `pwm12-m0`, `pwm13-m0`, `pwm14-m0`, `pwm14-m2`

### Display
- `lcd` - MIPI DSI LCD panel
- `hdmi2-8k` - Enable 8K@60Hz on HDMI 2.1
- `hdmirx` - HDMI input receiver

### Camera
- `gc5035` - GC5035 camera sensor
- `ov13850` - OV13850 camera sensor
- `ov13855` - OV13855 camera sensor

### Storage
- `ssd-sata0` - SATA on M.2 slot 0
- `ssd-sata2` - SATA on M.2 slot 2

### Other
- `leds` - Control status LEDs (set to false to disable)
- `dmc` - Dynamic Memory Controller
- `wifi-ap6275p` - WiFi/Bluetooth module (AP6256)
- `wifi-pcie` - PCIe WiFi module (alternative)

## Troubleshooting

### WiFi Not Working
Enable the WiFi overlay in `orangepi5pro.nix`:
```nix
board.hardware.enabled.wifi-ap6275p = true;
```

### M.2 NVMe Not Detected
Enable the storage overlay:
```nix
board.hardware.enabled.ssd-sata0 = true;  # or ssd-sata2
```

### Serial Console Access
Connect to the 3-pin debug UART on the 40-pin GPIO header:
- Baud rate: 1500000
- Format: 8N1 (8 data bits, no parity, 1 stop bit)
- Console: `ttyFIQ0`

### Check Available Outputs
```bash
# List all buildable configurations
nix flake show

# List all available hardware overlays
nix eval .#nixosModules.orangepi-5-pro --apply 'x: builtins.attrNames x.board.hardware.available'
```

## Performance Notes

- **CPU**: 8 cores (4×A76@2.4GHz + 4×A55@1.8GHz)
- **RAM**: LPDDR5 (4/8/16GB variants)
- **GPU**: Mali-G610 MP4 with OpenGL ES 3.2, OpenCL 2.2, Vulkan 1.2
- **NPU**: 6 TOPS AI acceleration (INT4/INT8/INT16)
- **Video**: Hardware decode 8K@60fps H.265/VP9, 8K@30fps H.264
- **Video Encode**: 8K@30fps H.265/H.264

## Docker Build Options

```bash
# Default: Template mode, Orange Pi 5 Pro
./script/build.sh --board orangepi5pro

# Use checks mode (faster, no customization)
./script/build.sh --board orangepi5pro --mode checks

# Help
./script/build.sh --help
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Orange Pi 5 Pro Official Page](http://www.orangepi.org/)
- [Rockchip RK3588 Documentation](https://www.rock-chips.com/)
- Repository: https://github.com/dvdjv/socle

