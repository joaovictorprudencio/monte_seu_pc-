import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  select(event) {
    const componentId = this.element.dataset.componentId
    const categoryName = this.element.dataset.category

   
    document.querySelectorAll(".component-card").forEach(card => {
      card.classList.remove("selected")
    })


    this.element.classList.add("selected")
    document.getElementById("selected_component_id").value = componentId

    
    const url = new URL(window.location.href)
    url.searchParams.set("selected_id", componentId)

    fetch(url, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
  }
}