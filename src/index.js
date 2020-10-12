import { Elm } from './Main.elm'

const app = Elm.Main.init({
  flags: {
    theme: localStorage.getItem('theme') || 'light',
    currentChapter: parseInt(localStorage.getItem('currentChapter')) || 0,
  },
})

app.ports.saveInLocalStorage.subscribe(value => {
  localStorage.setItem(...value);
})
