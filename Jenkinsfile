def CHECK_CURL(String OUTPUT) 
{
    return OUTPUT.contains('PetClinic :: a Spring Framework demonstration')
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
        stage("Create network") 
		{
            steps 
			{
                echo 'Creating network...'
				sh "docker network create ${NET_PET}"
				echo 'Network created!'
            }
        }
		stage("Сreate docker image") 
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
		stage("Push into docker image") 
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
		stage("Curl") 
		{
            steps 
			{
				echo "Pulling curl..."
				sh "docker pull curlimages/curl:latest"
				echo "Done!"
            }
        }
		stage("Run image from docker hub") 
		{
            steps 
			{
				echo "Pulling image..."
                sh "docker pull ${USER}/${REP}:${VERSION}"
				echo "Done!"
				echo "Running image..."
				sh "docker run --name ${PET_NAME} -d --network ${NET_PET} -p 3000:3000 ${USER}/${REP}:${VERSION}"
				echo "Done!"
            }
        }
		stage("Run curl") 
		{
            steps 
			{
				echo "Running curl image..."
				sleep(30)
				script 
				{
					def PET_IP = sh (
                        script: "docker inspect -f '{{range.NetworkSettings.Networks}}{{.Gateway}}{{end}}' ${PET_NAME}",
                        returnStdout: true).trim().split(" ").last().replace("\'", "").trim()
					println("get IP: ${PET_IP}")
					def RESULT = sh (script: "docker run --name ${CURL_NAME} --rm --network ${NET_PET} curlimages/curl:7.81.0 -L -v ${PET_IP}:3000/ --fail-with-body",
										  returnStdout: true)
					if (CHECK_CURL(RESULT)) 
					{
						println("SUCCESS")
					} 
					else 
					{
						println("FAIL")
					}
				}
            }
        }
    }
	post 
	{
		always
		{
			sh "docker stop ${PET_NAME}"
            sh "docker container rm ${PET_NAME}"
			sh "docker network rm ${NET_PET}"
		}
	}
	
}