pragma solidity ^0.5.16;
contract CrowdFunding {
  OwningEntity[] private owners;
  Project[] private projects;
  Transaction[] private transactions;

  struct OwningEntity {
    bytes32 name;
    bytes32 phoneNumber;
    bytes32[] projectNames;
  }

  struct Round {
    bytes32 projectName;
    uint startDate;
    uint endDate;
    uint targetAmount;
    uint collectedAmount;
  }

  struct Project {
    bytes32 projectName;
    bytes32 projectDescription;
    bytes32 projectLink;
    uint currentRound;
    uint startDate;
    Round[] rounds;
  }

  struct Transaction {
    uint amount;
    bytes32 projectName;
    uint round;
  }

// Add new Owning Entity
function addOwningEntity(bytes32 _name, bytes32 _phoneNumber) public view returns(bool success) {
  // Check if an owner exist with same phone number
  for(uint i = 0; i < owners.length; i++) {
    if(owners[i].name == _name){
      return false;
    }
  }
  OwningEntity private owner;
  owner.name = _name;
  owner.phoneNumber = _phoneNumber;
  owners.push(owner);
  return true;
}

// Add new project
function addNewProject(bytes32 _projectName, bytes32 _projectDescription, bytes32 _projectLink, uint _targetAmount, uint _startDate, uint _endDate, bytes32 _ownerName) public view returns(bool success){
    Project private project;
    Round[] private rounds;
    Round private firstRound;
    // Adding round 0 info
    // NOTE: Redundant value of projectName in round info
    firstRound.projectName = _projectName;
    firstRound.startDate = _startDate;
    firstRound.endDate = _endDate;
    firstRound.targetAmount = _targetAmount;
    firstRound.collectedAmount = 0;
    rounds.push(firstRound);
    // Populating project data
    project.projectName = _projectName;
    project.projectDescription = _projectDescription;
    project.projectLink = _projectLink;
    // NOTE: intiliasing round number with 0
    project.currentRound = 0;
    project.startDate = _startDate;
    project.rounds = rounds;
    // Adding project Details to owner
    for(uint i = 0; i < owners.length; i++) {
      if(owners[i].name == _ownerName){
        owners[i].projectNames.push(_projectName);
        break;
      }
    }
    return true;
} 
//Get all projects owned by a single org/entity
function getAllProjectsForAOwningEntity(bytes32 _ownerName) public view returns(bytes32[] memory) {
  uint length = owners.length;
  uint i = length-1;
  while (i >= 0) {
    if (owners[i].name == _ownerName) {
      return owners[i].projectNames;
    }
    i--;
  }
}

//Total funds raised over a period through various rounds
function getAllFundingsOverAPeriod(bytes32 _projectName, uint _startDate, uint _endDate) public view returns(uint fund) {
  uint i = transactions.length-1;
  while (i >= 0) {
    if (transactions[i].projectName == _projectName) {
      fund += transactions[i].amount;
    }
    i--;
  }
  return fund;
}

//Total funds raised in each round
function getTotalFundingRoundWise(bytes32 _projectName) public view returns(uint[] memory, uint[] memory) {
  uint size = projects.length;
  uint i = size-1;
  while (i >= 0) {
    if (projects[i].projectName == _projectName) {
      break;
    }
    i--;
  }
  size = projects[i].rounds.length;
  uint[] memory rounds = new uint[](size);
  uint[] memory funds = new uint[](size);
  uint j = size-1;
  //NOTE: there is no need of returning rounds array, as we can get it by it's position in array
  while (j >= 0) {
    funds[i] = projects[i].rounds[j].collectedAmount;
    rounds[i] = j;
    j--;
  }
  return(rounds, funds);
}

//Total funds raised so far in this round
function getTotalFundingCurrentRound(bytes32 _projectName) public view returns(uint fund) {
  uint size = projects.length;
  uint i = size-1;
  while (i >= 0) {
    if (projects[i].projectName == _projectName) {
      break;
    }
    i--;
  }
  size = projects[i].rounds.length;
  uint j = size-1;
  while (j >= 0) {
    if(projects[j].projectName == _projectName) {
      return projects[j].rounds[projects[j].rounds.length - 1].collectedAmount;
    }
    j--;
  }
  return 0;
}

//Total funds raised since the beginning
function getTotalFundingReceived(bytes32 _projectName) public view returns(uint fund) {
  uint size = projects.length;
  uint i = size-1;
  while (i >= 0) {
    if(projects[i].projectName == _projectName) {
      uint roundLength = projects[i].rounds.length;
      uint j = roundLength - 1;
      while (j >= 0) {
        fund += projects[i].rounds[j].collectedAmount;
      }
      return fund;
    }
    i--;
  }
  return 0;
}

//Total funds requested for the current round
function getTargetAmount(bytes32 _projectName, uint _roundNumber) public view returns(uint fund) {
  uint size = projects.length;
  uint i = size-1;
  while (i >= 0) {
    if(projects[i].projectName == _projectName) {
      return projects[i].rounds[_roundNumber].targetAmount;
    }
    i--;
  }
  return 0;
}
}
