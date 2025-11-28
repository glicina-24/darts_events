// app/javascript/controllers/account_type_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "title", "description", "shopOwnerInput", "proPlayerInput"]

  connect() {
    console.log("account-type controller connected") // 動作確認用
    this.setRole("pro_player")
  }

  change(event) {
    const role = event.currentTarget.dataset.role
    this.setRole(role)
  }

  setRole(role) {
    this.tabTargets.forEach((tab) => {
      const tabRole = tab.dataset.role

      if (tabRole === role) {
        tab.classList.add("bg-black", "text-white", "shadow")
        tab.classList.remove("text-slate-600")
      } else {
        tab.classList.remove("bg-black", "text-white", "shadow")
        tab.classList.add("text-slate-600")
      }
    })

    switch (role) {
      case "general":
        this.shopOwnerInputTarget.value = "false"
        this.proPlayerInputTarget.value = "false"
        this.titleTarget.textContent = "一般ユーザー登録"
        this.descriptionTarget.textContent =
          "基本情報を入力して一般ユーザーアカウントを作成します"
        break

      case "shop_owner":
        this.shopOwnerInputTarget.value = "true"
        this.proPlayerInputTarget.value = "false"
        this.titleTarget.textContent = "店舗オーナー登録"
        this.descriptionTarget.textContent =
          "店舗情報の発信ができるオーナーアカウントを作成します"
        break

      case "pro_player":
      default:
        this.shopOwnerInputTarget.value = "false"
        this.proPlayerInputTarget.value = "true"
        this.titleTarget.textContent = "プロプレイヤー登録"
        this.descriptionTarget.textContent =
          "プロとしてイベント情報を発信できるアカウントを作成します"
        break
    }
  }
}