import { Application } from "@hotwired/stimulus"

import FlashController from "./flash_controller"

window.Stimulus = Application.start()

Stimulus.register("flash", FlashController)