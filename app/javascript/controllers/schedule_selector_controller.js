import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    console.log("Schedule selector connected");
  }

  change() {
    // Ждем немного чтобы все значения обновились
    setTimeout(() => {
      this.submitForm();
    }, 50);
  }

  submitForm() {
    const formData = new FormData(this.element);
    const url = this.element.action;
    
    // Создаем URL с параметрами
    const newUrl = new URL(url);
    for (const [key, value] of formData.entries()) {
      if (value) {
        newUrl.searchParams.set(key, value);
      }
    }
    
    // Делаем redirect с заменой истории
    window.location.replace(newUrl.toString());
  }
}