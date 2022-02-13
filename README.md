Provision a tutorial application which uses Node.js, React.js, and MySQL, using Terraform & Microsoft Azure.

#### Provisioning

1. Download and install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
2. Download and install [Terraform](https://www.terraform.io/downloads). Make sure to include it inside your system's [PATH](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/).
3. Clone this repository and open a terminal with the current path inside the new folder.
4. Rename `terraform.tfvars.sample` as `terraform.tfvars` and input a valid email (used to send SSL service notifications). You can choose to change the admin user and password but you must enter a valid email.
5. Run `terraform apply` and enter `yes` when prompted. This process should take 10-15 minutes. Once finished, a URL will output where you can access the application.

#### Clean up

1. Run `terraform destroy` to delete resources or you can delete the resource group manually on the Azure portal.

Backend from: [Node.js Rest APIs with Express, Sequelize & MySQL](https://github.com/bezkoder/nodejs-express-sequelize-mysql)  
Frontend from: [React.js CRUD App with React Router & Axios](https://github.com/bezkoder/react-crud-web-api)
