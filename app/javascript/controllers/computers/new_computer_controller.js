import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    save(event){
        event.preventDefault()
        const data = new FormData(this.element)

        fetch(this.element.action, {
            method: "POST",
            headers: {"Accept": "text/vnd.turbo-stream.html"},
            body: data
        }).then(response => response.text())
    }
}