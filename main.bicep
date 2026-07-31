##main.bicep

@Author : Goutam Sahoo

targetScope = 'subscription'

@description('Version tag applied to all resource names.')
param version string = 'v2'

@description('Enforcement mode for the initiative assignment.')
@allowed(['Default', 'DoNotEnforce'])
param enforcementMode string = 'Default'

// ── INITIATIVE-LEVEL PARAMETERS (Configurable via JSON) ──
@description('Registry for all initiative-level shared parameters.')
param initiativeParameters object = {
  sharedDeniedModels: {
    type: 'Array'
    defaultValue: ['grok', 'deepseek']
  }
  sharedEndpointEffect: {
    type: 'String'
    defaultValue: 'Deny'
  }
}

// ── POLICY LEDGER (The Scalable Registry) ──
var policyLedger = [
  {
    name: 'deny-restricted-ai-models-2'
    displayName: 'Governance: Deny Restricted AI Models'
    rule: {
      if: {
        allOf: [
          { field: 'type', equals: 'Microsoft.CognitiveServices/accounts/deployments' }
          { field: 'Microsoft.CognitiveServices/accounts/deployments/model.name', in: '[parameters(\'deniedModels\')]' }
        ]
      }
      then: { effect: 'Deny' }
    }
    parameters: {
      deniedModels: { type: 'Array', defaultValue: [] }
    }
    parameterMappings: {
      deniedModels: { value: '[parameters(\'sharedDeniedModels\')]' }
    }
  }
  {
    name: 'deny-public-ai-endpoints'
    displayName: 'Governance: Deny Public AI Endpoints'
    rule: {
      if: {
        allOf: [
          { field: 'type', equals: 'Microsoft.CognitiveServices/accounts' }
          { field: 'Microsoft.CognitiveServices/accounts/publicNetworkAccess', notEquals: 'Disabled' }
        ]
      }
      then: { effect: '[parameters(\'effect\')]' }
    }
    parameters: {
      effect: { type: 'String', allowedValues: ['Deny', 'Audit'], defaultValue: 'Deny' }
    }
    parameterMappings: {
      effect: { value: '[parameters(\'sharedEndpointEffect\')]' }
    }
  }
]

module definitionDeploy './policyDefinition.bicep' = [for policy in policyLedger: {
  name: 'dep-def-${policy.name}-${version}'
  params: {
    policyName: '${policy.name}-${version}'
    policyDisplayName: '${policy.displayName} (${version})'
    policyRule: policy.rule
    policyParameters: policy.parameters
  }
}]

module initiativeDeploy './policyInitiative.bicep' = {
  name: 'dep-initiative-${version}'
  params: {
    initiativeName: 'enterprise-ai-governance-${version}'
    initiativeDisplayName: 'Enterprise AI Governance (${version})'
    initiativeParameters: initiativeParameters
    policyDefinitions: [for (policy, i) in policyLedger: {
      policyDefinitionId: definitionDeploy[i].outputs.id
      policyDefinitionReferenceId: policy.name
      parameters: policy.parameterMappings
    }]
  }
  dependsOn: [definitionDeploy]
}

module assignmentDeploy './policyAssignment.bicep' = {
  name: 'dep-assignment-${version}'
  params: {
    assignmentName: 'assign-ai-governance-${version}'
    assignmentDisplayName: 'Enterprise AI Governance Assignment (${version})'
    initiativeId: initiativeDeploy.outputs.id
    enforcementMode: enforcementMode
  }
  dependsOn: [initiativeDeploy]
}

output initiativeId string = initiativeDeploy.outputs.id
