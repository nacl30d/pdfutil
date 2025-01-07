#!/usr/bin/env bash

set -Cue

function e_info() {
    echo "INFO: $1"
}

function e_warn() {
    echo "WARN: $1"
}

function show_usage() {
    cat <<EOS
Usage: $0 <filename>
EOS
}

function main() {
    : "Check options" && {
        if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
            show_usage;
            exit;
        fi
    }


    : "Check arguments" && {
        if [ "$#" -lt 1 ]; then
            show_usage;
            exit 1
        fi

        : "Parse arguments" && {
            readonly filename="$1"
        }
    }

    : "Configurations" && {
        readonly wd="./work"
        readonly output_basename="output"
        readonly output_ext="pdf"

        : "Check working files" && {
            readonly output=$(
                [ -f "$output_basename.$output_ext" ] \
                    && echo "$output_basename-$(find . -regex "./$output_basename\(-[0-9]+\)?\.$output_ext" | wc -l).$output_ext" \
                        || echo "$output_basename.$output_ext"
                     )
        }
    }

    : "Create working directory" && {
        mkdir -p "$wd"
    }

    : "Split file" && {
        pdfseparate "$filename" "$wd/%d.pdf"
    }

    : "Tidy files" && {
        readonly pages=$(find "$wd" -name "*.pdf" | wc -l)

        for p in $(seq 1 "$pages"); do
            # 奇数ページは使わない
            if [ $((p % 2)) -ne 0 ]; then
                rm "$wd/$p.pdf"
                continue
            fi
        done
    }

    : "Unite file" && {
        local -r pwd=$(pwd)
        cd "$wd"
        pdfunite $(ls . | \grep pdf | sort -nr) "$pwd/output.pdf"
        cd -
    }

    : "Clean up" && {
        rm -rf "$wd"
    }
}

main "$@";
