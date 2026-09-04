#!/usr/bin/env python3
"""macOS 同梱フォント(Menlo / ヒラギノ角ゴシック)の縦メトリクスだけを揃えた
派生フォントを *元ファイルを上書きせず* 新 family 名で ~/Library/Fonts/ に生成する。

背景:
  Emacs の 1 画面行の高さは「行内の各フォントの ascent の最大 + descent の最大」。
  Menlo(14px: 13/3 = 16px)と素のヒラギノ(16px: 16/4 = 20px。Emacs 30 の
  src/macfont.m が Hiragino 系に限り hhea.lineGap=500 の 1/4 を ascent に・全量を
  descent に加算する)を混在させると、日本語を含む行だけ 20px に伸びて後続行が
  ズレる。本スクリプトは字形を変えずに hhea / OS/2 の ascender・descender・
  lineGap だけを書き換え、Latin と日本語で行高を一致させる。

生成する組(プロファイル):
  emacs2 (既定, stock-modern-fixed 用) -- 全行 20px(上 16 / 下 4)。
      Menlo Emacs (Regular/Bold/Italic/BoldItalic): asc 1901->2300, dsc -483->-550 (upem 2048, 14px)
      Hiragino Kaku Gothic ProN Emacs2 (W3/W6):   asc 880->1000, dsc -120->-250, gap 500->0 (upem 1000, 16px)
      => 元の日本語行と同じ寸法(全角の上 2px・下 2px の余裕がカーソル箱の内側に入る)。
  emacs1 (比較用, stock-modern-fixed-v1 用) -- 日本語側だけ 12/2 = 14px。
      Hiragino Kaku Gothic ProN Emacs (W3/W6):    asc 880->760, gap 500->0
      => 改行を含む行は Menlo と同じ 16px になるが、折り返した日本語のみの行は
         14px になり、全角の字形上端 14px が行上端 13px より 1px はみ出る(カーソル
         箱の上が欠けて見える)。emacs2 で解消したため比較用途のみ。

注意:
  いずれも macOS 同梱のライセンスフォントの派生。生成物は本人のマシン内で使うだけに
  留め、git 管理や配布はしない(本リポジトリには本スクリプトのみ置く)。

使い方:
  pipx install fonttools            # 依存(初回のみ。pipx の隔離 venv に入る)
  ~/.local/pipx/venvs/fonttools/bin/python tools/make-emacs-fonts.py            # emacs2
  ~/.local/pipx/venvs/fonttools/bin/python tools/make-emacs-fonts.py emacs1     # 比較用
  ~/.local/pipx/venvs/fonttools/bin/python tools/make-emacs-fonts.py --out-dir DIR emacs1 emacs2
  (素の python3 には fontTools が無いので pipx venv の python で実行する)
  生成後は Emacs を再起動するか M-x my-font-preset RET stock-modern-fixed で反映。
"""

import argparse
import os
import re
import sys

from fontTools.ttLib import TTCollection

SRC_DIR = "/System/Library/Fonts"

# 名前の置換対象 nameID(family / unique / full / PostScript / typographic family)。
# 著作権表示等(0, 7, 8, ...)は触らない。
RENAME_NAME_IDS = (1, 3, 4, 6, 16, 18)

