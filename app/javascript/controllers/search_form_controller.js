// app/javascript/controllers/search_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  debounceSearch(event) {
    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 500) 
  }
}