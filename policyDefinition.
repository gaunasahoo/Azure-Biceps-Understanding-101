#policyDefinition.bicep
#@Goutam Sahoo

targetScope = 'subscription'

param policyName string
param policyDisplayName string
param policyRule object
param policyParameters object

resource customDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    policyType: 'Custom'
    mode: 'All'
    parameters: policyParameters
    policyRule: policyRule
  }
}

output id string = customDefinition.id
