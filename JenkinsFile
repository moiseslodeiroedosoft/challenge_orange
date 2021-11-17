pipeline {
    // agent { docker { image 'jenkins:orange' }
    agent any
    parameters {
        string(name: 'NAME', defaultValue: 'Moises', description: 'Nombre')
        string(name: 'LASTNAME', defaultValue: 'Lodeiro', description: 'Apellido')
        choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH'
    }
    stages {
        stage('Descarga git') {
            steps {
                git(
                    branch: "${params.BRANCH}",
                    credentialsId: 'myid',
                    url: 'https://github.com/luishernandez25/easyTest.git'
                )
                sh "ls -lat"
            }
        }
        stage('Salida job') {
            steps {
                sh "echo ${params.NAME}"
                sh "echo ${params.LASTNAME}"
                sh "echo ${params.CHOICE}"
                sh "echo ${params.BRANCH}"

                sh "echo 'process.env' > salida.js"
                sh "node salida.js"

            }
        }
    }
}
