import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = true
window.Stimulus = application

// Debug controller registration
const originalRegister = application.register
application.register = function(identifier, controllerConstructor) {
  console.log(`Registering controller: ${identifier}`, controllerConstructor)
  const result = originalRegister.call(this, identifier, controllerConstructor)
  console.log(`Registered controllers:`, Object.keys(this.router.controllersByIdentifier || {}))
  return result
}

export { application }