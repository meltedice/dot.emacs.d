#!/usr/bin/env python3
"""Hiragino Kaku Gothic ProN の縦メトリクスを Menlo に揃えた派生フォントを生成する。

背景:
  Emacs 30 の macOS フォント処理 (src/macfont.m, macfont_open) は
  Hiragino 系に対して lineGap(leading) の 1/4 を ascent に、lineGap 全量を
  descent に加算するため、hhea.lineGap=500 のヒラギノを Menlo(行高 16px@14px)
  と混在させると日本語を含む行だけ 20〜21px に伸びて後続行が下にズレる。
  本スクリプトはシステムのヒラギノを *上書きせず* 新 family 名で複製し、
    - hhea.ascent / OS/2.sTypoAscender : 880 -> 760  (17px 時に 12.9 -> 丸めて 13 = Menlo と一致)
    - hhea.lineGap / OS/2.sTypoLineGap : 500 -> 0
  にして ~/Library/Fonts/ へ書き出す(字形は無変更)。

注意:
  ヒラギノは macOS 同梱のライセンスフォント。生成物は本人のマシン内で使うだけに
  留め、git 管理や配布はしない(本リポジトリには本スクリプトのみ置く)。

使い方:
  pipx install fonttools            # 依存(初回のみ。pipx の隔離 venv に入る)
  ~/.local/pipx/venvs/fonttools/bin/python tools/make-hiragino-emacs-font.py
      # -> W3 と W6 を ~/Library/Fonts/HiraKakuProNEmacs-{W3,W6}.otf へ
  ~/.local/pipx/venvs/fonttools/bin/python tools/make-hiragino-emacs-font.py --out-dir DIR [W3 W6 ...]
  (素の python3 には fontTools が無いので pipx venv の python で実行する)
  生成後は Emacs を再起動するか M-x my-font-preset RET stock-modern で反映。
"""

import argparse
import os
import sys

from fontTools.ttLib import TTCollection

SRC_DIR = "/System/Library/Fonts"
SRC_FILE_FORMAT = "ヒラギノ角ゴシック {weight}.ttc"

FAMILY_OLD = "Hiragino Kaku Gothic ProN"
FAMILY_NEW = "Hiragino Kaku Gothic ProN Emacs"
PS_OLD = "HiraKakuProN-"
PS_NEW = "HiraKakuProNEmacs-"
JP_OLD = "ヒラギノ角ゴ ProN"
JP_NEW = "ヒラギノ角ゴ ProN Emacs"

ASCENDER = 760
LINEGAP = 0


def find_font(collection, ps_name):
    for font in collection.fonts:
        if font["name"].getDebugName(6) == ps_name:
            return font
    raise SystemExit(f"{ps_name} not found in collection")


def rename(s):
    return (s.replace(FAMILY_OLD, FAMILY_NEW)
             .replace(PS_OLD, PS_NEW)
             .replace(JP_OLD, JP_NEW))


def convert(weight, out_dir):
    src = os.path.join(SRC_DIR, SRC_FILE_FORMAT.format(weight=weight))
    ps_old = f"{PS_OLD}{weight}"
    font = find_font(TTCollection(src), ps_old)

    hhea = font["hhea"]
    os2 = font["OS/2"]
    before = (hhea.ascent, hhea.descent, hhea.lineGap,
              os2.sTypoAscender, os2.sTypoDescender, os2.sTypoLineGap)
    hhea.ascent = ASCENDER
    hhea.lineGap = LINEGAP
    os2.sTypoAscender = ASCENDER
    os2.sTypoLineGap = LINEGAP

    for rec in font["name"].names:
        try:
            s = rec.toUnicode()
        except UnicodeDecodeError:
            continue
        new = rename(s)
        if new != s:
            rec.string = new

    if "CFF " in font:
        cff = font["CFF "].cff
        cff.fontNames[0] = rename(cff.fontNames[0])
        top = cff.topDictIndex[0]
        for attr in ("FamilyName", "FullName"):
            if hasattr(top, attr):
                setattr(top, attr, rename(getattr(top, attr)))

    out = os.path.join(out_dir, f"{PS_NEW}{weight}.otf")
    font.save(out)

    print(f"{ps_old} -> {out}")
    print(f"  hhea/OS2 before: asc={before[0]} dsc={before[1]} gap={before[2]} "
          f"typo(asc={before[3]} dsc={before[4]} gap={before[5]})")
    print(f"  hhea/OS2 after : asc={hhea.ascent} dsc={hhea.descent} gap={hhea.lineGap} "
          f"typo(asc={os2.sTypoAscender} dsc={os2.sTypoDescender} gap={os2.sTypoLineGap})")
    for rec in font["name"].names:
        try:
            s = rec.toUnicode()
        except UnicodeDecodeError:
            continue
        if rec.nameID in (1, 2, 4, 6, 16, 17):
            print(f"  name[{rec.nameID}] plat={rec.platformID} lang={rec.langID}: {s}")
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out-dir", default=os.path.expanduser("~/Library/Fonts"))
    ap.add_argument("weights", nargs="*", default=["W3", "W6"])
    args = ap.parse_args()
    os.makedirs(args.out_dir, exist_ok=True)
    for w in args.weights:
        convert(w, args.out_dir)


if __name__ == "__main__":
    sys.exit(main())
