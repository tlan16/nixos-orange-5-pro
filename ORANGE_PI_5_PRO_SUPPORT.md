# Orange Pi 5 Pro Support - Implementation Summary

## Overview
Added full support for the Orange Pi 5 Pro board to the nixos-orange-5-pro repository. The Orange Pi 5 Pro uses the RK3588S SoC (same as Orange Pi 5 Plus) and shares most hardware characteristics.

## Changes Made

### 1. Module Definition (`modules/default.nix`)
- Added `orangepi-5-pro` module with complete hardware overlay support
- Reuses `ubootOrangePi5Plus` package (same SoC family)
- Configured hardware overlays for:
  - WiFi/Bluetooth (AP6256 module via AP6275P overlay)
  - CAN bus (can0-m0, can1-m0)
  - I2C interfaces (i2c2-m0, i2c2-m4, i2c4-m3, i2c5-m3, i2c8-m2)
  - SPI interfaces (multiple configurations)
  - UART ports (uart1-m1, uart3-m1, uart4-m2, uart6-m1, uart7-m2, uart8-m1)
  - PWM channels (pwm0-m0/m2, pwm1-m0/m2, pwm11/12/13/14-m0, pwm14-m2)
  - Camera support (gc5035, ov13850, ov13855)
  - Display support (LCD, HDMI 8K, HDMIRX)
  - Storage (SATA on M.2 slots)
  - LED control
  - DMC (Dynamic Memory Controller)

### 2. Flake Outputs (`flake.nix`)
- Added `orangepi-5-pro` to checks outputs
- Enables building via `nix build .#checks.<system>.orangepi-5-pro`

### 3. Template Files
- Created `templates/orangepi-5x/orangepi5pro.nix` with board-specific configuration
- Updated `templates/orangepi-5x/flake.nix` to include `orangepi5pro` configuration
- Template supports all standard NixOS module imports

### 4. Build Script (`script/build.sh`)
- Added `orangepi5pro` as a supported board option
- Updated help text and validation
- Added board name mapping: `orangepi5pro` → `orangepi-5-pro`
- Both template and checks modes fully support the new board

### 5. Documentation (`README.md`)
- Added Orange Pi 5 Pro to supported boards list
- Updated all build examples to include Orange Pi 5 Pro commands
- Updated board-specific file references

## Hardware Specifications Mapped

Based on the Orange Pi 5 Pro specs:
- **SoC**: Rockchip RK3588S (8nm, 8-core ARMv8)
- **CPU**: 4×A76@2.4GHz + 4×A55@1.8GHz
- **GPU**: Mali-G610 MP4 (OpenGL ES 3.2, OpenCL 2.2, Vulkan 1.2)
- **NPU**: 6 TOPS AI acceleration
- **Memory**: LPDDR5 (4GB/8GB/16GB variants)
- **Storage**: eMMC socket, microSD, M.2 NVMe PCIe 2.0×1
- **Video**: HDMI 2.1 (8K@60Hz), HDMI 2.0 (4K@60Hz), MIPI DSI (4K@60Hz)
- **Camera**: 2× MIPI CSI (4-lane each)
- **USB**: 1× USB 3.1 Gen1, 2× USB 2.0, 1× USB Type-C OTG
- **Networking**: Gigabit Ethernet with PoE+ support, Wi-Fi 5 (802.11ac), Bluetooth 5.0
- **Audio**: ES8388 codec, 3.5mm combo jack, onboard mic, HDMI eARC
- **GPIO**: 40-pin header (GPIO, UART, PWM, I2C, SPI, CAN)

## Usage Examples

### Building with Docker (Recommended)

```fish
# Orange Pi 5 Pro using template mode (default)
./script/build.sh --board orangepi5pro

# Orange Pi 5 Pro using checks mode
./script/build.sh --board orangepi5pro --mode checks
```

### Building with Nix Flake Template

```fish
# Initialize from template
nix flake new -t github:dvdjv/socle nixos
cd nixos

# Build Orange Pi 5 Pro image
nix build .#nixosConfigurations.orangepi5pro.config.system.build.sdImage

# Flash to SD card
zstdcat result/sd-image/*.img.zst | dd of=/dev/sdX bs=1M
```

### Building from Repository Checks

```fish
# On x86_64-linux
nix build .#checks.x86_64-linux.orangepi-5-pro

# On aarch64-linux
nix build .#checks.aarch64-linux.orangepi-5-pro
```

## Hardware Configuration

Edit `orangepi5pro.nix` to enable hardware features:

```nix
board.hardware.enabled = {
  # Disable LEDs
  leds = false;
  
  # Enable WiFi/Bluetooth (AP6256 module)
  wifi-ap6275p = true;
  
  # Enable CAN bus
  can0-m0 = true;
  
  # Enable additional UART
  uart6-m1 = true;
  
  # Enable SPI
  spi0-m2-cs0-spidev = true;
  
  # Enable M.2 NVMe/SATA
  ssd-sata0 = true;
  
  # Enable HDMI 8K support
  hdmi2-8k = true;
};
```

## Testing Status

- ✅ Module syntax validated
- ✅ Flake outputs validated
- ✅ Template files validated
- ✅ Build script syntax validated
- ✅ All files pass static analysis
- ⚠️ Runtime testing pending (requires physical Orange Pi 5 Pro hardware)

## Notes

1. **U-Boot Compatibility**: Orange Pi 5 Pro reuses the Orange Pi 5 Plus u-boot package since both boards use the same RK3588S SoC and similar boot architecture.

2. **Device Tree Overlays**: The Orange Pi 5 Pro shares most device tree overlays with the Orange Pi 5 Plus. Board-specific overlays use the `rk3588-opi5plus-*` prefix until Orange Pi 5 Pro-specific overlays are available upstream.

3. **WiFi Module**: The Orange Pi 5 Pro includes the AP6256 WiFi/Bluetooth module (not AP6275P), but the overlay name remains `wifi-ap6275p` for driver compatibility.

4. **Cross-Compilation**: Building on x86_64 for aarch64 is supported but may be slower. Native aarch64 builds are recommended for faster iteration.

5. **PoE+ Support**: PoE+ functionality (up to 95W) requires a compatible HAT adapter (not included by default).

## Files Modified

- `modules/default.nix` - Added orangepi-5-pro module
- `flake.nix` - Added orangepi-5-pro to checks
- `templates/orangepi-5x/flake.nix` - Added orangepi5pro configuration
- `templates/orangepi-5x/orangepi5pro.nix` - New board-specific config
- `script/build.sh` - Added orangepi5pro support
- `README.md` - Updated documentation

## Next Steps

1. Test on physical Orange Pi 5 Pro hardware
2. Verify all hardware overlays function correctly
3. Add board-specific device tree overlays if needed
4. Update firmware packages if Orange Pi 5 Pro requires specific blobs
5. Document any hardware quirks or special configuration requirements

