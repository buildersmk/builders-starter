// Eager-load every controller under app/javascript/controllers. Add a new *_controller.js and it's
// wired automatically — reference it in HTML with data-controller="name".
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
