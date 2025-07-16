// app/javascript/controllers/pdf_uploader_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "file", "result"]

  async submit(event) {
    event.preventDefault()

    const file = this.fileTarget.files[0]

    const formData = new FormData()
    formData.append("file", file)

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content")

    try {
      const response = await fetch("/pdf_documents/create", {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken
        },
        body: formData
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.error || "Failed to generate PDF.")
      }

      const blob = await response.blob()
      const url = URL.createObjectURL(blob)

      this.resultTarget.innerHTML = `
        <a href="${url}" download="converted.pdf" title="Download PDF">
          <strong>Download PDF</strong>
        </a>
      `
    } catch (err) {
      this.resultTarget.innerHTML = `<p style="color:red;">Error: ${err.message}</p>`
    }
  }
}
