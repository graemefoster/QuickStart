# QuickStart Azure Devops Pipeline setup

You'll need access to an Azure Devops project to use these Pipelines.

## Step 1 - Clone the repo locally

``` git clone https://github.com/graemefoster/QuickStart/```

## Step 2 - Create a new repository in your Github account

## Step 3 - Add a remote to your local repository and push

```bash
cd QuickStart
git remote remove origin
git remote add origin <new-repository-url>
git push origin 
```

## Step 4 - Create the pipeines

- Head to the Pipelines section of your Project.
- Select ``` Create Pipeline ```
- Select ``` Azure Repos Git ``` when asked 'Where is your code?'
- Select the Quickstart Repository
- Select ``` Existing Azure Pipelines YAML file ``` when asked to 'Configure your pipeline'
- Locate the ``` AzDevOps/Platform-Pipeline.yaml ``` file and select 'Continue'

