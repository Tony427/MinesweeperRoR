// Game status display controller
import { Controller } from "@hotwired/stimulus"
import { DOMHelpers } from "utils/dom_helpers"

export default class extends Controller {
  static targets = ["mines", "status", "timer"]

  connect() {
    this.startTimer()
  }

  disconnect() {
    this.stopTimer()
  }

  updateMines(count) {
    if (this.hasMinesTarget) {
      this.minesTarget.textContent = count
      this.animateUpdate(this.minesTarget.parentElement)
    }
  }

  updateStatus(status) {
    if (this.hasStatusTarget) {
      let text, className

      switch (status) {
        case 'won':
          text = 'Won! 🎉'
          className = 'badge badge-status-won'
          this.stopTimer()
          break
        case 'lost':
          text = 'Lost 💥'
          className = 'badge badge-status-lost'
          this.stopTimer()
          break
        default:
          text = 'Playing'
          className = 'badge badge-status-playing'
      }

      DOMHelpers.updateBadge(this.statusTarget, text, className)
      this.animateUpdate(this.statusTarget.parentElement)
    }
  }

  startTimer() {
    this.startTime = Date.now()
    this.timerInterval = setInterval(() => {
      this.updateTimer()
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  resetTimer() {
    this.stopTimer()
    this.startTimer()
    if (this.hasTimerTarget) {
      this.timerTarget.textContent = '0'
    }
  }

  updateTimer() {
    if (this.hasTimerTarget && this.startTime) {
      const seconds = Math.floor((Date.now() - this.startTime) / 1000)
      this.timerTarget.textContent = seconds
    }
  }

  animateUpdate(element) {
    element.classList.remove('status-update')
    // Force reflow
    element.offsetHeight
    element.classList.add('status-update')
    
    setTimeout(() => {
      element.classList.remove('status-update')
    }, 300)
  }
}