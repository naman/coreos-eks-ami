PACKER_BINARY ?= packer
PACKER_VARIABLES := aws_region ami_name binary_bucket_name kubernetes_version kubernetes_build_date docker_version cni_version cni_plugin_version arch instance_type subnet_id vpc

aws_region ?= us-east-2

K8S_VERSION_PARTS := $(subst ., ,$(kubernetes_version))
K8S_VERSION_MINOR := $(word 1,${K8S_VERSION_PARTS}).$(word 2,${K8S_VERSION_PARTS})

ami_name ?= amazon-eks-node-$(K8S_VERSION_MINOR)-v$(shell date +'%Y%m%d')
subnet_id ?= subnet-0497f9bf57c71ec69
vpc = vpc-xxx

arch ?= x86_64
ifeq ($(arch), arm64)
instance_type ?= a1.large
else
instance_type ?= m5.large
endif

T_RED := \e[0;31m
T_GREEN := \e[0;32m
T_YELLOW := \e[0;33m
T_RESET := \e[0m

.PHONY: all
all: 1.10 1.11 1.12 1.13

.PHONY: validate
validate:
	$(PACKER_BINARY) validate $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)=$($(packerVar)),)) eks-worker-coreos.json

.PHONY: k8s
k8s: validate
	@echo "$(T_GREEN)Building AMI for version $(T_YELLOW)$(kubernetes_version)$(T_GREEN) on $(T_YELLOW)$(arch)$(T_RESET)"
	$(PACKER_BINARY) build $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)=$($(packerVar)),)) eks-worker-coreos.json

.PHONY: 1.10
1.10:
	$(MAKE) k8s kubernetes_version=1.10.13 kubernetes_build_date=2019-03-27

.PHONY: 1.11
1.11:
	$(MAKE) k8s kubernetes_version=1.11.9 kubernetes_build_date=2019-03-27

.PHONY: 1.12
1.12:
	$(MAKE) k8s kubernetes_version=1.12.7 kubernetes_build_date=2019-03-27

.PHONY: 1.13
1.13:
	$(MAKE) k8s kubernetes_version=1.13.7 kubernetes_build_date=2019-06-11
