# dots-tsapt

Install `apt` packages on a ChatGPT Dots cloud computer without root.

A Dots computer has no `sudo` and its system folders are read-only, so normal `apt` fails. `tsapt` runs the real `apt-get` with its own configuration and unpacks packages into a folder you own.

It downloads through the Dots platform proxy (`browser-proxy:8889`). It needs no Tailscale, no exit node and no SSH, and it does not touch your shell profile.

## Install

No terminal needed. Send this to your dot:

> Clone `https://github.com/e-kotov/dots-tsapt` at tag `v0.1.0` into `/workspace/shared/dots-tsapt`, using `HTTPS_PROXY=http://browser-proxy:8889` and `HTTP_PROXY=http://browser-proxy:8889`. Run `bash install.sh`, then `/workspace/shared/.tsapt/bin/tsapt update` and `/workspace/shared/.tsapt/bin/tsapt install -y iperf3`, then `/workspace/shared/.tsapt/bin/tsrun iperf3 --version`. Show me the output.

It works if the last command prints a version.

Files go under `/workspace/shared` because a Dots cleanup on 2026-10-23 was reported to delete other top-level `/workspace` folders.

## Use

```bash
tsapt update                    # refresh package lists
tsapt install -y <package>      # install with dependencies
tsapt list                      # what tsapt installed
tsapt remove <package>
tsrun <program> [arguments]     # run an installed program
```

Both commands live in `/workspace/shared/.tsapt/bin`. `tsrun` sets the library path for that one program, so installed libraries cannot affect anything else on the computer.

To use another proxy, or none, edit `TSAPT_PROXY` in `/workspace/shared/.tsapt/tsapt.conf`. `off` means a direct connection.

## What to expect

- **Install scripts are skipped.** Packages that need a background service, new users, setuid or generated configuration may not work.
- **Fixed paths can fail.** A program that looks for data in `/usr/share/...` will not find it under the tsapt folder without an option pointing there.
- **`python3-*` packages** match the system `/usr/bin/python3`. If your shell uses another Python, prefer `pip`.
- **What is installed** is inferred from `/usr/share/doc`, because the Dots image has no dpkg database. It can be wrong for an unusual package.

## Security

- The platform proxy can see which packages you fetch. `apt`'s signature checks protect their contents. `tsapt` does not turn those checks off.
- Packages run with your account's rights, including access to anything else stored there. Use official sources.
- `tsapt` opens no network path that the Dots computer does not already have.

## Optional: dots-tailscale

`install-dots-tailscale.sh` installs [dots-tailscale](https://github.com/abruption/dots-tailscale) `v0.8.0`, unmodified, and refuses to continue if the code does not match the pinned commit. It places everything under `/workspace/shared` and does not sign in. `tsapt` does not use it. For signing in and for the SSH access dots-tailscale provides, read its [usage guide](https://github.com/abruption/dots-tailscale/blob/main/docs/usage.md).

## Testing

CI installs and removes a real package as an unprivileged user on Debian 13, connecting directly. That container is not a Dots computer: it does not test the platform proxy.

## Origin

`bin/tsapt` and its tests come from [hostkimjang/dots-tsnet](https://github.com/hostkimjang/dots-tsnet) at commit `787057b0b1e01305fd9dea824d4b5cd9fa012eaf`, by kimjang, under the MIT licence. Changes: English messages, the platform proxy as default, renamed settings, and no exit-node check or `apt` command replacement. To get exit-node downloads, a shell-wide `apt` and SSH set up for you, use dots-tsnet itself.

This project is not affiliated with OpenAI, Tailscale, dots-tsnet or dots-tailscale.
