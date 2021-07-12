# Allows for easy injection of environment variables into the deploy config
CONFIG_PATH=$1
echo "CONFIG_PATH: ${CONFIG_PATH}"

RELEASE_CONTAINER=$2
echo "RELEASE_CONTAINER: ${RELEASE_CONTAINER}"

cat $CONFIG_PATH | \
  sed -e 's|$$POD_NAME|'"$POD_NAME"'|g' | \
  sed -e 's|$$CI_ENVIRONMENT_HOST|'"$CI_ENVIRONMENT_HOST"'|g' | \
  sed -e 's|$$CI_PROJECT_NAME_SLUG|'"$CI_PROJECT_NAME_SLUG"'|g' | \
  sed -e 's|$$CI_COMMIT_SHORT_SHA|'"$CI_COMMIT_SHORT_SHA"'|g' | \
  sed -e 's|$$CI_COMMIT_REF_SLUG|'"$CI_COMMIT_REF_SLUG"'|g' | \
  sed -e 's|$$CI_ENVIRONMENT_SLUG|'"$CI_ENVIRONMENT_SLUG"'|g' | \
  sed -e 's|$$CI_PIPELINE_ID|'"$CI_PIPELINE_ID"'|g' | \
  sed -e 's|$$CI_BUILD_ID|'"$CI_BUILD_ID"'|g' | \
  sed -e 's|$$CI_COMMIT_SHORT_SHA|'"$CI_COMMIT_SHORT_SHA"'|g' | \
  sed -e 's|$$CI_COMMIT_TAG|'"$CI_COMMIT_TAG"'|g' | \
  sed -e 's|$$RELEASE_CONTAINER|'"$RELEASE_CONTAINER"'|g'
