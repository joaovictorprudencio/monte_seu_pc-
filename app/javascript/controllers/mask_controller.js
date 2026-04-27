import { Controller } from "@hotwired/stimulus"
import IMask from "imask"

export default class extends Controller {
  connect() {
    this.mask = IMask(this.element, {
      mask: 'R$ num',
      blocks: {
        num: {
          mask: Number,
          thousandsSeparator: '.',
          padFractionalZeros: true,
          radix: ',',
          mapToRadix: ['.']
        }
      }
    })
  }

  disconnect() {
    this.mask?.destroy()
  }
}
