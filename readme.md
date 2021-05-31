- Clone the repository in the same level of the project that you want to automate the updating of the environments values, 
running the next command.

`git clone adk-hq-regression-test-run-all-env`

- give execute permission: 

`chmod +x updateConfig.sh`

- create a new regression data file

`cp regression-data.demo.txt regression-data.txt`

- finally, run the script: 
  
`./updateConfig.sh`