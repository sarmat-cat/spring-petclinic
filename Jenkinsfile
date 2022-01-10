def CHECK_CURL(String OUTPUT) {
    return OUTPUT.contains('PetClinic :: a Spring Framework demonstration')
}

pipeline {
    agent any
	environment {
		USER = 'nasiya'
		REP = 'petclinic'
		VERSION = '2.5.0-SNAPSHOT'
		ART_ID = 'spring-petclinic'
		NET_PET = UUID.randomUUID().toString()
		CURL_NAME = UUID.randomUUID().toString()
		PET_NAME = UUID.randomUUID().toString()
	}
    stages {
        stage("create nerwork") {
            steps {
                echo 'Im just sayin'
				echo 'open'
				bat "docker network create ${NET_PET}"
            }
        }
		stage("create docker image") {
			steps {
				echo "building the image"
				script {
					docker.build("${USER}/${REP}:${VERSION}", "--build-arg JAR_VERSION=${VERSION} --build-arg JAR_ARTIFACT_ID=${ART_ID} -f Dockerfile .")
				}
			}
        }
		stage("push into docker image") {
			steps {
				withCredentials([usernamePassword(credentialsId: 'credentials_dockerhub', passwordVariable: 'pass_dockerhub', usernameVariable: 'user_dockerhub')]) {
					echo "loging in Docker Hub"
					bat "echo ${pass_dockerhub}| docker login -u ${user_dockerhub} --password-stdin"
					echo "pushing into Docker Hub"
					bat "docker push ${USER}/${REP}:${VERSION}"
				}
			}
		}
		stage("curl") {
            steps {
				bat "docker pull curlimages/curl:7.81.0"
				echo "pull curl, yo"
            }
        }
		stage("run from Docker Hub") {
            steps {
				echo "pulling from Docker Hub"
                bat "docker pull ${USER}/${REP}:${VERSION}"
				echo "run the app"
				bat "docker run --name ${PET_NAME} -d --network ${NET_PET} -p 3000:3000 ${USER}/${REP}:${VERSION}"
				echo "now it is curl time"
            }
        }
		stage("run curl") {
            steps {
				echo "run curl container"
				script {
					sleep(60)
					def PET_IP = bat (
                        script: "docker inspect -f '{{range.NetworkSettings.Networks}}{{.Gateway}}{{end}}' ${PET_NAME}",
                        returnStdout: true).trim().split(" ").last().replace("\'", "").trim()
					println("get IP: ${PET_IP}")
					def RESULT = bat (script: "docker run --name ${CURL_NAME} --rm --network ${NET_PET} curlimages/curl:7.81.0 -L -v ${PET_IP}:3000/",
										  returnStdout: true)
					if (CHECK_CURL(RESULT)) {
							println("SUCCESS")
						} 
					else {
							println("FAIL")
						}
				}
            }
        }
    }
	post {
		always{
			bat "docker stop ${PET_NAME}"
            bat "docker container rm ${PET_NAME}"
			bat "docker network rm ${NET_PET}"
		}
	}
	
}

				