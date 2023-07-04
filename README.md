# rivian-usb

## What is This?

Short answer: If you're familiar with the [teslausb project][1], it's like that,
but for Rivians.

Longer answer: Rivian vehicles support USB storage for video recordings, but
accessing those video files means unplugging from the vehicle, plugging into a
computer, and manually copying the files. With rivian-usb, the USB storage stays
plugged into your vehicle, and the files are automatically archived to your
destination of choice once you drive back into Wi-Fi range.

This project is very much inspired by [teslausb][1].

## Status

:rotating_light: This is alpha-quality software. :rotating_light:

Expect major features to be broken or missing. Data loss may occur.

## Installation

1. Have a Raspberry Pi, and follow the
  [teslausb setup instructions](https://github.com/marcone/teslausb/blob/main-dev/doc/OneStepSetup.md).
2. Once you're up and running, reconfigure the system to use rivian-usb:
    1. `ssh` into your Raspberry Pi
    2. Edit your configuration:
        ```shell
        sudo /root/bin/remountfs_rw
        sudo ${EDITOR-nano} /root/teslausb_setup_variables.conf
        ```
    3. Set these two variables:
        ```shell
        export REPO=rivian-community
        export BRANCH=dev
        ```
    4. Apply your changes:
        ```shell
        sudo /root/bin/setup-teslausb upgrade
        ```

After rebooting, your system should be running the latest scripts from this
repository's "dev" branch.

## Development

To install the latest dev version:

```shell
curl -L https://github.com/rivian-community/rivian-usb/archive/dev.tar.gz |
  tar zxf - --one-top-level=riv-tmp --strip-components=1
riv-tmp/src/bin/riv install -f dev
rm -rf riv-tmp
```

At this point `riv` should be in your path (/usr/local/bin/riv), and you can
install further updates with `riv install`.

[1]: https://github.com/marcone/teslausb
