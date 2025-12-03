import { Application } from "@hotwired/stimulus"

import FlashController from "./flash_controller"
import MenuController from "./menu_controller"

window.Stimulus = Application.start()

Stimulus.register("flash", FlashController)
Stimulus.register("menu", MenuController)