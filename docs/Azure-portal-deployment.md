<div id="top"></div>

# Azure SDK provisioning 

## Deployment using Azure Portal

## Setup Instructions
<p align="left"><a href="#top">Back to Top</a></p>

This document outlines the steps to configure and deploy Python Azure functions using portal 


* [Prerequisite](#prerequisite)
* [Create supporting Azure resources for your function](#create-supporting-azure-resources-for-your-function)
    - [Create Resource group](#create-resource-group)
    - [Create Storage account](#create-storage-account)
    - [Create a Container](#create-a-container)
        - [Upload config files to the Container](#upload-config-files-to-the-container)
    - [Create Function app](#create-function-app) 
* [Create an Azure Cosmos Core (SQL) API serverless account, database and container](#create-an-azure-cosmos-core-sql-api-serverless-account-database-and-container)
    - [Create cosmos DB account](#create-cosmos-db-account)
    - [Create an SQL database and container](#create-an-sql-database-and-container)
* [Update Function App configuration settings](#update-function-app-configuration-settings)
* [Deployment](#deployment)
## Prerequisite
<p align="left"><a href="#top">Back to Top</a></p>

1. Follow this document to create the configuration files customised for your stream, 
[Config files Setup Reference](config-setup.md)

## Create supporting Azure resources for your function

### Create Resource group
<p align="left"><a href="#top">Back to Top</a></p>

Create **Resource group** (say, `myResourceGroup`) if it doesn't exists

1. Sign in to the [Azure portal](https://portal.azure.com/).
2. Select **Resource groups**
3. Select **Create**.
4. Enter the following values:
    1. _Subscription_: Select your Azure subscription.
    2. _Resource group_: Enter a new resource group name.
    3. _Region_: Select an Azure location, such as Central US.
5. Select Review + Create
6. Select **Create**. It takes a few seconds to create a resource group.
7. Select Refresh from the top menu to refresh the resource group list, and then select the newly created resource group to open it. Or select Notification(the bell icon) from the top, and then select Go to resource group to open the newly created resource group

### Create Storage account 
<p align="left"><a href="#top">Back to Top</a></p>

Create **Storage account** (say, `datastreamsdkaccount`) in the created resource group for metadata container.

1.  From the [Azure portal](https://portal.azure.com/) menu or the **Home** page, select **Storage accounts** to display a list of your storage accounts.
2. On the **Storage accounts** page, select **Create**.
3. On the Basics tab, provide the essential information for your storage account. After you complete the Basics tab, you can choose to further customize your new storage account by setting options on the other tabs, or you can select **Review + create** to accept the default options and proceed to validate and create the account. The following table describes the fields on the Basics tab. Rest settings can be configured based on your requirements.

    <table>
    <thead>
    <tr align="left" valign="top">
        <th> Section </th>
        <th> Field </th>
        <th> Suggested value </th>
    </tr>
    </thead>
    <tbody>
    <tr align="left" valign="top">
        <td> Project details </td>
        <td> Subscription </td>
        <td> Select the subscription for the new storage account. </td>
    </tr>
    <tr align="left" valign="top">
        <td> Project details </td>
        <td> Resource group	</td>
        <td> Create a new resource group for this storage account, or select an existing one. For more information, see <a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview#resource-groups"> Resource groups </a>. </td>
    </tr>
    <tr align="left" valign="top">
        <td> Instance details </td>
        <td> Storage account name </td>
        <td> Choose a unique name for your storage account (e.g. <code>datastreamsdkaccount</code>). <br> Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only. </td>
    </tr>
    <tr align="left" valign="top">
        <td> Instance details </td>
        <td> Region </td>
        <td> Select the appropriate region for your storage account.</td>
    </tr>
    <tr align="left" valign="top">
        <td> Instance details </td>
        <td> Performance </td>
        <td> Select your desired Performance. <br> <b>Preferred:</b> <code><i><b>Standard</b>: Recommended for most scenarios (general-purpose v2 account)</i>. </code></td>
    </tr>
    <tr align="left" valign="top">
        <td> Instance details </td>
        <td> Redundancy	</td>
        <td> Select your desired redundancy configuration.<br> <b>Preferred</b>: <code><i>Locally-redundant storage(LRS)</i> </code></td>
    </tr>
    <tbody>
    </table>

### Create a Container
<p align="left"><a href="#top">Back to Top</a></p>

Create **Container** (say, `metadata`) in the created Storage account.

1. From the [Azure portal](https://portal.azure.com/) menu or the **Home** page, Navigate to your new storage account in the Azure portal.
2. In the left menu for the storage account, scroll to the Data storage section, then select Containers.
3. Select the **Add container** button.
4. Type a name for your new container. Example: `metadata`
    - The container name must be lowercase, must start with a letter or number, and can include only letters, numbers, and the dash (-) character. 
    - For more information about container and blob names, see [Naming and referencing containers, blobs, and metadata](https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata).
5. Keep the default level of Private (no anonymous access) access to the container.
6. Select **Create** to create the container.

#### Upload config files to the Container

1. In the [Azure portal](https://portal.azure.com/), navigate to the container you created in the previous section.
2. Select the created **container** (say `metadata`) to show a list of blobs it contains. 
3. Select the Upload button to open the upload blade and browse your local file system to find all the config files in the git repo to upload as a block blob.
4. Select all the config files in the `configs/` directory inside the git repo to upload.
5. Select the Upload button to upload all the config files .

### Create Function app
<p align="left"><a href="#top">Back to Top</a></p>

Create **Function App** (e.g., `datastreamSdkFunctionApp`) in the created Resource group and Storage account using the following steps, 

1. From the [Azure portal](https://portal.azure.com/) menu or the **Home** page, select **Create a resource**.
2. In the New page, select **Compute > Function** App.
3. Select **Consumption** hosting plan.
4. Create the **function app** using the **settings** as specified in the following table

    <table>
    <thead>
    <tr align="left" valign="top">
        <th>Setting</th>	
        <th>Suggested value	</th>
        <th>Description</th>
    </tr>
    </thead>
    <tbody>
    <tr align="left" valign="top">
        <th>Subscription </th>
        <td>Your subscription </td>
        <td>The subscription under which this new function app is created.</td>
    </tr>
    <tr align="left" valign="top">
        <th> Resource Group </th>
        <td> Your resource group </td>
        <td>
            Resource group that is created in earlier steps
        </td>
    </tr>
    <tr align="left" valign="top">
        <th> Function App name </th>
        <td> <code>datastreamSdkFunctionApp</code> </td>
        <td> Name that identifies your new function app. Valid charactersare a-z (case insensitive), 0-9, and -.</td>
        </tr>
    <tr align="left" valign="top">
        <th> Runtime stack </th>
        <td> <i>Python</i> </td>
        <td> Choose a runtime that supports the function programming language.</td>
    </tr>
    <tr align="left" valign="top">
        <th> Version </th>
        <td> <i>3.12</i></td>
        <td> Version of the installed runtime. choose 3.12 or above.</td>
    </tr>
    <tr align="left" valign="top">
        <th> Region </th>
        <td> Preferred region </td>
        <td></td>
    </tr>
    <tr align="left" valign="top">
        <th> Storage account </th>
        <td> <code> datastreamsdkaccount </code> </td>
        <td> storage account to be used by your function app. </td>
    </tr>
    <tr align="left" valign="top">
        <th> Operating system </th>
        <td> <i>Linux</i></td>
        <td></td>
    </tr>
    <tr align="left" valign="top">
        <th> Enable public access </th>
        <td> Off</td>
        <td></td>
    </tr>
    </tbody>
    </table>                                                


## Create an Azure Cosmos DB API account, database and container

### Create cosmos DB account
<p align="left"><a href="#top">Back to Top</a></p>

Create **cosmos DB account**

1. From the Azure portal menu or the Home page, select Create a resource.
2. On the New page, search for and select Azure Cosmos DB.
3. On the Select API option page, select the Create option within the **Azure Cosmos DB for NoSQL** section.
4. In the Create Azure Cosmos DB Account page, enter the following basic settings for the new Azure Cosmos account. Rest settings can be configured based on your requirements.

    <table>
    <thead>
    <tr align="left" valign="top">
        <th>Setting</th>	
        <th>Suggested value</th>
    </tr>
    </thead>
    <tbody>
    <tr align="left" valign="top">
        <th>Subscription </th>
        <td>Select the Azure subscription that you want to use for this Azure Cosmos account.</td>
    </tr>
    <tr align="left" valign="top">
        <th>Resource Group </th>
        <td>Select the resource group created in the first step.</td>
    </tr>
    <tr align="left" valign="top">
        <th>Account Name </th>
        <td>Enter a unique name to identify your Azure Cosmos account. <br> The name can only contain lowercase letters, numbers, and the hyphen (-) character. It must be between 3-44 characters in length. <br> Say, <code>datastreamsdk-cosmos-account</code></td>
    </tr>
    <tr align="left" valign="top">
        <th>Location </th>
        <td>The region closest to your users</td>
    </tr>
    <tr align="left" valign="top">
        <th>Capacity mode </th>
        <td><b>Preferred:</b> <code>Serverless </code></td>
    </tr>
    </tbody>
    </table>

5. Select **Review + create**.
6. Review the account settings, and then select Create. It takes a few minutes to create the account. Wait for the portal page to display Your deployment is complete.

### Create an SQL database and containers
<p align="left"><a href="#top">Back to Top</a></p>

Create an **SQL database** under an Azure Cosmos DB account. Say,  `datastreamSdkDb`. And Create an **SQL container** under an Azure Cosmos DB SQL database. Say, `cosmosContainerName`.

1. Select Data Explorer from the left navigation on your Azure Cosmos DB account page, and then select **New Container**.

2. In the Add container pane, enter the settings for the new container.

    <table>
    <thead>
    <tr align="left" valign="top">
        <th>Setting</th>	
        <th>Suggested value</th>
    </tr>
    </thead>
    <tbody>
    <tr align="left" valign="top">
        <th>Database id </th>
        <td><code>datastreamSdkDb</code></td>
    </tr>
    <tr align="left" valign="top">
        <th>Container id </th>
        <td><code>mainContainer</code></td>
    </tr>
    <tr align="left" valign="top">
        <th>Partition key </th>
        <td><code>/id</code> </td>
    </tr>
    </tbody>
    </table>

3. Select OK. The Data Explorer displays the new database and the container that you created.

4. Add a second container for the database. Select the database you created in the previous step, and then select **New Container**.

    <table>
    <thead>
    <tr align="left" valign="top">
        <th>Setting</th>	
        <th>Suggested value</th>
    </tr>
    </thead>
    <tbody>
     <tr align="left" valign="top">
        <th>Container id </th>
        <td><code>uniqueVisitorContainer</code></td>
    </tr>
    <tr align="left" valign="top">
        <th>Partition key </th>
        <td><code>/partition_key</code></td>
    </tr>
    </tbody>
    </table>

5. Select OK. The Data Explorer displays the database and the container that you created.

## Update Function App configuration settings
<p align="left"><a href="#top">Back to Top</a></p>

Bind Storage account and cosmos db account in the created Azure function

1. Populate connection details for the function app:
    - Navigate to the created **Function App**
    - Go to **Settings > Environment variables**
    - Under **App settings**, add/edit the following variable **Names**

        <table>
        <thead>
        <tr align="left" valign="top">
            <th> Name </th>
            <th> Suggested Value </th>
            <th> Description </th>
        </tr>
        </thead>
        <tbody>
        <tr align="left" valign="top">
            <th> AzureMetadataStorageConnectionString </th>
            <td> <code>DefaultEndpointsProtocol=https;AccountName=...</code> </td>
            <td> Connection String used to connect to Storage account containing config files</td>
        </tr>
        <tr align="left" valign="top">
            <th> AzureMetadataStorageContainer </th>
            <td> <code>metadata</code> </td>
            <td> Container Name where the config files are copied. </td>
        </tr>
        <tr align="left" valign="top">
            <th> AzureDataStorageConnectionString </th>
            <td> <code>DefaultEndpointsProtocol=https;AccountName=... </code></td>
            <td> Connection String used to connect to Storage account that receives input data</td>
        </tr>
        <tr align="left" valign="top">
            <th> AzureDataStorageContainer </th>
            <td> <code>data</code> </td>
            <td> Container Name where the data files are stored. </td>
        </tr>
        <tr align="left" valign="top">
            <th> AzureCosmosDBConnectionString </th>
            <td> <code>DefaultEndpointsProtocol=https;AccountName=... </code> </td>
            <td> Connection String used to connect to Cosmos DB to load the data</td>
        </tr>
        <tr align="left" valign="top">
            <th>AzureCosmosDBName</th>
            <td> <code>datastreamSdkDb</code> </td>
            <td> CosmosDB name used to connect to Cosmos DB to load the data</td>
        </tr>
        <tr align="left" valign="top">
            <th>AzureCosmosDBContainerName</th>
            <td> <code>mainContainer</code> </td>
            <td> cosmosSecondContainerName This container will store tha data that will be used for calculation of unique visitor</td>
        </tr>
        </tbody>
        </table>

## Deployment 
<p align="left"><a href="#top">Back to Top</a></p>

The function app can be configured to fork the repo from a Github account.
Before configuring ensure that the `host.json` and `cloud_modules_azure/function.json` file are updated accordingly and added to your branch in the repo.

1. Navigate to Function App

    - Go to Deployment.
    - select 'Deployment Center'.
    - Login Github and provide the repository and branch

## References
<p align="left"><a href="#top">Back to Top</a></p>

- [Azure Functions documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Quickstart: Create a function in Azure with Python using Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python)
- [Develop Azure Functions by using Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=python)
- [Create a function in Azure that's triggered by Blob storage](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-storage-blob-triggered-function)
- [Create resource groups](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups)
- [Create a storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal#create-a-storage-account-1)
- [Create a container](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#create-a-container)
- [Upload a block blob](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#upload-a-block-blob)
- [Create an Azure Cosmos DB account](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account)
- [Add a database and a container](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/create-cosmosdb-resources-portal#add-a-database-and-a-container)