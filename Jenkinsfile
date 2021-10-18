node 
  {	  	          
	stage ('Workspace Cleanup') {
	  cleanWs()	                          
	}
	stage('Code Checkout')
	{
        git url: 'https://github.com/knagu/WeatherApi.git', branch: 'master' 
	}
	
	
   //stage('Build Stage')
	//{	   	  
        //sh label: '', script: '''
        //cd weatherapi
        //dotnet restore
        //dotnet build
        //dotnet publish -c Release -o out'''
	//    echo "Build Successful"
  //  }             
    stage('Build'){        	   
            sh label: '', script: '''                
            auth_token=`aws codeartifact get-authorization-token --domain daxeos --query authorizationToken --output text --duration-seconds 900 --region us-west-2`
            docker build -t 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi:latest --build-arg TOKEN=$auth_token .
            docker build -t 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi:$BUILD_NUMBER --build-arg TOKEN=$auth_token .           
            '''  
            echo "Build Succcessful"     	    
    }
    stage('Push the Docker image'){        
            sh label: '', script: '''                            
            aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 921881026300.dkr.ecr.us-west-2.amazonaws.com
            docker push 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi:latest
            docker push 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi:$BUILD_NUMBER 
            docker rmi -f 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi:latest
            docker rmi -f 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi:$BUILD_NUMBER
            '''                      
    }
    stage('Terraform Plan'){                             
        sh label: '', script: '''   
        cd terraform
        sed -i 's/btag/'$BUILD_NUMBER'/g' variables.tf
        terraform init
        echo "yes" | terraform plan 
        '''          
     }  
     stage('Terraform Apply'){     
        timeout(time: 10, unit: 'MINUTES') {
        input message: "Do you want to proceed for deployment?"
     }                   
        sh label: '', script: '''   
        cd terraform
        echo "yes" | terraform apply
        '''          
     }               
  }
