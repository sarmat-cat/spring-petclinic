def CHECK_CURL(String OUTPUT) 
{
    return OUTPUT.contains('PetClinic :: a Spring Framework demonstration')
}

def withDockerNetwork(Closure inner) 
{
	try 
		{
			networkId = UUID.randomUUID().toString()
			sh "docker network create ${networkId}"
			inner.call(networkId)
		} 
	finally 
		{
			sh "docker network rm ${networkId}"
		}
}

pipeline 
{
    agent any
	environment 
	{
		USER 		= 'nasiya'
		REP 		= 'mypetclinic'
		VERSION 	= 'latest'
		ART_ID 		= 'spring-petclinic'
		NET_PET 	= UUID.randomUUID().toString()
		CURL_NAME 	= UUID.randomUUID().toString()
		PET_NAME 	= UUID.randomUUID().toString()
	}
    stages 
	{
        stage("Creating network") 
		{
            steps 
			{
                echo 'Creating network...'
				sh "docker network create ${NET_PET}"
				echo 'Network created!'
            }
        }
		stage("Build image") 
		{
			steps 
			{
				echo "Building image..."
				script 
				{
					docker.build("${USER}/${REP}:${VERSION}", "--build-arg JAR_VERSION=${VERSION} --build-arg JAR_ARTIFACT_ID=${ART_ID} -f Dockerfile .")
				}
				echo "Done"
			}
        }
		stage("Check") 
		{
			steps 
			{
				script 
				{
					def app = docker.image("${USER}/${REP}:${VERSION}")
					def client = docker.image("curlimages/curl:latest")

					withDockerNetwork
					{ n ->
						app.withRun("--name app --network ${NET_PET}") 
						{ c ->
							client.inside("--network ${NET_PET}") 
							{
								echo "I'm client!"
								sh "sleep 300"
								sh "curl -S --fail http://app:3000 > curl_output.txt"
								sh "cat curl_output.txt"
								archiveArtifacts artifacts: 'curl_output.txt'
							}
						}
					}
				}
			}
		}
		stage("Push image") 
		{
			steps 
			{
				echo "Pushing image..."
				withCredentials([usernamePassword(credentialsId: 'credentials_dockerhub', passwordVariable: 'pass_dockerhub', usernameVariable: 'user_dockerhub')]) 
				{
					echo "loging in Docker Hub"
					sh "echo ${pass_dockerhub}| docker login -u ${user_dockerhub} --password-stdin"
					echo "pushing into Docker Hub"
					sh "docker push ${USER}/${REP}:${VERSION}"
				}
				echo "Done!"
			}
		}

    }
	post 
	{
		always
		{
			sh "docker network rm ${NET_PET}"
		}
	}
	
}