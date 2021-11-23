podTemplate(containers: [
    containerTemplate(
        name: 'busybox',
        image: 'busybox:latest',
        command: 'sleep',
        args: '30d'
        ),
    containerTemplate(
        name: 'node',
        image: 'node:latest',
        command: 'sleep',
        args: '30d')
]){

  properties([
    parameters([
          string(name: 'NAME', defaultValue: 'Moises', description: 'Nombre'),
          string(name: 'LASTNAME', defaultValue: 'Lodeiro', description: 'Apellido'),
          choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something'),
          string(defaultValue: 'master', name: 'BRANCH'),
    ])
  ])

  node(POD_LABEL) {

      stage('Start project') {
          git(
            branch: "${params.BRANCH}",
            url: 'https://github.com/luishernandez25/easyTest.git'
          )
          container('busybox') {
              stage('First step') {
                  sh '''
                  ls -lat
                  '''
              }
          }
      }

      stage('Run node and print envs') {
          container('node') {
              stage('Print parameters') {
                  sh "node -e 'console.log(process.env);'"
                  echo "${params.NAME}"
                  echo "${params.LASTNAME}"
                  echo "${params.CHOICE}"
                  echo "${params.BRANCH}"
              }
          }
      }

      try {
          echo "${params}"
      } finally {
          echo "${params.NAME}"
      }

  }

}
