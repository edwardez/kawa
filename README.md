![logo](resource/png/logo.png)

# Kawa [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/utatti/kawa/master/LICENSE) [![GitHub release](https://img.shields.io/github/v/release/edwardez/kawa.svg)](https://github.com/edwardez/kawa/releases)

A macOS input source switcher with user-defined shortcuts.

## Why this fork

I just want a lightweight app that does exactly one thing: switch input
sources with user-defined shortcuts. Upstream kawa is unmaintained and its
Intel-only build will stop running on future versions of macOS. I'm aware
of the many modern alternatives — but I only want an app that does this
one thing. So this fork simply keeps kawa alive: a native universal
(Apple Silicon + Intel) build, plus a fix for the long-standing macOS bug
where switching to CJKV input sources didn't actually take effect
(workaround adapted from [macism](https://github.com/laishulu/macism)).

## Demo

[![demo](https://cloud.githubusercontent.com/assets/1013641/9109734/d73505e4-3c72-11e5-9c71-49cdf4a484da.gif)](http://vimeo.com/135542587)

## Install

### Using [Homebrew](https://brew.sh/)

```shell
brew update
brew install --cask kawa
```

### Manually

The prebuilt binaries can be found in [Releases](https://github.com/utatti/kawa/releases).

Unzip `Kawa.zip` and move `Kawa.app` to `Applications`.

## Caveats

### CJKV input sources

There is a known bug in the macOS's Carbon library that switching keyboard
layouts using `TISSelectInputSource` doesn't work well with complex input
sources like [CJKV](https://en.wikipedia.org/wiki/CJK_characters): the menu
bar icon changes, but keystrokes keep going to the previous input source.

This fork works around it by briefly stealing window focus after switching,
which forces the input context to re-sync. The workaround is adapted from
[macism](https://github.com/laishulu/macism) (MIT License, © laishulu).

## Development

Dependencies ([MASShortcut](https://github.com/shpakovski/MASShortcut)) are
managed with Swift Package Manager and resolved automatically by Xcode.
Just clone and open the project:

```bash
$ git clone https://github.com/edwardez/kawa.git
```

## License

Kawa is released under the [MIT License](LICENSE).
