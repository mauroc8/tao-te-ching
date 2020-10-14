import { Elm } from './Main.elm'

const app = Elm.Main.init({
  flags: {
    theme: localStorage.getItem('theme') || 'light',
    currentChapter: parseInt(localStorage.getItem('currentChapter')) || 0,
  },
})

app.ports.saveInLocalStorage.subscribe(value => {
  localStorage.setItem(...value)
})

window.addEventListener('touchstart', event => {
  app.ports.onTouchStart.send({
    x: event.changedTouches[0].screenX,
    y: event.changedTouches[0].screenY
  })
})

window.addEventListener('touchmove', event => {
  app.ports.onTouchMove.send({
    x: event.changedTouches[0].screenX,
    y: event.changedTouches[0].screenY
  })
})

window.addEventListener('touchend', event => {
  app.ports.onTouchEnd.send({})
})
