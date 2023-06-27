def secret_name = "registry-auth-secret"
def k8s_auth = "kubeconfig"
podTemplate(
    cloud: "kubernetes",
    namespace: "devops",
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
        hostPathVolume(mountPath:'/var/run/docker.sock',hostPath:'/run/docker.sock'),
        hostPathVolume(mountPath:'/usr/bin/kubectl',hostPath:'/usr/bin/kubectl')
    ]
){
    node('jenkins-slave'){
        stage("echo"){
            echo "test"
        }
        stage('代码拉取') {
           // git credentialsId: 'cd4dfa5f-49d6-4908-a344-fe418d28dcbd', url: 'http://192.168.40.210:31323/fff/web-test.git'
           git credentialsId: 'gitlab', url: 'http://192.168.40.210:32456/root/web-test.git'
        }
        stage('构建镜像上传dockerhub'){
            container('docker'){
                def harbor_auth="dockerhub"
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
        kubeconfig(credentialsId: 'kubeconfig', serverUrl: '') {
         // some block
         sh """ kubectl apply -f nginx.yml --record
                kubectl rollout restart -f nginx.yml
         """
        }
        //kubernetesDeploy configs: "nginx.yml",kubeconfigId: "${k8s_auth}" //新版jenkins取消了Kubernetes Continuous Deploy插件，该插件有漏洞
    }
}
