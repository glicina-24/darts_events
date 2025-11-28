// app/javascript/controllers/index.js
import { application } from "./application"

// 各コントローラをここで個別に登録する形にする
import AccountTypeController from "./account_type_controller"

application.register("account-type", AccountTypeController)