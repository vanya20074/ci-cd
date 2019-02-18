job("dsl-domain-init") {
    description()
    keepDependencies(false)


    disabled(false)
    concurrentBuild(false)
    scm{
        git{
            remote{
                branch("master")
                credentials("9b6f1814-3355-4285-92a0-45d354ed2df5")
                url('https://Bimmo@bitbucket.org/Bimmo/ci-cd.git')
            }
        }
    }
    steps {


        shell("""pwd
cd domain-init
terraform init
rm *.tfstate
terraform import aws_instance.jump i-0b87886bb35c38371
terraform plan
terraform apply -auto-approve""")
    }

    publishers {
        downstream('dsl-create-infrastructure', 'SUCCESS')
    }
}

job("dsl-create-infrastructure") {
    description()
    keepDependencies(false)


    disabled(false)
    concurrentBuild(false)
    scm{
        git{
            remote{
                branch("master")
                credentials("9b6f1814-3355-4285-92a0-45d354ed2df5")
                url('https://Bimmo@bitbucket.org/Bimmo/ci-cd.git')
            }
        }
    }
    steps {


        shell("""pwd
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
sudo ./set_hosts.sh""")
    }
    publishers {
        downstream('dsl-build_app', 'SUCCESS')
    }

}

job("dsl-destroy-infrastructure") {
    description()
    keepDependencies(false)


    disabled(false)
    concurrentBuild(false)

    steps {


        shell("""pwd
cd ../dsl-create-infrastructure/terraform/
terraform destroy -auto-approve
""")
    }
}


job("dsl-build_app") {
    description()
    keepDependencies(false)
    scm {
        git {
            remote {
                github("vanya20074/java_example", "https")
            }
            branch("*/master")
        }
    }
    disabled(false)
    concurrentBuild(false)
    steps {

        maven {
            mavenInstallation('mvn')
            goals('clean')
            goals('package')
        }
        shell("""pwd
cd docker
cp ../target/docker_home.jar docker_home.jar
sudo docker build -t anekdot/java_test_app .
sudo docker push anekdot/java_test_app""")
    }

    publishers {
        downstream('dsl-ansible', 'SUCCESS')
    }

}

job("dsl-ansible") {
    description()
    keepDependencies(false)
    scm {
        git{
            remote{
                branch("master")
                credentials("9b6f1814-3355-4285-92a0-45d354ed2df5")
                url('https://Bimmo@bitbucket.org/Bimmo/ci-cd.git')
            }
        }
    }
    disabled(false)
    concurrentBuild(false)
    steps {
        shell("""cd ansible
ansible-playbook playbook.yml --key-file /home/ubuntu/linux.pem""")
    }
}