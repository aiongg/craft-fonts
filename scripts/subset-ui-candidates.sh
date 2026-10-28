#!/bin/sh
# Rebuilds fonts/ui-candidates/*/ from the upstream releases named in
# fonts/ui-candidates-manifest.txt. Downloads each release archive, checks its SHA-256 and the
# SHA-256 of the original font, then subsets the font to the interface's Latin, Greek and
# Cyrillic needs with fonttools (via uv). Re-runnable; archives already in the work directory
# are reused.
#
# usage: scripts/subset-ui-candidates.sh [work-dir]
#   work-dir  download and extraction scratch (default: ${TMPDIR:-/tmp}/ui-candidates-work)
# needs: curl, unzip, sha256sum, uvx
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
work=${1:-${TMPDIR:-/tmp}/ui-candidates-work}
mkdir -p "$work"

# Unicode ranges kept: Basic Latin, Latin-1 Supplement, Latin Extended-A and -B, Latin Extended
# Additional, Greek and Coptic, Cyrillic, General Punctuation (includes U+2007 figure space),
# Currency Symbols, Letterlike Symbols, Arrows, and the math operators interfaces use
# (partial derivative, increment, sum, minus, division slash, asterisk operator, square root,
# infinity, integral, approximately equal, not equal, identical to, less/greater or equal).
# U+00B1, U+00D7 and U+00F7 are already in Latin-1.
unicodes='U+0020-007E,U+00A0-00FF,U+0100-017F,U+0180-024F,U+1E00-1EFF,U+0370-03FF,U+0400-04FF,U+2000-206F,U+20A0-20CF,U+2100-214F,U+2190-21FF,U+2202,U+2206,U+2211,U+2212,U+2215,U+2217,U+221A,U+221E,U+222B,U+2248,U+2260,U+2261,U+2264,U+2265'

fetch() { # url archive-sha256 file
    [ -f "$work/$3" ] || curl -fL --silent --show-error -o "$work/$3" "$1"
    echo "$2  $work/$3" | sha256sum -c --quiet -
}

# subset <slug> <archive> <member path in archive> <original sha256> <output file name>
subset() {
    out="$root/fonts/ui-candidates/$1"
    mkdir -p "$out"
    orig="$work/$2.d/$3"
    echo "$4  $orig" | sha256sum -c --quiet -
    uvx --from fonttools pyftsubset "$orig" \
        --unicodes="$unicodes" \
        --layout-features='*' \
        --no-hinting \
        --name-IDs='*' --name-languages='*' --name-legacy \
        --notdef-outline \
        --output-file="$out/$5"
}

# unpack <archive-file>
unpack() { mkdir -p "$work/$1.d" && unzip -qo "$work/$1" -d "$work/$1.d"; }

# --- Inter 4.1 (rsms/inter) ---
fetch https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip \
    9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e inter-4.1.zip
unpack inter-4.1.zip
subset inter inter-4.1.zip extras/ttf/Inter-Regular.ttf \
    40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82 Inter-Regular.ttf
subset inter inter-4.1.zip extras/ttf/Inter-SemiBold.ttf \
    78a843fade9d4612a5567302fb595b56976eb5fcebf4fea5a5912d638bafcde3 Inter-SemiBold.ttf

# --- IBM Plex Sans 1.1.0 (IBM/plex) ---
fetch 'https://github.com/IBM/plex/releases/download/%40ibm%2Fplex-sans%401.1.0/ibm-plex-sans.zip' \
    fb365d910566e6d199cc2c15579a7dd9a267128e18431a394ed81f1970c69200 ibm-plex-sans-1.1.0.zip
unpack ibm-plex-sans-1.1.0.zip
subset ibm-plex-sans ibm-plex-sans-1.1.0.zip ibm-plex-sans/fonts/complete/ttf/IBMPlexSans-Regular.ttf \
    975dcda37d80f038dcd143c22e33ca2d97a0cc5a929aace1c749153b0fe1afa5 IBMPlexSans-Regular.ttf
