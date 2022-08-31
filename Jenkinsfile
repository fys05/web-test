def secret_name = "registry-auth-secret"
def k8s_auth = "kubeconfig"
podTemplate(
    cloud: "kubernetes",
    namespace: "jenkins",
    label: 'jenkins-slave',
    // 配置容器信息
    containers: [
        containerTemplate(
            name: "jnlp",
            image: "jenkins/inbound-agent:4.11.2-4"
        ),
        containerTemplate(
            name: "docker",
            image: "docker:stable",
            ttyEnabled: true,
            command: 'cat'
        )
    ],
    volumes:[
        hostPathVolume(mountPath:'/var/run/docker.sock',hostPath:'/run/docker.sock')
    ]
){
    node('jenkins-slave'){
        stage("echo"){
            echo "test"
        }
        stage('代码拉取') {
            git credentialsId: 'cd4dfa5f-49d6-4908-a344-fe418d28dcbd', url: 'http://192.168.40.210:31323/fff/web-test.git'
        }
        stage('构建镜像上传dockerhub'){
            container('docker'){
                def harbor_auth="d9660d46-a9db-4b61-ba9b-1f77a6e23d6a"
                sh "pwd && docker build -t nginx:v1 . && docker tag nginx:v1 fuyongsheng/k8s-repo:nginx-test"
                //第一种推送镜像方式,主要是登陆方式不同
                //sh "echo fys051813 | docker login -u fuyongsheng --password-stdin"
                //sh "docker push fuyongsheng/k8s-repo:nginx-test"方式方式
                //第二种推送镜像方式
                withCredentials([usernamePassword(credentialsId: "${harbor_auth}", passwordVariable: 'password', usernameVariable: 'username')])
                {
                    sh "docker login -u ${username} -p ${password}"
                    sh "docker push fuyongsheng/k8s-repo:nginx-test"
                }
            }
        }
        def image_name = "fuyongsheng/k8s-repo:nginx-test"
        //部署到K8S
        sh "pwd && ls"
        sh """sed -i 's#\$IMAGE_NAME#${image_name}#' nginx.yml 
              sed -i 's#\$SECRET_NAME#${secret_name}#' nginx.yml
        """
        kubernetesDeploy configs: "nginx.yml",kubeconfigId: "${k8s_auth}"
    }
}