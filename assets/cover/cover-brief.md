# 封面設計與驗證說明

**DRAFT / REQUIRES AUTHOR APPROVAL**。日期：2026-10-15。僅供出版前審查，未上傳商店。

## 設計決策

採米白底、深藍大字與青綠流程線，將「從終端機開始，接到多個工作節點」轉成原創幾何構圖。圖中的框、線與圓點是抽象裝飾，不是軟體截圖，也不代表已驗證的系統架構。書名優先於裝飾與署名；不使用 Hermes／Nous 標誌、吉祥物、官方配色規範或外部影像。

封面只有書名、副標題、作者與出版者四項可見文字，與 [metadata 草案](../../notes/publishing-metadata-draft.md) 一致：

- Hermes Agent 操作手冊
- 從第一次安裝到多平台 AI 助理
- Happy eBook Authors
- Happy eBook

## 尺寸、字型與色彩

| 項目 | 設定 |
| --- | --- |
| 畫布 | 1800 × 2400 px；直式，寬高比 3:4 |
| SVG | `viewBox="0 0 1800 2400"`；文字保留可編輯，無外部影像或網路依賴 |
| PNG | RGB、無透明度、sRGB ICC；約 300 dpi 標記；預覽用途 |
| 字型 | `Noto Sans CJK TC`，依序退回 `Noto Sans TC`、`PingFang TC`、`Microsoft JhengHei`、`sans-serif` |
| 實際本機字型 | Noto Sans CJK TC Regular，Version 2.004；不把字型檔放入交付包 |
| 字級 | 英文主書名 184 px；中文主書名 340 px；副標題 78 px；作者 64 px；出版者 48 px |
| 文字／主圖 | 深藍 `#142D3B` |
| 背景 | 米白 `#F4F1E8` |
| 連接線／邊線 | 青綠 `#16756B` |
| 裝飾節點 | 橘色 `#D86944` |
| 輔助格線 | `#DADDD3` |

SVG 沒有嵌入字型，因此在缺少上述繁中字型的電腦上可能出現替代字形或版面差異。需要保留排版外觀時使用此 PNG 預覽；重新輸出前先核對中文字型。字型宣告不會下載字型。

## 平台規則與此稿對照

Google 的**電子書**封面接受 JPEG、PNG、TIFF、PDF；官方文件列最低解析度 640 px、最大寬高 7200 px，檔案須小於 2 GB。此 PNG 的尺寸與格式符合這些檔案條件；SVG 是編輯來源，不作為平台上傳格式。此處沒有套用同頁的有聲書方形封面規則。[Google Book file guidelines](https://support.google.com/books/partner/answer/3424254?hl=en)。

Kobo 建議直式、3:4、300 dpi，72 dpi 亦可；封面不超過 5 MB，JPEG 效果佳，PNG 也接受。本稿採 3:4 與 PNG，這是依建議設計，不把建議比例誤稱硬性要求。[Kobo Cover Image Tips](https://kobowritinglife.zendesk.com/hc/en-us/articles/360059385711-Cover-Image-Tips)。

格式條件通過不代表商店內容審核或實機顯示已通過。平台內預覽及最終 EPUB 封面整合尚未執行。

## 可讀性與權利

深藍文字與米白背景的計算對比值約 **12.66:1**；裝飾線不承擔文字訊息。已檢視 900 × 1200 排版預覽及 180 × 240 縮圖：主書名清楚，繁體字無缺字方框，未見裁切；縮圖中的副標題與署名字級很小，不主張所有文字都能舒適閱讀。此為視覺檢查，不代表完整無障礙認證。SVG 提供 `title`、`desc` 與 `zh-Hant`；PNG 不會自行保留語意替代文字，EPUB 製作時仍需另加封面替代文字。

圖形為本次以 SVG 基本幾何元素繪製，沒有使用下載圖片或生成式點陣圖。Noto Sans CJK TC 的本機字型內嵌授權欄及 [上游授權文件](https://github.com/notofonts/noto-cjk/blob/main/Sans/LICENSE) 均載明 SIL Open Font License 1.1；未重散布或修改字型檔。若日後嵌入／重散布字型，需另遵守授權條件。

Hermes Agent 與 Nous Research 名稱僅用於指明書籍主題，不表示合作、認證或授權。本稿未執行商標法律審查，也未取得官方背書。獨立出版聲明置於 metadata 草稿與預計的版權頁；不使用官方 logo。封面無網址，符合 Kobo 對封面與 metadata 外部連結的限制。[Kobo Metadata Guidelines](https://kobowritinglife.zendesk.com/hc/en-us/articles/360058975792-Metadata-Guidelines)。

## 實際轉圖與重現方法

已使用既有 **PyQt5 5.15.10／QtSvg 5.15.13 的 `QSvgRenderer`** 讀入 SVG，經 `QPainter` 繪入 `QImage` 後輸出 PNG；不是用另一套繪圖程式重畫近似封面。沒有安裝套件。Pillow 用於獨立解碼檢查及暫存縮圖。

在專案根目錄、具備上述工具及字型的環境執行以下命令，可重新產生 `cover-preview.png`（會覆寫此預覽）：

```bash
QT_QPA_PLATFORM=offscreen python3 - <<'PY'
from PyQt5.QtWidgets import QApplication
from PyQt5.QtSvg import QSvgRenderer
from PyQt5.QtGui import QImage, QPainter, QColorSpace
from PIL import Image
from pathlib import Path
app = QApplication([])
renderer = QSvgRenderer('assets/cover-draft/cover.svg')
assert renderer.isValid()
canvas = QImage(1800, 2400, QImage.Format_RGB32)
canvas.fill(0xffffff)
painter = QPainter(canvas)
renderer.render(painter)
painter.end()
canvas.setDotsPerMeterX(11811)
canvas.setDotsPerMeterY(11811)
canvas.setColorSpace(QColorSpace(QColorSpace.SRgb))
target = Path('assets/cover-draft/cover-preview.png')
assert canvas.save(str(target), 'PNG')
with Image.open(target) as picture:
    picture.verify()
with Image.open(target) as picture:
    picture.load()
    print(picture.format, picture.size, picture.mode, picture.info.get('dpi'))
print(target.stat().st_size)
PY
```

本次實際產物：**1800 × 2400、RGB PNG、154366 bytes**；成功完整解碼，DPI 為 `(299.9994, 299.9994)`，含 459 bytes ICC profile。此微小 DPI 小數差異來自像素／公尺整數標記。視覺審查縮圖未列入交付包。驗證紀錄見 [來源與檢查紀錄](../../research/codex-publishing-sources.md)。
