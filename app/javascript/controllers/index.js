// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load controllers using Import Map (recommended approach for Rails 7 + Import Maps)
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)