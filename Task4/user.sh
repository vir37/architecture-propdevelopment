# Общие переменные (задать по данным действующего кластера)
# 
server_certificate_path="???" # путь к сертификату CA кластера (берется из конфига кластера)
server="https://x.x.x.x:yyyy" # URL сервера (берется из конфига кластера)
ca_path="???" #путь к CA кластера

cluster_name="kubernetes" # наименование кластера Kubernetes

# -------------------------------------------------------------------------------------------------------
# 1. Создание пользователя "clusteradministrator"
user="clusteradministrator"
user_home="/home/$user"
filename="$user_home/$user"

# Создание пользователя в операционной системе
useradd $user

# Генерация приватного ключа
openssl genrsa -out $filename.key 2048

# Создание запроса на выпуск сертификата
openssl req -new -key $filename.key -out $filename.csr -subj "/CN=$user"

# Генерация и подпись сертификата пользователя
openssl x509 -req -in $filename.csr -CA $ca_path/ca.crt -CAkey $ca_path/ca.key -CAcreateserial -out $filename.crt -days $days

# Создание директории с сертификатами в домашнем каталоге пользователя
mkdir $user_home/.certs && mv $filename.* $user_home/.certs

# Регистрация пользователя в кластере
kubectl config set-credentials $user --client-certificate=$user_home/.certs/$user.crt  --client-key=$user_home/.certs/$user.key

# Задание контекста пользователю
kubectl config set-context $user-context --cluster=$cluster_name --user=$user

# Создание конфиг.файла Kubernetes для пользователя
mkdir $user_home/.kube
cat <<-EOF > $user_home/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: $certificate_data
    server: $server
  name: $cluster_name
contexts:
- context:
    cluster: $cluster_name
    user: $user
  name: $user-context
current-context: $user-context
kind: Config
preferences: {}
users:
- name: $user
  user:
    client-certificate: $user_home/.certs/$user.crt
    client-key: $user_home/.certs/$user.key
EOF
	
# Смена владельца у файлов
sudo chown -R $user: $user_home


# 2. Создание пользователя "clusterreader"
user="clusterreader"
user_home="/home/$user"
filename="$user_home/$user"

# Создание пользователя в операционной системе
useradd $user

# Генерация приватного ключа
openssl genrsa -out $filename.key 2048

# Создание запроса на выпуск сертификата
openssl req -new -key $filename.key -out $filename.csr -subj "/CN=$user"

# Генерация и подпись сертификата пользователя
openssl x509 -req -in $filename.csr -CA $ca_path/ca.crt -CAkey $ca_path/ca.key -CAcreateserial -out $filename.crt -days $days

# Создание директории с сертификатами в домашнем каталоге пользователя
mkdir $user_home/.certs && mv $filename.* $user_home/.certs

# Регистрация пользователя в кластере
kubectl config set-credentials $user --client-certificate=$user_home/.certs/$user.crt  --client-key=$user_home/.certs/$user.key

# Задание контекста пользователю
kubectl config set-context $user-context --cluster=$cluster_name --user=$user

# Создание конфиг.файла Kubernetes для пользователя
mkdir $user_home/.kube
cat <<-EOF > $user_home/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: $certificate_data
    server: $server
  name: $cluster_name
contexts:
- context:
    cluster: $cluster_name
    user: $user
  name: $user-context
current-context: $user-context
kind: Config
preferences: {}
users:
- name: $user
  user:
    client-certificate: $user_home/.certs/$user.crt
    client-key: $user_home/.certs/$user.key
EOF
	
# Смена владельца у файлов
sudo chown -R $user: $user_home
