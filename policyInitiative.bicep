policyInitiative.bicep
@Author :Goutam Sahoo
targetScope = 'subscription'

param initiativeName string
param initiativeDisplayName string
param initiativeParameters object
param policyDefinitions array

resource initiative 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    policyType: 'Custom'
    parameters: initiativeParameters
    policyDefinitions: policyDefinitions
  }
}

output id string = initiative.id
