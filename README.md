# Tao Te Ching

[DEMO](https://mauroc8.github.io/tao-te-ching/)

Tao Te Ching is a classic Chinese book written by Lao-Tzu.

This repository contains the source code of a digital edition of the Tao Te Ching.

## Features

- Clean, focused design.
- Fade-out/fade-in transitions between chapters.
- Use arrow keys or swipe gestures to navigate the chapters.
- Toggle light/dark mode.
- Grid with all chapters.

## Translations

I've uploaded three different translations:

1. [Stephen Mitchell's translation (english)](https://mauroc8.github.io/tao-te-ching/)
2. [Addiss and Lombardo's translation (english)](https://mauroc8.github.io/tao-te-ching/addiss-lombardo/)
3. [A spanish version of Stephen Mitchell's translation](https://mauroc8.github.io/tao-te-ching/es/)

## About

Developed using [Elm](https://elm-lang.org/) and [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/).

## Development

I use [parcel](https://parceljs.org/) because it works out of the box. It's not even necessary to do `npm install`.

Just install parcel and run the development server:

    parcel src/index.html

To build:

```
parcel build src/index.html --public-url ./
```

To change the build's translation, I change the `language` definition in `Main.elm`

```elm
language = English StephenMitchell
-- or
language = English AddissAndLombardo
-- or
language = Spanish
```

> This is harder than just having a button that changes the translation on the fly (because I have to make three different builds every time I make a change), but I specifically want to avoid the design overhead of a button that most readers wont ever use. Having a clean design is one of the main goals.

