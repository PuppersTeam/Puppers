#!/bin/sh

yaml_file=$1

yaml_group=$2

if [ ! $yaml_group ]; then
  echo "Please specify a yaml_group. Exiting."
  exit 1
fi

rm -rf "./ops/build/gen/${yaml_group}"

mkdir -p ./ops/build/gen

cat $yaml_file | awk '
/^apiVersion:/ {
  close(file)
  file="./ops/build/gen/" NR ".yaml"
}

/^# Source:/ {
  print "Skipping line: " $0
  next;
}

file != "" && !/^--/{
  print > (file)
}
'

for file_path in $(find ./ops/build/gen -type f -name "*.yaml"); do
  name=$(
    grep -m 1 "^  name:" $file_path | \
    awk '{ print tolower($2) }' | \
    sed 's|:|#|g'
  )

  kind=$(
    grep -m 1 "^kind:" $file_path | \
    awk '{ print $2 }' | \
    sed -E 's/([A-Z]+)/-\1/g' | \
    sed -E 's/^-//g' | \
    awk '{ print tolower($0) }'
  )

  echo "----------------------------------------------"
  echo "name: ${name}"
  echo "kind: ${kind}"

  path="./ops/build/gen/${yaml_group}/pt-${name}"

  if [ "${kind}" == "custom-resource-definition" ]; then
    kind="${name}@crd"
    path="./ops/build/gen/${yaml_group}/setup/crds"
  fi

  if [ "${kind}" == "namespace" ]; then
    path="./ops/build/gen/${yaml_group}/setup/namespaces/pt-${name}"
  fi

  mkdir -p "${path}"

  mv $file_path "${path}/${kind}.yml"
done
