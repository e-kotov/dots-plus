# dots-plus

Install `apt` packages on a ChatGPT Dots cloud computer without root.

A Dots computer has no `sudo` and its system folders are read-only, so normal `apt` fails. `tsapt` runs the real `apt-get` with its own configuration and unpacks packages into a folder you own.

It downloads through the Dots platform proxy (`browser-proxy:8889`). It needs no Tailscale, no exit node and no SSH, and it does not touch your shell profile.

## Install

Run this in the dot's terminal, or send it to your dot in chat. It also updates an existing install:

```bash
curl -fsSL --proxy http://browser-proxy:8889 https://raw.githubusercontent.com/e-kotov/dots-plus/v0.2.3/get.sh | bash
```

Then check it in a new shell:

```bash
apt update && apt install -y iperf3 && iperf3 --version
```

It works if the last command prints a version.

The install puts everything under `/workspace/shared`, because a Dots cleanup on 2026-10-23 was reported to delete other top-level `/workspace` folders. It also adds two lines to `~/.bashrc` and `~/.profile` so that plain `apt` works. To remove those lines:

```bash
bash /workspace/shared/dots-plus/install.sh --no-shell
```

## Use

Use the normal names in any new shell:

```bash
apt update
apt install -y <package>
<program> [arguments]
apt list                        # what tsapt installed
apt remove <package>
```

Without the shell lines, call `/workspace/shared/.tsapt/bin/tsapt` in place of `apt`, and put `/workspace/shared/.tsapt/bin/tsrun` in front of a program.

The shell setup changes `PATH` only. The library path is set for each installed program as it starts, so installed libraries cannot affect anything else. A system program keeps priority over an installed one with the same name.

Plain `apt` works only in a shell that reads those startup files. A tool that starts commands another way needs the full paths. `sudo apt` does not work, because the computer has no `sudo`.

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

## Use at your own risk

This is an unofficial project, provided as is with no warranty. The authors are not responsible for anything that results from using it, including data loss, security problems or action taken against your account. You are responsible for following the terms of OpenAI and of any other service you use.

## Optional: dots-tailscale

`install-dots-tailscale.sh` installs [dots-tailscale](https://github.com/abruption/dots-tailscale) `v0.8.0`, unmodified, and refuses to continue if the code does not match the pinned commit. It places everything under `/workspace/shared` and does not sign in. `tsapt` does not use it. **It tunnels Tailscale through the Dots network proxy, which may conflict with OpenAI's terms, and a dot may refuse to run it. Check this yourself before using it.** For signing in and for the SSH access dots-tailscale provides, read its [usage guide](https://github.com/abruption/dots-tailscale/blob/main/docs/usage.md).

## Testing

CI installs and removes a real package as an unprivileged user on Debian 13, connecting directly. That container is not a Dots computer: it does not test the platform proxy.

## Credits

dots-plus builds on the work of two projects:

- **[dots-tsnet](https://github.com/hostkimjang/dots-tsnet)** by kimjang (MIT). `bin/tsapt` and `tests/test_tsapt.py` come from commit `787057b0b1e01305fd9dea824d4b5cd9fa012eaf`, including the method of running `apt` without root. dots-plus changes the messages to English, makes the platform proxy the default, renames the settings, removes the exit-node check and sets the library path per program. The dots-tsnet copyright notice is kept in [LICENSE](LICENSE). For exit-node downloads and SSH set up for you, use dots-tsnet itself.
- **[dots-tailscale](https://github.com/abruption/dots-tailscale)** by abruption and contributors (MIT). `install-dots-tailscale.sh` downloads it unmodified. No dots-tailscale code is included here.

This project is not affiliated with OpenAI, Tailscale, dots-tsnet or dots-tailscale.
