policyAssignment.bicep
@Author : Goutam Sahoo
targetScope = 'subscription'

param assignmentName string
param assignmentDisplayName string
param initiativeId string

@allowed(['Default', 'DoNotEnforce'])
param enforcementMode string = 'Default'

resource assignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: assignmentName
  properties: {
    displayName: assignmentDisplayName
    policyDefinitionId: initiativeId
    enforcementMode: enforcementMode
  }
}

output id string = assignment.id
