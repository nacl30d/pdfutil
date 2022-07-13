#! /usr/bin/env bash

function croppdf () {
    file=$1
    file_name="$(basename "$file" .pdf)"

    # set page size
    read org_width org_height <<< $(pdfinfo "$file" | grep 'Page size:' | awk '{print int($3+0.5), int($5+0.5)}')
    target_width=$(($org_width / 2))
    target_height=$org_height

    # crop left page
    echo '=> Crop left harf page'
    pdftocairo "$file" -pdf -nocrop -x 0 -y 0 -W $target_width -H $target_height -paperw $target_height -paperh $target_width "./cropped/${file_name}.left.pdf"

    # crop right page
    echo '=> Crop left harf page'
    pdftocairo "$file" -pdf -nocrop -x $target_width -y 0 -W $target_width -H $target_height -paperw $target_height -paperh $target_width "./cropped/${file_name}.right.pdf"
}


###
# main script
###

input_file=$(find "`pwd`" -name "$1")
input_file_name="$(basename "$input_file")"
work_dir=${input_file_name%.*}
output_file=${input_file_name}.split.pdf

echo '=> Create work directory'
mkdir -p "${work_dir}"
cd "${work_dir}"
mkdir -p split cropped united

# separate each page
echo '=> Split each pages'
pdfseparate "$input_file" split/%d.pdf

# crop each page
for pdf in split/*.pdf
do
    if [ -f "$pdf" ]; then
        croppdf "$pdf"
        name=$(basename "$pdf")
        number=${name%.*}
        echo '=> Combine left and right page'
        pdfunite $(ls "cropped/${number}.*" | sort -n) "united/${number}.pdf"
    else
        continue
    fi
done

# rm working files
rm -rf "${input_file_name}/split" "${input_file_name}/cropped"

exit 0
