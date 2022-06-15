# Configure the Microsoft Azure Provider
terraform {

  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "8e1ad5ac-e81e-4cc3-94f0-f25367326657"
  tenant_id       = "ee4ce65b-115d-4111-a16c-6baf87efbb11"
  client_id       = "4803c322-d353-4aad-a928-f56e8fd429d8"
  client_secret   = "qJZ8Q~Pz.FQiSBLGJMpgyYKXtC5jIqlOpuJkCdxg"
}

#Creating resource group

module "resource_group"{
  source   = "./modules/resource_group"
  resource_group_name = "${var.resource_group_name}"
  location = "${var.location}"
}

#Creating Virtual Network

module "virtual_network" {
  source = "./modules/virtual_network"
  location = "${var.location}"
  resource_group_name = "${module.resource_group.name}"
}

#Creating Virtual Machine

module "virtual_machine" {
  source = "./modules/virtual_machine"
  location = "${var.location}"
  vnetwork_interface_id = "${module.virtual_network.nic}"
  resource_group_name = "${module.resource_group.name}"
  blob_storage_url = "${module.storage_account.url}"
  #sshkey = "${var.sshkey}"
  #admin_username = "${var.admin_username}"
}

#Creating Storage account

module "storage_account" {
  source = "./modules/storage_account"
  location = "${var.location}"
  resource_group_id = "${module.resource_group.id}"
  resource_group_name = "${module.resource_group.name}"
  uid = "${module.unique_id.uid}"
}

#Creating Unique id

module "unique_id" {
  source = "./modules/unique_id"
  resource_group_name = "${module.resource_group.name}"
}

#Creating Keyvault

module "key_vault" {
  source = "./modules/key_vault"
  location = "${var.location}"
  resource_group_name = "${module.resource_group.name}"
  tenant_id = "${var.tenant_id}"
  object_id = "${var.object_id}"
}

#Creating Database

module "database" {
  source = "./modules/database"
  location = "${var.location}"
  resource_group_name = "${module.resource_group.name}"
  vmip = "${module.virtual_network.vmip}"
  dblogin = "${var.dblogin}"
  dbpassword = "${var.dbpassword}"
  uid = "${module.unique_id.uid}"
}

