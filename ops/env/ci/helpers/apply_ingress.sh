# Generates a custom ingress config that we can use for easy creation of dynamic network mapping across multiple docker images, as specified in the base ops directory. This way we can avoid using multiple ingresses which would incur resource costs.
INGRESS_CONFIG_PATH=$1

$BASE_DIR/ops/gen_config.sh $INGRESS_CONFIG_PATH > $2.yml

echo "Using the following generated ingress config:"
echo "=============================================="
cat $2.yml
echo "=============================================="

echo "Cleaning up generated ingress config..."
rm $2.yml
