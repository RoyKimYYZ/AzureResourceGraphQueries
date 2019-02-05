# https://docs.microsoft.com/en-us/azure/governance/resource-graph/concepts/query-language
Search-AzureRmGraph -Query "" | format-table -AutoSize
Search-AzureRmGraph -Query "" | Out-GridView
 
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | limit 1 " | ConvertTo-Json | clip.exe | notepad
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Web/sites' | limit 1" | ConvertTo-Json 

# Provider Namespace and Resource Types for use in the type property
Get-AzureRmResourceProvider -ListAvailable | Where-Object { $_.RegistrationState -eq 'Registered' } | Select-Object ProviderNamespace -ExpandProperty ResourceTypes
(Get-AzureRmResourceProvider -ListAvailable | Where-Object { $_.RegistrationState -eq 'Registered' }) | Select-Object ProviderNamespace, ResourceTypes | Export-Csv -LiteralPath "C:\users\user1\documents\arm-providernamespace-resourcetypes.csv"
(Get-AzureRmResourceProvider -ListAvailable | Where-Object { $_.RegistrationState -eq 'Registered' }).ResourceTypes.ResourceTypeName
(Get-AzureRmResourceProvider -ListAvailable | Where-Object { $_.RegistrationState -eq 'Registered' })
((Get-AzureRmResourceProvider -ProviderNamespace $providerNamespace).ResourceTypes | Where-Object ResourceTypeName -eq batchAccounts).ApiVersions

# VMs
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' |
 project name, type, location, subscriptionId, resourceGroup" | ft
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' and properties.PowerState=='Running'"
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by resourceGroup, subscriptionId"
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by resourceGroup, location, subscriptionId"
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' and properties.provisioningState=='Succeeded' | summarize count() by resourceGroup, location, subscriptionId"

Search-AzureRmGraph -Query "where type =~ 'Microsoft.KeyVault/vaults' | limit 10 " | Out-GridView
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | extend os = properties.storageProfile.osDisk.osType | summarize count() by tostring(os), resourceGroup"

Search-AzureRmGraph -Query "where tags =~ 'devtestlabs'" | Out-GridView
Search-AzureRmGraph -Query "where resourceGroup =~ 'enterprise'" | Out-GridView

#web sites
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Web/*' |
project name, type, location, subscriptionId, resourceGroup"
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Web/sites' and properties.state=='Stopped' "
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Web/sites' and properties.state=='Stopped' |
project name, type, location, subscriptionId, resourceGroup"

## Aggregation ##
# Count by resource group, subscription
Search-AzureRmGraph -Query "summarize Num_ResourceGroups = count(resourceGroup) by subscriptionId" | Out-GridView
# Count by resource type, resource group, subscription
Search-AzureRmGraph -Query "summarize Num_ResourceTypes = count() by type, resourceGroup, subscriptionId " | Out-GridView
# Count by resource type, resource group order by resource type count descending
Search-AzureRmGraph -Query "summarize resource_type_count = count() by resourceGroup, type | order by resource_type_count" | Out-GridView
# Count by resource type, subscription order by type name ascending
Search-AzureRmGraph -Query "summarize count() by type, subscriptionId | order by type asc" | Out-GridView
Search-AzureRmGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by resourceGroup, location, subscriptionId"

# List resource name, type, group in order of resource group name descending
Search-AzureRmGraph -Query "project name, type, resourceGroup | order by resourceGroup" | Out-GridView
Search-AzureRmGraph -Query "project resourceGroup, name, type | order by resourceGroup, name" | Out-GridView
# not really aggregating, but a fancy way of list resource names by resourceGroup
Search-AzureRmGraph -Query "summarize count() by name, type, resourceGroup | order by resourceGroup" | Out-GridView

Search-AzureRmGraph -Query "where type=='microsoft.keyvault/vaults' | summarize count(type) by subscriptionId, type | order by type, subscriptionId" | Out-GridView
Search-AzureRmGraph -Query "where type=='microsoft.compute/virtualmachines' | summarize count(type) by subscriptionId, type | order by type, subscriptionId" | Out-GridView
Search-AzureRmGraph -Query "where type=='microsoft.web/sites' | summarize count(type) by subscriptionId, type | order by type, subscriptionId" | Out-GridView

Search-AzureRmGraph -Query "distinct type"

Search-AzureRmGraph -Query "" | Out-GridView | Out-File -LiteralPath "C:\users\roy\downloads\azure-graph.csv"
Search-AzureRmGraph -Query "summarize count(id) by resourceGroup, type, name"
Search-AzureRmGraph -Query "project subscriptionId, resourceGroup, type, name, location, tags | order by subscriptionId, resourceGroup"  | Export-Csv -LiteralPath "C:\users\roy\downloads\azure-graph2.csv" -NoTypeInformation

# Export
Search-AzureRmGraph -Query "" | Export-Csv -LiteralPath "C:\users\roy\downloads\azure-graph.csv"
Search-AzureRmGraph -Query "" | Export-FormatData 
Search-AzureRmGraph -Query "" | Format-Table -AutoSize -GroupBy Location | Export-Csv -LiteralPath "C:\users\roy\downloads\azure-graph-bylocation.csv"
# requires Install-Script -Name Join
Search-AzureRmGraph -Query "" | InnerJoin (Get-AzureRmSubscription) subscriptionId on Id 

# tag
Search-AzureRmGraph -Query "project tags | summarize buildschema(tags)"
Search-AzureRmGraph -Query "project name, tags" | Out-GridView 
Search-AzureRmGraph -Query "where tags.displayName=='FE' | project name, type, resourceGroup, tags" | Out-GridView 
Search-AzureRmGraph -Query "where tags.Environment=='Development' | project name, type, resourceGroup, tags" | Out-GridView 
Search-AzureRmGraph -Query "project resourceGroup, name, tags"
