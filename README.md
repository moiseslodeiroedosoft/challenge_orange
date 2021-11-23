# Challenge MLS - Orange

## Prerequisitos

- Disposición de un cluster de k8s
- Disposición de docker

## Paso 1 - Iniciar Clúster

En este caso, a modo de ejemplo, se ha hecho uso del sistema _minikube_ para emular un clúster de un solo nodo, con 4096Mb de RAM y de una CPU virtual.

```sh
minikube start --nodes 1 --mount --mount-string="$HOME/images:/srv/images" --memory 4096 --cpus=2 --addons=ingress --kubernetes-version=latest --extra-config=apiserver.feature-gates=RemoveSelfLink=false
```

## Paso 2 - Compilar imagen de Jenkins con las dependencias y plugins instalados

Durante este paso, no sólo se hará la compilación sino que la imagen será cargada en los nodos de kuberentes.

### Montar carpetas locales en nodos donde almacenar imágenes docker

Si no hubo problemas a la hora de hacer el montaje de ficheros al crear el cluster, o se usó otro, se puede omitir este paso.

```sh
minikube mount ~/images:/srv/images &
```

### Compilar imagen y cargar en nodos

```sh
docker build . -t jenkins:orange && docker save -o ~/images/jenkins.tar.gz jenkins:orange && for nodeName in `minikube node list | tr '\t' ' ' | cut -d ' ' -f1`; do minikube ssh -n $nodeName "sudo docker load -i /srv/images/jenkins.tar.gz"; done;
```

## Paso 3 - Tareas de Kubernetes

```sh
kubectl create -f sa.yml
kubectl create -f jenkins.yml
kubectl create namespace usuario-1
kubectl create namespace usuario-2
kubectl create -f roles/user1.yml
kubectl create -f roles/user2.yml
```

Nota: Si se quiere mantener persistencia en el volumen /var/jenkins_home (donde se almacena la configuración), ejecutar también el siguiente comando:

```sh
kubectl patch pv `kubectl get pv --no-headers | grep "jenkins-pv-claim" | cut -d" " -f1` -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

Después de que la imagen se termine de montar, se podrá acceder a la web vía

`http://$(minikube ip):32000/`

## Paso 4 - Configurando Jenkins

Dentro de la web (no es necesario usuario y contraseña), acceder al endpoint `configure` y cambiar el número de ejecutores a 12. Guardar los cambios.

## Paso 5 - Configurar Nube Kubernetes

Acceder al endpoint `configureClouds/` y añadir una nube de tipo kubernetes con los siguientes parámetros de configuración:

- name: kubernetes
- kuberentes url: (dejar en blanco)
- Disable https certificate check: marcar
- Kubernetes namespace: default

Hacer clic en Credentials - Add.

Antes de seguir, desde una terminal, ejecutar la siguiente secuencia de comandos y copiar el resultado:

```sh
kubectl get secrets `kubectl get serviceaccount jenkins-admin -o=jsonpath='{.secrets[0].name}' -n default` -o=jsonpath='{.data.token}' -n default | base64 -d
```

Siguiendo con la creaciónd e credenciales, seleccionar tipo (kind) como _secret text_ y, en el apartado "secret", pegar la cadena resultante del comando anterior.

En ID, se puede poner un nombre que identifique estas credenciales como, por ejemplo, cluster-k8s y se puede dejar vacía la descripción.

Una vez creada la credencial, seleccionar la misma en el desplegable de _Credentials_ y **guardar la configuración**.

Para verificar que se conecta correctamente, se puede hacer clic en el botópn "Test connection", dando como resultado _Connected to Kubernetes v1.22.4-rc.0_.

Agregar a Jenkins URL: `http://jenkins-service.default.svc.cluster.local:8080`.

En la sección de Container template, agregar la siguiente información por defecto:

- Name: jnlp
- Docker image: jenkins/inbound-agent:4.3-4
- Vaciar command to run
- Vaciar arguments to pass to the command

## Paso 6 - Configuración de pipeline mediante un repositorio Git

En el panel principal, agregar una nueva tarea de nombre _test_ (o el que se requiera), de tipo **pipeline**. Hacer clic en OK.
Dentro del apartado de creación, bajar hasta la sección **Pipeline**.

En definition, seleccionar "Pipeline script from SCM". En SCM, seleccionar git y añadir la URL de este repositorio (_`https://github.com/moiseslodeiroedosoft/challenge_orange.git`_). En este caso no hacen falta credenciales, aunque se pueden agregar vía clave privada y pública siguiendo el mismo procedimiento que antes pero cambiando el tipo de _kind_ por _SSH Username with private key_ y agregando los campos oportunos del pareado de claves privada y pública ([agregada y on permisos en github](https://docs.github.com/es/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)).

Asegurarse de tener marcado en el _Script Path_ la opción _Jenkinsfile_ y hacer clic en guardar.

## Paso 7 - Ejecutar pipeline

Para la ejecución del pipeline, hacer clic en "Construir ahora". Una vez la pipeline se valide, se podrá hacer uso de los parámetros que contiene la misma.

### Visualizar resultado

El final del resultado debería ser algo similar a

```
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // container
[Pipeline] }
[Pipeline] // stage
[Pipeline] echo
[BRANCH:master, CHOICE:One, LASTNAME:Lodeiro, NAME:Moises]
[Pipeline] echo
Moises
[Pipeline] }
[Pipeline] // node
[Pipeline] }
[Pipeline] // podTemplate
[Pipeline] End of Pipeline
Finished: SUCCESS
```
