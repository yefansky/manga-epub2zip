#!/bin/bash

for file in $(find . -name "*.epub"); do
    echo ${file}

    filename=${file%.epub}
    filename=${filename#./}
    # echo ${filename}

    tmpPath=./${filename}
    # echo ${tmpPath}

    zipPath=${tmpPath}.tempzip
    # echo ${zipPath}

    if [ ! -f "${tmpPath}" ]; then
        mkdir ${tmpPath}
    fi

    if [ ! -f "${zipPath}" ]; then
        mkdir ${zipPath}
    fi

    unzip -d ${tmpPath} ${file} >/dev/null

    path_list=$(grep "\.html" ${tmpPath}/vol.opf | grep '[0-9]' | awk -F "\"" '{print $4}')
    index=1
    for path in $path_list; do
        IMGURL=$(cat ${tmpPath}/${path} | grep src | cut -d '"' -f 2)
        #echo ${IMGURL}

        oldImgPath=${tmpPath}/${IMGURL#../}

        array=(${oldImgPath//./ })
        typeName=${array[${#array[@]} - 1]}
        newImgPath=${zipPath}/$(echo ${index} | awk '{printf("%05d",$0)}').${typeName}

        mv ${oldImgPath} ${newImgPath}

        index=$(($index + 1))
    done

    cd ${zipPath}
    
    # 去除 [Kox]
    new_filename="${filename//\[Kox\]/}"
    # 去除 .kepub.epub
    new_filename="${new_filename//\.kepub/}"

    echo $new_filename

    zip  -q ../${new_filename}.zip *
    cd ..

    rm -rf ${tmpPath}
    rm -rf ${zipPath}

    echo ${zipPath}.zip

done