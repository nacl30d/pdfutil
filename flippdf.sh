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

        if [ "$1" = '-y' ]; then
            readonly yes=true;
            shift 1;
        else
            readonly yes=false;
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
        readonly output="output.pdf"

        : "Check working files" && {
            if [ -d $wd ]; then
                e_warn "$wd is already exists.";
                if "$yes"; then
                    e_info "Remove $wd"
                    rm -rf "$wd"
                else
                    read -p "Overwrite it? [Y/n] " yn
                    if [[ $yn =~ [nN] ]]; then
                        exit 1;
                    else
                        rm -rf "$wd"
                    fi
                fi
            fi
            if [ -f $output ]; then
                e_warn "$output is already exists.";
                if "$yes"; then
                    e_info "Overwrite $output"
                    rm -rf "$output"
                else
                    read -p "Overwrite it? [Y/n] " yn
                    if [[ $yn =~ [nN] ]]; then
                        exit 1;
                    else
                        rm -rf "$output"
                    fi
                fi
            fi
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
