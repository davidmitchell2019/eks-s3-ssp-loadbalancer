############################################
#testing resource deployment to EKS
############################################
resource "kubernetes_namespace" "self-service-portal" {
  metadata {
    name = "${var.namespace_name}"
    labels {
      name = "self-service-portal"
    }
    annotations {
      name = "example-annotation"
    }
  }
}
resource "kubernetes_pod" "nginx" {
  metadata {
    name      = "${var.nginx_pod_name}"
    namespace = "${var.namespace_name}"
    labels {
      app = "nginx"
    }
  }
  spec {
    container {
      name  = "${var.nginx_pod_name}"
      image = "${var.nginx_pod_image}"
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "${var.nginx_pod_name}"
    namespace = "${var.namespace_name}"

    annotations {
      #testing deploying network load balancer
      #"service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }
  spec {
    selector {
      app = "${kubernetes_pod.nginx.metadata.0.labels.app}"
    }

    port {
      port = 80
      target_port = 8080
    }
    type = "LoadBalancer"
    /*
    ClusterIP: Service exposed on an IP address inside the cluster. This is the default behavior.    NodePort: Service exposed on each Node’s IP address at a defined port.    LoadBalancer: If deployed in the cloud, exposed externally using a cloud-specific load balancer.    ExternalName: Service is attached to the externalName field. It is mapped to a CNAME with the value.
    NodePort: Service exposed on each Node’s IP address at a defined port
    LoadBalancer: If deployed in the cloud, exposed externally using a cloud-specific load balancer.
    ExternalName: Service is attached to the externalName field. It is mapped to a CNAME with the value.
    */
  }
}

########################
#variables for testing
########################
variable "namespace_name" {
  default = "test-for-namespace-creation"
  type    = "string"
}

variable "nginx_pod_name" {
  default = "test-for-pod-creation"
  type    = "string"
}

variable "nginx_pod_image" {
  default = "nginx:latest"
  type    = "string"
}