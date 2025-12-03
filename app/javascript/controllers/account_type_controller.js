import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tab",
    "title",
    "description",
    "shopOwnerStatusInput",
    "proPlayerStatusInput"
  ]

  connect() {
    // 初期はプロ or 一般、どっちでもOK
    this.setRole("general")
  }

  change(event) {
    const role = event.currentTarget.dataset.role
    this.setRole(role)
  }

  setRole(role) {
    // タブの見た目
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
    // ステータス切り替え
    switch (role) {
      case "general":
        this.shopOwnerStatusInputTarget.value = "not_applying"
        this.proPlayerStatusInputTarget.value = "not_applying"
        this.titleTarget.textContent = "一般ユーザー登録"
        this.descriptionTarget.textContent =
          "基本情報を入力して一般ユーザーアカウントを作成します"
        break
  
      case "shop_owner":
        this.shopOwnerStatusInputTarget.value = "pending"
        this.proPlayerStatusInputTarget.value = "not_applying"
        this.titleTarget.textContent = "店舗オーナー登録"
        this.descriptionTarget.textContent =
          "店舗情報の発信ができるオーナーアカウントを作成します"
        break
  
      case "pro_player":
      default:
        this.shopOwnerStatusInputTarget.value = "not_applying"
        this.proPlayerStatusInputTarget.value = "pending"
        this.titleTarget.textContent = "プロプレイヤー登録"
        this.descriptionTarget.textContent =
          "プロとしてイベント情報を発信できるアカウントを作成します"
        break
    }
  }
}