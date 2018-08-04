(function(){
  window.onload = () => {
    var js = document.createElement("script")
    js.src = "/ws/client.js"
    js.onload = () => {
      document.client = new Faye.Client('http://localhost:8080/ws')

      document.client.subscribe('/test', (m) => {
        console.log(m)
      })
        .then(console.log("Subscribed!"))
    }

    document.head.appendChild(js)

    document.body.addEventListener('contextmenu',
      (e => {
        e.preventDefault()
        handleRightClick(e.target)
        return false
    })
  )
  }

  function handleRightClick(elt) {
    var id = elt.dataset['frestId']
    fetch(`/${id}.html`, {
      method: 'OPTIONS'
    })
      .then((res) => {
        return res.text()
      })
      .then((txt) =>{
        elt.innerHTML = txt
      })
  }
})()
