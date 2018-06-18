(function(){
  window.onload = () => {
    var js = document.createElement("script")
    js.src = "/client.js"
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
        elt.replaceWith(txt)
      })
  }
})()
