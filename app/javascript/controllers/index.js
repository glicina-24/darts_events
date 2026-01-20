import { application } from "./application"

import FlashController from "./flash_controller"
import MenuController from "./menu_controller"
import ProPickerController from "./pro_picker_controller"

application.register("flash", FlashController)
application.register("menu", MenuController)
application.register("pro-picker", ProPickerController)