---
lang: zh
layout: post
title: "利用 Method Swizzling 實作 iOS App 內切換語言功能"
excerpt: '前陣子工作時，替公司開發了一套工具，實作了 app 內切換語言的功能。'
published: true
---

前陣子工作時，替公司開發了一套工具，實作了 app 內切換語言的功能。

一般來說，在 iOS app 內語言都是跟隨手機系統語言，但是會有滿多用戶會希望手機語言與 app 內語言不同。

網路上有許多第三方套件可以做到 app 內換語言，但使用方式多半會與內建的 `NSLocalizedString` 不同，對於既有的程式碼，改動成本相對高。

這時我們可以使用 [Method Swizzling](https://nshipster.com/method-swizzling/) 這個技術來替換 `NSLocalizedString` 底層的實作方式減少改動成本。

## 多國語言字串

### `NSLocalizedString` 簡介

在 iOS app 中，可以透過 [`NSLocalizedString`](https://developer.apple.com/documentation/foundation/nslocalizedstring) 來讀取 app 內所包裝的不同語言字串。

舉例來說，如果我們有以下 `.strings` 檔：

```c
// Localizable.strings (en)
"phone_number" = "Phone Number";

// Localizable.strings (zh-Hant)
"phone_number" = "電話號碼";
```

然後我們就可以在 app 內使用以下語法對 `phoneNumberLabel` 進行文字的設定：

```swift
phoneNumberLabel.text = NSLocalizedString("phone_number", comment: "")
```

這時如果使用者手機語言為正體中文，`phoneNumberLabel` 就會顯示 `電話號碼`；同理，若手機語言為英文，則會顯示 `Phone Number`。

### iOS 系統如何選擇顯示語言

一般來說，從 iOS 系統會從 app 有支援的語言中，找出第一個在系統語言偏好列表中的語言的作為 app 內使用的語言。但如果沒有共通的語言的話則會使用**開發語言**。

#### 舉幾個例子

| 手機語言偏好 | App 支援語言 | App 內使用語言 |
|:------|:-----------|:-------------|
| 英文 | 英文（開發語言）、正體中文 | 英文 |
| 正體中文 | 英文（開發語言）、正體中文 | 正體中文 |
| 德文、正體中文、英文 | 英文（開發語言）、正體中文 | 正體中文 |
| 德文、英文、正體中文 | 英文（開發語言）、正體中文 | 英文 |
| 法文 | 英文（開發語言）、正體中文 | 英文 = *開發語言* |

<br>

程式上來說，我們可以透過 [`Bundle.preferredLocalizations`](https://developer.apple.com/documentation/foundation/bundle/1413220-preferredlocalizations) 取得系統決定的語言。

使用方法如下：

```swift
let currentLanguage = Bundle.main.preferredLocalizations.first
```


## 解構 NSLocalizedString

### Objective-C 中的 NSLocalizedString
根據 Apple 所提供的[文件](https://developer.apple.com/documentation/foundation/nslocalizedstring)，在 Objective-C 裡面，`NSLocalizedString` 是個 macro。它的實作則是呼叫 main bundle 的 [`localizedStringForKey:value:table:`](https://developer.apple.com/documentation/foundation/nsbundle/1417694-localizedstringforkey?language=objc)

> **Return Value**
>
> The result of invoking localizedStringForKey:value:table: on the main bundle passing nil as the table.

### Swift 中的 NSLocalizedString

Swift 中的 `NSLocalizedString` 則是一個 global function：

```swift
func NSLocalizedString(_ key: String,
						   tableName: String? = nil,
						   bundle: Bundle = Bundle.main,
						   value: String = "",
						   comment: String) -> String
```

同樣根據 Apple 提供的[文件](https://developer.apple.com/documentation/foundation/1418095-nslocalizedstring)，也是從 main bundle 中拿取字串。

所以我們可以透過 swizzle [`Bundle.localizedString(forKey:value:table:)`](https://developer.apple.com/documentation/foundation/bundle/1417694-localizedstring) 的實作內容來達成 swizzling `NSLocalizedString` 的效果。

## 實作 App 內切換語言

首先，我們需要實作可以讓使用者從 app 有支援的語言中選取一種的介面。

這部分就不在此贅述，這邊列出幾個實作重點：

- `Bundle.main.localizations` → 取得 app 有支援的語言代碼列表
- `Locale(identifier: langCode).localizedString(forLanguageCode: langCode)` → 將改語言以該語言的字串顯示，例如：
	- langCode = en → English
	- langCode = fr → français

在此假設使用者在上述介面中選擇偏好的語言會被存入 `preferredLanguage` 這個變數中。

如果使用者沒有手動選擇，則這個變數的值為 `Bundle.main.preferredLocalizations.first!`，也就是系統所選用的語言。

### 取得特定語言的字串

因為 `.strings` 檔案是放置在 `.lproj` 資料夾底下，所以我們可以透過指定 Bundle 拿取資源的路徑來達成取得指定語言字串的效果。

```swift
extension Bundle {
    func localizedString(forKey key: String, language languageCode: String, value: String?, table tableName: String?) -> String {
        guard
            let lprojPath = path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: lprojPath)
        else { fatalError("Language '\(languageCode)' is not supported") }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
```

這樣一來，我們就可以透過以下方式取得 `preferredLanguage` 所指定語言版本的字串：

```swift
preferredLanguage = "zh-Hant"
Bundle.main.localizedString(forKey: "phone_number", language: preferredLanguage, value: nil, table: nil) // "電話號碼"

preferredLanguage = "en"
Bundle.main.localizedString(forKey: "phone_number", language: preferredLanguage, value: nil, table: nil) // "Phone Number"
```

### 定義新的 `NSLocalizedString`

先前提到 `NSLocalizedString` 其實就是呼叫 `Bundle.main.localizedString(forKey:value:table:)` 的結果。

搭配前一小節內容，可以先定義出會參考 `preferredLanguage` 的 `localizedString(forKey:value:table:)` 版本。

```swift
extension Bundle {
    @objc private func modifiedLocalizedString(forKey key: String, value: String?, table: String?) -> String {
        return localizedString(forKey: key, language: preferredLanguage, value: value, table: table)
    }
}
```

接下來我們只需要將 `modifiedLocalizedString(forKey:value:table:)` 以及 `localizedString(forKey:value:table:)` 利用 method swizzling 調換其中的實作內容，就可以使 `NSLocalizedString` 根據 `preferredLanguage` 回傳對應語言的字串了。

```swift
extension Bundle {
	class func swizzleLocalizedStringMethodImplementations() {
        let cls: AnyClass = self
        let originalMethod = class_getInstanceMethod(cls, #selector(localizedString(forKey:value:table:)))!
        let modifiedMethod = class_getInstanceMethod(cls, #selector(modifiedLocalizedString(forKey:value:table:)))!
        method_exchangeImplementations(originalMethod, modifiedMethod)
    }
}
```

### 還沒結束！

一旦呼叫了 `swizzleLocalizedStringMethodImplementations`， 原本`localizedString(forKey:value:table:)` 的實作內容會與 `modifiedLocalizedString(forKey:value:table:)` 的內容互換。

所以必須修改 `localizedString(forKey:language:value:table)` 讓其呼叫原始的 `localizedString(forKey:value:table:)`，否則**會有無窮迴圈產生**。

```diff
  func localizedString(forKey key: String, language languageCode: String, value: String?, table tableName: String?) -> String {
      guard
          let lprojPath = path(forResource: languageCode, ofType: "lproj"),
          let bundle = Bundle(path: lprojPath)
      else { fatalError("Language '\(languageCode)' is not supported") }

-     return bundle.localizedString(forKey: key, value: value, table: tableName)
+     return modifiedLocalizedString(forKey: key, value: value, table: tableName)
  }
```

這樣一來才算是真正完成。

完成後程式碼如下：

```swift
extension Bundle {
    class func swizzleLocalizedStringMethodImplementations() {
        let cls: AnyClass = self
        let originalMethod = class_getInstanceMethod(cls, #selector(localizedString(forKey:value:table:)))!
        let modifiedMethod = class_getInstanceMethod(cls, #selector(modifiedLocalizedString(forKey:value:table:)))!
        method_exchangeImplementations(originalMethod, modifiedMethod)
    }

    @objc private func modifiedLocalizedString(forKey key: String, value: String?, table: String?) -> String {
        return localizedString(forKey: key, language: preferredLanguage, value: value, table: table)
    }

    private func localizedString(forKey key: String, language languageCode: String, value: String?, table tableName: String?) -> String {
        guard
            let lprojPath = path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: lprojPath)
            else { fatalError("Language '\(languageCode)' is not supported") }

        return bundle.modifiedLocalizedString(forKey: key, value: value, table: tableName)
    }
}
```

### 呼叫 `swizzleLocalizedStringMethodImplementations`

最後，在 App 一啓動時套用剛才所寫的實作置換，就大功告成。

```swift
// AppDelegate.swift
class AppDelegate: UIResponder, UIApplicationDelegate {
	...
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		Bundle.swizzleLocalizedStringMethodImplementations()
		...
		return true
    }
	...
}
```

# 小結

除非不得已，在開發中不建議使用 method swizzling 或是其他 Objective-C runtime 相關功能。
這些工具自然好用，但是會減少程式碼的易讀性，同時也失去了透過編譯器檢查型別等等好處。
仔細想想，通常都可以有更好解決方式。

至於我會選用這樣的方式實作，主要是希望 app 其他部分的程式碼可以維持與系統預設語法相同，這樣未來比較不會因為忘了要用特殊語法而產生 bug — 也算是利大於弊啦。


# 延伸閱讀

[Method Swizzling -  NSHipster](https://nshipster.com/method-swizzling/) （個人認為）必讀的 Method Swizzling 教學

[iOS 界的毒瘤：Method Swizzle](https://juejin.im/entry/5a1fceddf265da43310d9985) 對於 Method Swizzling 很詳細的一篇分析（簡體中文文章）
