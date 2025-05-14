#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit
THEME_SVGS="src/svgs"
THEME_INDEX="src/index.theme"
ALIASES="cursorList"

echo -ne "Checking Requirements...\\r"
if [ ! -f $THEME_INDEX ] ; then
    echo -e "\\nFAIL: '$THEME_INDEX' missing"
    exit 1
elif ! type "inkscape" > /dev/null ; then
    echo -e "\\nFAIL: inkscape must be installed"
    exit 1
elif ! type "xcursorgen" > /dev/null ; then
    echo -e "\\nFAIL: xcursorgen must be installed"
    exit 1
fi
echo -e "Checking Requirements... DONE"

# Make output directory
BUILD_DIR="build"
mkdir -p "$BUILD_DIR/3d-white/cursors"


for SIZE in 24 32 48; do
    echo -ne "\\033[0KGenerating cursors for size $SIZE...\\r"
    
    # Make output subdirectory
    OUTPUT_DIR="$BUILD_DIR/$SIZE"
    mkdir -p "$OUTPUT_DIR"

    echo -ne "\\033[0KGenerating simple cursor pixmaps...\\r"
    for CUR in src/config/*.cursor; do
        BASENAME=$CUR
        BASENAME=${BASENAME##*/}
        BASENAME=${BASENAME%.*}

        echo -ne "\\033[0KGenerating $BASENAME @ $SIZE\\r"

        inkscape -w $SIZE --export-filename "$OUTPUT_DIR/$BASENAME.png" $THEME_SVGS/"$BASENAME".svg > /dev/null
    done
    echo -e "\\033[0KGenerating simple cursor pixmaps... DONE"
    
    
    echo -ne "\\033[0KGenerating progress-cursor pixmaps...\\r"
    for i in 01 02 03 04 05 06 07 08 09 10; do
        inkscape -w $SIZE --export-filename "$OUTPUT_DIR/progress-$i.png" $THEME_SVGS/progress-$i.svg > /dev/null
    done
    echo -e "\\033[0KGenerating progress-cursor pixmaps... DONE"
    
    
    echo -ne "\\033[0KGenerating wait-cursor pixmaps...\\r"
    for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20; do
        inkscape -w $SIZE --export-filename "$OUTPUT_DIR/wait-$i.png" $THEME_SVGS/wait-$i.svg > /dev/null
    done
    echo -e "\\033[0KGenerating wait-cursor pixmaps... DONE"
done


echo -ne "Generating cursor theme...\\r"
for CUR in src/config/*.cursor; do
    BASENAME=$CUR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

    if ! ERR="$( xcursorgen -p build "$CUR" "$BUILD_DIR/3d-white/cursors/$BASENAME" 2>&1 )"; then
        echo "FAIL: $CUR $ERR"
    fi
done
echo -e "Generating cursor theme... DONE"


echo -ne "Generating shortcuts...\\r"
while read -r ALIAS ; do
    FROM=${ALIAS% *}
    TO=${ALIAS#* }
    if [ -e "$BUILD_DIR/3d-white/cursors/$FROM" ] ; then
        continue
    fi
    ln -sf "$TO" "$BUILD_DIR/3d-white/cursors/$FROM"
done < $ALIASES
echo -e "\\033[0KGenerating shortcuts... DONE"


echo -ne "Copying Theme Index...\\r"
    if ! [ -e "$BUILD_DIR/3d-white/index.theme" ] ; then
        cp $THEME_INDEX "$BUILD_DIR/3d-white/index.theme"
    fi
echo -e "\\033[0KCopying Theme Index... DONE"


echo -ne "Building Theme archive...\\r"
    (cd "$BUILD_DIR" && tar -czvf 3d-white.tar.gz 3d-white/)
echo -e "\\033[0KBuilding Theme archive... DONE"


echo "COMPLETE!"
