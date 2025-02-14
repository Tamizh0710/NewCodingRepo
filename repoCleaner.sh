#!/bin/sh

:'This is an automated bash script to reads a list from a masterRepoList text file'

file='masterRepoList.txt'
files=$(git ls-files)
for file in ${files} ; 
do 
    echo $file ; 
done;


:'
  This is an automated bash script to delete git branches older than 1 year.
  '
declare -i timeWindow=12 # Declare the default period in months
declare blackListedBranches # Blacklisted branches
clear=clear # Command to clear terminal
ECHO='echo ' # Custom echo

${clear} # Clear terminal

# Check for passed period(In months) parameter
if [ -z "$1" ]; 
then
  # Period not set
  echo ""
  echo "Period not set. Assuming delete period to the default $timeWindow months period!"
  echo ""
  sleep 2 # Hold for 2 seconds
else
  # Period set
  timeWindow=$1 # Set passed period
fi

echo "Deleting branches older than $timeWindow months!"
echo ""
sleep 1 # Hold for a second


# Set branches to exclude in deletion
blackListedBranches="main,master,development"



# Check for trailing commas to remove them
if [[ "$blackListedBranches" == *, ]]; 
then  
  declare trimmedValue=$(sed 's/.\{1\}$//' <<< "$blackListedBranches") # Remove last character
  blackListedBranches="$trimmedValue" # Re-assign value
fi

# Start loop to search for commas
while true; do
  # Check for commas in case of comma separated list to create a list for GREP
  case "$blackListedBranches" in 
    *,*)
      declare branchSeparator="$\|" # Declare separator syntax
      blackListedBranches=${blackListedBranches/,/$branchSeparator} # Replace comma with GREP separator syntax
      ;;
    *) # Default
      break # Break loop
    ;;
  esac
done

blackListedBranches="${blackListedBranches}$" # Append dollar sign at the end of GREP list

echo "The branches [ $blackListedBranches ] will not be deleted!"
sleep 2 # Hold for 2 seconds

echo "The branches below will be deleted!"
sleep 1 # Hold for 2 seconds
git branch -a | sed 's/^\s*//' | sed 's/^remotes\///' | grep -v $blackListedBranches
sleep 4 # Hold for 2 seconds

: '
  Initiate loop scanning for branches older than passed time or set default while excluding the below branches
  main, master
'
for target_branch in $(git branch -a | sed 's/^\s*//' | sed 's/^remotes\///' | grep -v $blackListedBranches); 
do
  # Check period
  if ! ( [[ -f "$target_branch" ]] || [[ -d "$target_branch" ]] ) && [[ "$(git log $target_branch --since "$timeWindow month ago" | wc -l)" -eq 0 ]]; then
    if [[ "$DRY_RUN" = "false" ]]; 
    then
      ECHO="" # Empty echo
    fi

    local_target_branch_name=$(echo "$target_branch" | sed 's/remotes\/origin\///') # Get target branch in iteration
    local_target_branch_name=${local_target_branch_name/origin\//} # Replace string "origin/" with empty(string)
    $ECHO Deleting Local Branch : "${local_target_branch_name}" # Print message
    sleep 1 # Hold for a second
    git branch -d "${local_target_branch_name}" # Delete local branch
    $ECHO Deleting Remote Branch : "${local_target_branch_name}" # Print message
    sleep 1 # Hold for a second
    git push origin --delete "${local_target_branch_name}" # Delete remote branch
  fi
done