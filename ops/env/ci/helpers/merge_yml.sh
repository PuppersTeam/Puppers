#!/bin/sh

# XXX: Better validate these arguments long term...
override_file=$1
origin_file=$2
target=$3

#echo "target: ${target}"

if [ $target == 'items' ]; then
  merge_target='items:'
  grep_target='items:'
elif [ $target == 'env' ]; then
  merge_target='- env\: \[\]'
  grep_target='\- env\: \[\]'
else
  merge_target='invalid_merge_target'
  grep_target='invalid_grep_target'
  exit 2
fi

#echo "merge_target: ${merge_target}"
#echo "grep_target: ${grep_target}"

# XXX: Ideally come up with a way to not need this MERGE_MARKER deletion and to do it in a singular sed command (just gotta look into how that's done)

# XXX: Maybe put this in it's own helper library long term?
indent=$(
  grep "${grep_target}" "${origin_file}" |
  awk  -F'[^ ]' '{ print length($1),NR }' |
  awk '{ print $1 }'
)

#echo "indent: ${indent}"

cat $override_file | \
  sed "s|^|$(printf "%*s%s" $indent '' "$line_padding")|" \
  > "${override_file}.override"

# XXX: Ideally come up with a way to not need this MERGE_MARKER deletion and to do it in a singular sed command (just gotta look into how that's done)
updated=$(cat $origin_file | \
  sed -e 's/'"${merge_target}"'/PT_MERGE_MARKER/g' | \
  sed -e '/PT_MERGE_MARKER/ r '"${override_file}.override" | \
  sed -e '/PT_MERGE_MARKER/d')

rm -rf "${override_file}.override"

echo "$updated"
