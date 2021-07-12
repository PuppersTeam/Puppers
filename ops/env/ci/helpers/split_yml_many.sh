#!/bin/sh

yaml_folder_path=$1

yaml_group=$2

if [ ! $yaml_group ]; then
  echo "Please specify a yaml_group. Exiting."
  exit 1
fi

rm -rf "./ops/build/gen/${yaml_group}"

mkdir -p ./ops/build/gen

function do_gen_resource_file () {
  local file_path=$1
  #echo "file_path: ${file_path}"

  local gen_file=$(echo $file_path | \
    sed -e 's|.yaml|.yml|g' | \
    sed -E 's/(.*)-+/\1@/' | \
    awk -F '/' '{ print $NF }' | \
    sed -E 's/([A-Z]+)/-\1/g' | \
    sed -E 's/^-//g' | \
    awk '{ print tolower($0) }'
  )
  #echo "gen_file: ${gen_file}"

  local resource=$(echo $gen_file | awk -F '[@/]' '{ print $(NF-1) }')
  #echo "resource: ${resource}"

  local kind=$(
    grep -m 1 "^kind:" $file_path | \
    awk '{ print tolower($2) }'
  )
  #echo "kind: ${kind}"

  local file_kind=$(echo $gen_file | awk -F '@' '{ print $NF }')
  #echo "file_kind: ${file_kind}"

  path="./ops/build/gen/${yaml_group}/pt-${resource}/${file_kind}"

  if [ "${kind}" == "customresourcedefinition" ]; then
    file_kind=$(echo $file_kind | sed -e 's|-custom-resource-definition|@crd|g')
    path="./ops/build/gen/${yaml_group}/setup/crds/${resource}/${file_kind}"
  fi

  if [ "${kind}" == "namespace" ]; then
    path="./ops/build/gen/${yaml_group}/setup/namespaces/pt-${resource}/${file_kind}"
  fi

  echo $path
}

function do_gen_resource_path () {
  local gen_path=$1

  local resource_path=$(echo $gen_path | \
    sed 's:/[^/]*$::'
  )

  echo $resource_path
}

for file_path in $(find $yaml_folder_path -type f -name "*.yaml"); do
  #echo "file_path: %${file_path}"

  gen_path=$(do_gen_resource_file $file_path)
  echo "gen_path: ${gen_path}"

  resource_path=$(do_gen_resource_path $gen_path)
  #echo "resource_path: ${resource_path}"

  mkdir -p $resource_path
  cat $file_path | tee $gen_path
done

# XXX: Think on this. It works, but can it be done better?
rm -rf ./ops/build/gen/*.yaml
