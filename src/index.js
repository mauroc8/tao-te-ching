import { Elm } from './Main.elm'

const app = Elm.Main.init({
  flags: {
    theme: localStorage.getItem('theme') || 'light',
    currentChapter: parseInt(localStorage.getItem('currentChapter')) || 0,
  },
})

app.ports.saveTheme.subscribe((theme) => {
  localStorage.setItem('theme', theme)
})

app.ports.saveCurrentChapter.subscribe((currentChapter) => {
  localStorage.setItem('currentChapter', String(currentChapter))
})
