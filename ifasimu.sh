#!/bin/bash

isStore="$(git config --global credential.helper)"
echo "isStore: $isStore"
if [[ "${isStore}" == "store" ]]; then
    git config --global credential.helper store
fi

if [ $# == 0 ]; then
    if [[ -f ifasimuSave.txt ]]; then
        data=$(cat ifasimuSave.txt)
    else
        echo "No data found"
        exit 1
    fi
else
    data=$*
fi

if [[ -d .ifasimu ]]; then
    rm -rf .ifasimu
fi
mkdir .ifasimu

for i in $data; do
    git clone $i
    folder=$(echo $i | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
    echo $folder
    cd $folder
    git gc --aggressive --prune
    git bundle create --all-progress "${folder}.bundle" --all
    mv "${folder}.bundle" ../.ifasimu
    cd ..
    rm -rf $folder
done

cd .ifasimu

tar -czvf ifasimu.tar.gz *.bundle
mv ifasimu.tar.gz ../
cd ..
rm -rf .ifasimu


if [ $isStore == false ]; then
    git config --global credential.helper ""
fi