# 各ターゲット: src = TTC ファイル名, fonts = [(元 PostScript 名, 出力ファイル名)],
# renames = [(旧, 新)] を上記 nameID と CFF 名に適用, asc/dsc/gap = hhea と OS/2 typo の新値。
PROFILES = {
    "emacs2": [
        dict(src="Menlo.ttc",
             fonts=[("Menlo-Regular", "MenloEmacs-Regular.ttf"),
                    ("Menlo-Bold", "MenloEmacs-Bold.ttf"),
                    ("Menlo-Italic", "MenloEmacs-Italic.ttf"),
                    ("Menlo-BoldItalic", "MenloEmacs-BoldItalic.ttf")],
             renames=[("Menlo-", "MenloEmacs-"), ("Menlo", "Menlo Emacs")],
             asc=2300, dsc=-550, gap=0),
        dict(src="ヒラギノ角ゴシック {w}.ttc", weights=("W3", "W6"),
             fonts=[("HiraKakuProN-{w}", "HiraKakuProNEmacs2-{w}.otf")],
             renames=[("HiraKakuProN-", "HiraKakuProNEmacs2-"),
                      ("Hiragino Kaku Gothic ProN", "Hiragino Kaku Gothic ProN Emacs2"),
                      ("ヒラギノ角ゴ ProN", "ヒラギノ角ゴ ProN Emacs2")],
             asc=1000, dsc=-250, gap=0),
    ],
    "emacs1": [
        dict(src="ヒラギノ角ゴシック {w}.ttc", weights=("W3", "W6"),
             fonts=[("HiraKakuProN-{w}", "HiraKakuProNEmacs-{w}.otf")],
             renames=[("HiraKakuProN-", "HiraKakuProNEmacs-"),
                      ("Hiragino Kaku Gothic ProN", "Hiragino Kaku Gothic ProN Emacs"),
                      ("ヒラギノ角ゴ ProN", "ヒラギノ角ゴ ProN Emacs")],
             asc=760, dsc=-120, gap=0),
    ],
}


def find_font(collection, ps_name):
    for font in collection.fonts:
        if font["name"].getDebugName(6) == ps_name:
            return font
    raise SystemExit(f"{ps_name} not found in collection")


def rename(s, renames):
    """RENAMES の (旧, 新) を 1 パスで適用する(長い旧名を優先し、置換結果に再適用しない)。"""
    table = dict(renames)
    pattern = "|".join(re.escape(old) for old in sorted(table, key=len, reverse=True))
    return re.sub(pattern, lambda m: table[m.group(0)], s)


def convert(src, ps_old, out_name, renames, asc, dsc, gap, out_dir):
    font = find_font(TTCollection(os.path.join(SRC_DIR, src)), ps_old)

    hhea = font["hhea"]
    os2 = font["OS/2"]
    before = (hhea.ascent, hhea.descent, hhea.lineGap)
    hhea.ascent = asc
    hhea.descent = dsc
    hhea.lineGap = gap
    os2.sTypoAscender = asc
    os2.sTypoDescender = dsc
    os2.sTypoLineGap = gap
    os2.usWinAscent = asc
    os2.usWinDescent = -dsc

    for rec in font["name"].names:
        if rec.nameID not in RENAME_NAME_IDS:
            continue
        try:
            s = rec.toUnicode()
        except UnicodeDecodeError:
            continue
        new = rename(s, renames)
        if new != s:
            rec.string = new

    if "CFF " in font:
        cff = font["CFF "].cff
        cff.fontNames[0] = rename(cff.fontNames[0], renames)
        top = cff.topDictIndex[0]
        for attr in ("FamilyName", "FullName"):
            if hasattr(top, attr):
                setattr(top, attr, rename(getattr(top, attr), renames))

    out = os.path.join(out_dir, out_name)
    font.save(out)
    print(f"{ps_old} -> {out}")
    print(f"  hhea before: asc={before[0]} dsc={before[1]} gap={before[2]}"
          f"  after: asc={hhea.ascent} dsc={hhea.descent} gap={hhea.lineGap}")
    for rec in font["name"].names:
        if rec.nameID in (1, 4, 6, 16):
            try:
                print(f"  name[{rec.nameID}] plat={rec.platformID} lang={rec.langID}: {rec.toUnicode()}")
            except UnicodeDecodeError:
                pass


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out-dir", default=os.path.expanduser("~/Library/Fonts"))
    ap.add_argument("profiles", nargs="*", default=["emacs2"], choices=sorted(PROFILES))
    args = ap.parse_args()
    os.makedirs(args.out_dir, exist_ok=True)
    for name in args.profiles:
        for t in PROFILES[name]:
            for w in t.get("weights", (None,)):
                src = t["src"].format(w=w)
                for ps_old, out_name in t["fonts"]:
                    convert(src, ps_old.format(w=w), out_name.format(w=w), t["renames"],
                            t["asc"], t["dsc"], t["gap"], args.out_dir)


if __name__ == "__main__":
    sys.exit(main())
