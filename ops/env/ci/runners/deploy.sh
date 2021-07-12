#!/bin/bash

RELEASE_CONTAINER=$1
REVIEW_DIR=$2
KEY_NAME=$3
DEPLOYMENT_NAME=$4

echo "Deploying Review App..."
echo "Review App Deploy config path:"
echo "DEPLOYMENT_NAME: $DEPLOYMENT_NAME"
echo "DEPLOYMENT_CONFIG_PATH: $DEPLOYMENT_CONFIG_PATH"
echo "KUBE_NAMESPACE: $KUBE_NAMESPACE"
echo "KEY_NAME: $KEY_NAME"
echo "CI_REGISTRY: $CI_REGISTRY"
echo "CI_DEPLOY_USER: $CI_DEPLOY_USER"

# XXX: We use this to determine when a pod has successfully deployed
echo "Deploying $DEPLOYMENT_NAME to Kubernetes Namespace... $KUBE_NAMESPACE"

# Get the environment host by splitting by slashes. The value between the second and third (optional) slash is the host.
export CI_ENVIRONMENT_HOST=$(echo $CI_ENVIRONMENT_URL | tr '[:upper:]' '[:lower:]' | awk -F/ '{print $3}')

if kubectl -n $KUBE_NAMESPACE get secret ${KEY_NAME}-gitlab-keys > /dev/null 2>&1; then
  echo "Found existing secret for $KEY_NAME"
else
  # Used for pulling docker images from Gitlab's Container Registry
  echo "Creating secrets to connect to Gitlab's Container Registry..."
  if kubectl -n $KUBE_NAMESPACE create secret docker-registry \
    ${KEY_NAME}-gitlab-keys \
    --docker-server=$CI_REGISTRY \
    --docker-username=$CI_DEPLOY_USER \
    --docker-password=$CI_DEPLOY_PASSWORD \
    --docker-email="ci@pt.studio"; then
    echo "Created secret"
  else
    echo "Error creating secret"
    exit 2
  fi
fi

# Inject CI environment variables into review config for main app deployment
$BASE_DIR/ops/gen_config.sh $DEPLOYMENT_CONFIG_PATH > generated_config.yml

echo "Using the following generated app config:"
echo "================================================="
cat generated_config.yml
echo "================================================="

# Set up review app specific secrets, if any exist
if [ -f "$REVIEW_DIR/ops/setup_secrets.sh" ]; then
  echo "Setting up Review App specific secrets..."
  $REVIEW_DIR/ops/setup_secrets.sh
fi

# Remove the customized_deploy config after we've successfully uploaded it
echo "Cleaning up generated config..."
rm generated_config.yml

# Apply the Ingress config, if it exists
if [ -f "$INGRESS_CONFIG_PATH" ]; then

  echo "Applying Ingress config at: $INGRESS_CONFIG_PATH"
  $BASE_DIR/ops/apply_ingress.sh $INGRESS_CONFIG_PATH generated_ingress_config
  echo "Pod deployed and can be viewed at: $CI_ENVIRONMENT_URL"

else

  echo "Pod deployed"

fi