subset ibm-plex-sans ibm-plex-sans-1.1.0.zip ibm-plex-sans/fonts/complete/ttf/IBMPlexSans-SemiBold.ttf \
    a20caf8286023a6a7a85e40b1d2a4ae9fc3e3b1f9eda8f4c542dd4986af67bb1 IBMPlexSans-SemiBold.ttf

# --- Source Sans 3 3.052R (adobe-fonts/source-sans) ---
fetch https://github.com/adobe-fonts/source-sans/releases/download/3.052R/TTF-source-sans-3.052R.zip \
    1b0dd1ec44b39f1dd98bbd153a1a3815f083639874ddee02c842bd601bad3d21 source-sans-3-3.052R.zip
unpack source-sans-3-3.052R.zip
subset source-sans-3 source-sans-3-3.052R.zip TTF/SourceSans3-Regular.ttf \
    4644c81b86ec9caaa76b634889968ed3c4f4f52f054855933acc7c2b21e53b0f SourceSans3-Regular.ttf
subset source-sans-3 source-sans-3-3.052R.zip TTF/SourceSans3-Semibold.ttf \
    a3f4f8dcf343a8f24dc61951de93f3ba1558b15cd250ba24af8a40e957081b7d SourceSans3-Semibold.ttf

# --- JetBrains Mono 2.304 (JetBrains/JetBrainsMono) ---
fetch https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip \
    6f6376c6ed2960ea8a963cd7387ec9d76e3f629125bc33d1fdcd7eb7012f7bbf jetbrains-mono-2.304.zip
unpack jetbrains-mono-2.304.zip
subset jetbrains-mono jetbrains-mono-2.304.zip fonts/ttf/JetBrainsMono-Regular.ttf \
    a0bf60ef0f83c5ed4d7a75d45838548b1f6873372dfac88f71804491898d138f JetBrainsMono-Regular.ttf
subset jetbrains-mono jetbrains-mono-2.304.zip fonts/ttf/JetBrainsMono-SemiBold.ttf \
    1b3bfa1ed5665a4ce3f9feb68d2d4e40e70bf8b4b7d9a3edd418f321b4e166a0 JetBrainsMono-SemiBold.ttf

# --- IBM Plex Mono 2.5.0 (IBM/plex) ---
fetch 'https://github.com/IBM/plex/releases/download/%40ibm%2Fplex-mono%402.5.0/ibm-plex-mono.zip' \
    6d23f01257663d8cc49a0d64c22ced630b79e0e2a0ac08a0da86e9a38bbc481c ibm-plex-mono-2.5.0.zip
unpack ibm-plex-mono-2.5.0.zip
subset ibm-plex-mono ibm-plex-mono-2.5.0.zip ibm-plex-mono/fonts/complete/ttf/IBMPlexMono-Regular.ttf \
    7c6fbddca4b700be918f5f6183d9bd4464fa427fe435f0b480d77fe2bb8c5a43 IBMPlexMono-Regular.ttf
subset ibm-plex-mono ibm-plex-mono-2.5.0.zip ibm-plex-mono/fonts/complete/ttf/IBMPlexMono-SemiBold.ttf \
    f04d7c488ddf7d1fa99f2574efc3406ea4cbe17bb1af3a1ab960f84d0c96a172 IBMPlexMono-SemiBold.ttf

# --- Source Code Pro 2.042R-u (adobe-fonts/source-code-pro) ---
fetch 'https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u/1.062R-i/1.026R-vf/TTF-source-code-pro-2.042R-u_1.062R-i.zip' \
    0c85bac90d15c040b82939aa92bc8404420fccc02e37bbcb9c93a7f21abb52c6 source-code-pro-2.042R-u.zip
unpack source-code-pro-2.042R-u.zip
subset source-code-pro source-code-pro-2.042R-u.zip TTF/SourceCodePro-Regular.ttf \
    74bd80d3e42a08517cd7e1108ba3d86f2da29ac0f3065be95e0357956ab9db37 SourceCodePro-Regular.ttf
subset source-code-pro source-code-pro-2.042R-u.zip TTF/SourceCodePro-Semibold.ttf \
    014a0fdf42504ee1faf719a96eab5f9ffdade793f1d5c5729ad4606f2aedc765 SourceCodePro-Semibold.ttf
