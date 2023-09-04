# rivian-usb

## What is This?

**Short answer:** It's a smart USB drive for [Rivians](https://rivian.com).

**Longer answer:** Rivian vehicles support USB storage for video recordings, but
accessing those video files means unplugging from the vehicle, plugging into a
computer, and manually copying the files. With rivian-usb, the USB storage stays
plugged into your vehicle, and the files are automatically archived to your
destination of choice once you drive back into Wi-Fi range.

## Status

:rotating_light: This is alpha-quality software. :rotating_light:

Expect major features to be broken or missing. Data loss may occur.

For now, see the `dev` branch for the latest.

### 0.0.1 TODO

- [x] Script framework
- [x] Image building
- [ ] Auto-updating
- [ ] USB data volume
- [ ] Data backup

## Installation

1. Have a Raspberry Pi + SD card. (Only tested with a Pi 4, so far.)
2. On a linux system, build a rivian-usb image: `make image`
   - The image is built with [pi-gen](https://github.com/RPi-Distro/pi-gen),
     in Docker. See their docs for more details.
3. Using the [Raspberry Pi imager](https://github.com/raspberrypi/rpi-imager):
   - Open the .img file you just built, from image/build/
   - Click the gear icon to configure your ssh key, user name, Wi-Fi, etc.
   - Write the image to an SD card

## Credit

This project is very much inspired by [teslausb][1]. If you have a Tesla, try
it out!


[1]: https://github.com/marcone/teslausb
