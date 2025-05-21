resource "random_id" "cluster_suffix" {
  keepers = {
    app_name = var.app_name
  }
  byte_length = 4
}

# Store cluster name locally for destroy provisioner
locals {
  full_cluster_name = "${var.app_name}-${random_id.cluster_suffix.hex}"
}

resource "null_resource" "cluster_creation" {
  triggers = {
    cluster_name = local.full_cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      kind create cluster \
        --name ${local.full_cluster_name} \
        --config=- <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name ${self.triggers.cluster_name}"
  }
}

resource "null_resource" "cluster_ready" {
  depends_on = [null_resource.cluster_creation]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait --for=condition=Ready nodes --all --timeout=300s && \
      kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml && \
      kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOT
  }
}