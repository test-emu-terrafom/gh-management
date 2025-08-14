#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Check for test config first, then production config
const testConfigPath = path.join(__dirname, '../config/test-resources.json');
const prodConfigPath = path.join(__dirname, '../config/gh-resources.json');

const configPath = fs.existsSync(testConfigPath) ? testConfigPath : prodConfigPath;

try {
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

  
  // Validate structure
  if (!config.teams || !Array.isArray(config.teams)) {
    throw new Error('Missing or invalid "teams" array');
  }
  
  if (!config.repositories || !Array.isArray(config.repositories)) {
    throw new Error('Missing or invalid "repositories" array');
  }
  
  // Validate teams
  const teamNames = new Set();
  config.teams.forEach(team => {
    if (typeof team !== 'string') {
      throw new Error(`Invalid team name: ${team}`);
    }
    if (teamNames.has(team)) {
      throw new Error(`Duplicate team name: ${team}`);
    }
    teamNames.add(team);
  });
  
  // Validate repositories
  const repoNames = new Set();
  config.repositories.forEach(repo => {
    if (!repo.name || typeof repo.name !== 'string') {
      throw new Error('Repository missing required "name" field');
    }
    if (repoNames.has(repo.name)) {
      throw new Error(`Duplicate repository name: ${repo.name}`);
    }
    repoNames.add(repo.name);
    
    if (!repo.team_permissions || !Array.isArray(repo.team_permissions)) {
      throw new Error(`Repository ${repo.name} missing "team_permissions" array`);
    }
    
    // Validate permissions
    repo.team_permissions.forEach(perm => {
      if (!perm.team || !perm.permission) {
        throw new Error(`Invalid permission entry in repository ${repo.name}`);
      }
      if (!teamNames.has(perm.team)) {
        throw new Error(`Repository ${repo.name} references unknown team: ${perm.team}`);
      }
      if (!['pull', 'push', 'maintain', 'admin'].includes(perm.permission)) {
        throw new Error(`Invalid permission level: ${perm.permission}`);
      }
    });
  });
  
  console.log('✅ JSON validation passed');
  console.log(`   - ${config.teams.length} teams`);
  console.log(`   - ${config.repositories.length} repositories`);
  
} catch (error) {
  console.error('❌ JSON validation failed:', error.message);
  process.exit(1);
}