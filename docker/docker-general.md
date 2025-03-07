# DOCKER

Docker temel olarak üç parçadan oluşan ve uygulama geliştirme,konteynerleştirme ve çalıştırma platformudur.

Temelde **Docker Engine** yer alır. 

- **Daemon Process** : Direkt olarak kullanıcı kontrolünde çalışmayan, arka
planda hizmet veren işlemlerdir. Sistem çalışma zamanı boyunca çalışabilirler.
- Sistem zamanı boyunca çalışan daemon işlemlere örnek olarak
`crond`, `sshd`, `httpd` ve `nfsd` işlemleri verilebilir.

Docker Engine, belli başlı 3 elemandan oluşan bir "client-server" uygulamasıdır.

- **Server:** dockerd daemon servisinin çalıştığı bir server.
- **API:** Programların server ile konuşmalarına yarayan ve 
    server tarafına komutları yollayan bir REST API servisi.
- **CLI:** Client tarafında API servisinin kullanımı için kullanılan bir CLI.

Yukarıdaki elemanlar sayesinde konteynerler, konteyner imajları, 
veri bölümlendirmeleri ve ağ yapısı yönetilebilir.

Docker mimarisi, client-server mimarisine dayanmaktadır.

Docker host üzerinde bulunan daemon, API isteklerini sürekli dinler ve docker
objelerini bu isteklere bağlı olarak yönetir.

Docker client, `docker run` gibi komutları API isteği şeklinde dockerd servisine
iletir. Kullanıcı tarafının etkileşim noktasıdır.

Docker registry, docker imajlarını tutar. Manuel olarak belirtilmediği sürece
DockerHub üzerindeki imajlarla etkileşim kurar.

İmajlar aslen okunabilir konteyner oluşturma komut taslağı olarak çalışır.
Dockerfile üzerinde belirtilen değişiklikler ve spesifikasyonlar ile çalışan
build operasyonları sonrasında ortaya çıkan imajlar ve halihazırda DockerHub
üzerinde bulunan public imajlar örnek olarak gösterilebilir.

Mesela `docker run -i -t ubuntu /bin/bash`  komutunu örnek alacak olursak;

1. Ubuntu imajı local registry üzerinde bulunmuyorsa DockerHub üzerinden
   indirilir. 
2. Yeni bir konteyner oluşturulur. 
3. Docker konteyner üzerinde bir read-write dosya sistemi oluşturur. 
4. Herhangi bir network interface belirtmediğimiz için Docker bizim yerimize
   yeni bir network oluşturur. 
5. Docker konteyneri başlatır ve `/bin/bash` komutunu çalıştırır.
6. `-i` ve `-t` parametreleri sayesinde konteynerimiz interaktif ve
   terminalimize bağlı çalışır. exit komutuyla konteynerden ayrıldığımızda ise
   konteyner durdurulur ancak imajı silinmez.

Docker izole bir çalışma çevresi oluşturmak için namespaces denen bir teknoloji
kullanır.Bu namespaces katmanında her konteyner için `pid`, `net`, `mnt` gibi
değerler bulunur.

## DOCKERFILE

Docker imajlarını otomatik olarak üretebilmek için **Dockerfile** olarak bilinen
dosyaları kullanır. Dockerfile aslen client tarafındaki kullanıcının
kullanabileceği ve konteyner konfigurasyonunda ihtiyaç duyabileceği her türlü
komutu ve bilgiyi içeren bir dosyadır. `docker build` komutuyla kullanıldığında
parametre kullanımına gerek kalmadan otomatik konteyner oluşturulabilir. 

Dockerfile formatı aşağıdaki gibi yazılır:

`# Comment`

`INSTRUCTION arguments`

Örneğin:

	FROM busybox
	ENV FOO=/bar
	WORKDIR ${FOO}   # WORKDIR /bar
	ADD . $FOO       # ADD . /bar
	COPY \$FOO /quux # COPY $FOO /quux

Oluşturulan Dockerfile, `docker build -f /path/to/Dockerfile .` şeklinde çalıştırılabilir.

### Docker çevre değişkenleri 

- **ADD**

    `ADD hom* /mydir/` 

    hom ile başlayan herşeyi /mydir altına ekler. Add komutu yeni dosyaların
    kopyalanmasında kullanılır. Formatı `ADD [--chown=<user>:<group>] <src>...
    <dest>` şeklindedir. Remote veya local `<src>` dosyalarını imajın `<dest>`
    dosya yoluna ekler.

- **COPY**

    `COPY hom* /mydir/` 

   `ADD` ile `COPY` arasındaki fark, `ADD`'in remote <src> üzerinden de
   çalışabilmesidir.

- **ENV** 

    `ENY MYNAME="John` 

   Çevre değişkenleri tanımlamamıza yardımcı olur.

    `ENV MYNAME="John" \ 
     MYCAT="fluffy" ` 

   şeklinde de kullanılabilir. `<key>=<value>` çiftleri şeklinde çalışır.

- **EXPOSE**

    `EXPOSE 80` veya `EXPOSE 80/udp` şeklinde çalışır. `<port>/<protocol>`
    formatına sahip değişkenler kullanır. `docker build -p 80:80/tcp ...`
    komutu ile benzerliği anlaşılabilir. 

- **FROM** etiketi yeni bir build ortamı kurar ve kullanılabilir bir Dockerfile'ın başında yer alır.
	Mesela 

    `FROM busybox:ver_1.5`
	
    `ARG` ve `FROM` etkileşimi burada anlaşılması gereken bir durumdur. Mesela:
    
    `ARG CODE_VER=latest` 

    `FROM base:${CODE_VERSION}` 


   `FROM` etiketinden sonra tanımlanmış bir `ARG`, build aşamasının dışında tutulur
   ve ilk `FROM` etiketinden sonra kullanılamaz.

- **LABEL** 

   Bu tanımlama imaja metadata ekler. `<key>=<value>` formatına sahiptir.
   Mesela:

   `LABEL "com.example.vendor"="ACME Incorporated"`

   `LABEL version="1.0"`
    
    `docker image inspect myimage` çıktısına bu `LABEL` tanımları eklenir.

- **STOPSIGNAL**

    Bu komut konteynerin exit aşamasında kullanılacak sinyali temsil eder. 9/15
    gibi değerler alabilir. 


- **USER**	

    Adından da anlaşılabileceği gibi konteynerin çalıştırılma zamanında kullanacağı 
    `<user>:<group>` değerlerinin belirlenmesinde rol oynar.

- **VOLUME**

    Bu komut docker için bir mount point tanımlar ve dosya dizin işlemlerinin
    içerisinde yapılmasını sağlar. Mesela, 

    `RUN echo "hello world" > /myvol/greeting` 
   
    `VOLUME /myvol` 

   Böylece greeting dosyası /myvol üzerine kopyalanır.

- **WORKDIR**	

    `WORKDIR $PATH` şeklinde çalışır. 
	
    `RUN`, `CMD`, `COPY` ve/ya `ADD` komutlarının çalıştırma dizinlerini belirler.
		
		WORKDIR /a
		WORKDIR b`
		WORKDIR c
		RUN pwd
    çıktısı /a/b/c şeklinde olacaktır.

- **ONBUILD**

    Bu komut imaja bir trigger ekler.
    
    `ONBUILD ADD . /app/src`
    
    `ONBUILD RUN /usr/local/bin/python-build --dir /app/src`

    şeklinde kullanımları mevcuttur ancak `ONBUILD ONBUILD` gibi bir kullanıma izin verilmez. `FROM` ve/ya `MAINTAINER` komutlarını tetiklemeyebilir.

- **RUN**

    `RUN <command>` 

    formatına sahiptir. Örneğin

    `RUN /bin/bash -c 'source $HOME/.bashrc; echo $HOME'`

    şeklindeki kullanımın 
    
    `RUN ["/bin/bash", "-c", "echo hello"]` 

    şeklinde JSON formatında yazılması da mümkündür ve Dockerfile içerisinde kullanılması tavsiye edilir.
	
- **CMD***

    Bu komutun kullanım amacı çalışan bir konteyner için default tanımlamaktır. Örneğin;

    `CMD echo "This is a test." | wc -`

- **MAINTAINER**

    Üretilen imajın "Author" alanını doldurur. Örneğin;
    
    `LABEL maintainer="SvenDowideit@home.org.au"`

    ile eşdeğer kullanılabilir.

- **ENTRYPOINT**

    Bu komut çalıştırılabilir haldeki bir konteynerin konfigurasyonunda rol oynar.

### Docker Networks

Docker kurulum esnasında otomatik olarak 3 temel network ekliyor.
Aynı zamanda 2 adet de driver desteği sağlıyor. bridge ve overlay.

Bir networke ait bilgiler `docker network inspect <network>` komutuyla bastırılabilir.

***bridge network:*** Aksi belirtilmedikçe konteynerler bu networke dahil ediliyor.
Bridge ağları genellikle iletişim kurması gereken ve 
standalone çalışan konteynerler için kullanılmaktadır.


#### Driver listesi

***host network:*** Konteynerlerin host makine ile yaşadığı network izolasyonunun 
kırılması için kullanılabilir ve konteyner host makinenin ağında çalışır.

***overlay network:*** overlay ağı birden fazla docker daemon servisini 
birbirine bağlar ve swarm servislerinin birbirleriyle olan iletişimini kurar.
Bu şekilde işletim sistemi seviyesindeki routing işlemlerine gereksinim ortadan kalkar.

***macvlan network:*** Konteynerlere MAC adresi ataması yapmak ve 
onları ağ üzerinde fiziksel bir cihaz olarak göstermek için kullanılır. 
Legacy uygulamalar ile çalışırken bu network driver'ını kullanmak bazen en iyi seçim olabilir.

***none network:*** Konteynerin ağ bağlantılarını koparmak için yapılır. 
Custom network driver'lar ile çalışılaması durumunda kullanılır.

--------------------------------------------------------------------------


`docker network disconnect bridge test-container` komutuyla 
test-container bridge network'den çıkarılır.

`docker network create -d bridge my_bridge` komutuyla da `my_bridge` adında ve
`bridge driver` ile çalışan bir network kurulabilir. 

Bir konteyneri basşlatırken belli bir networke eklemek için
`--net=<network_adı>` flag'i kullanılabilir.

Aynı networkteki konteynerler içerisinden shell yardımıyla diğer konteynerlere
`ping web/db` şeklinde ping atılabilir. 

**NOT!:** Bu işlem için konteynerlerin `docker network create myNetwork`
komutuyla oluşturulmuş olan yeni network üzerinde yer alıyor olmaları
gerekmekte. Ek olarak, IP kullanılarak atılan pingler aynı networkte olmayan
konteynerler için anlam taşımayacak ve %100 paket kaybı ile sonuçlanacaktır. 

## DOCKER-COMPOSE

Docker-compose çoklu-konteyner uygulamaları için kullanılan bir araçtır.
YAML formatında yazılmış bir dosya ile uygulama servislerinin konfigürasyonunda rol oynar.

Uygulamaların dockerfile konfigürasyonlarını tanımlamanız ve 
servis konfigürasyonlarını docker-compose.yml dosyasında barındırmanız halinde 
herhangi bir host üzerinde proje bazlı çalışan ve birden çok konteyner içeren
projelerinizi kolaylıkla çalıştırabilirsiniz.

Örnek bir docker-compose.yml...

```
version: "3.8"
services:

  redis:
    image: redis:alpine
    ports:
      - "6379"
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  db:
    image: postgres:9.4
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        max_replicas_per_node: 1
        constraints:
          - "node.role==manager"

  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - "5000:80"
    networks:
      - frontend
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
      restart_policy:
        condition: on-failure

  result:
    image: dockersamples/examplevotingapp_result:before
    ports:
      - "5001:80"
    networks:
      - backend
    depends_on:
      - db
    deploy:
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 1
      labels: [APP=VOTING]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
        window: 120s
      placement:
        constraints:
          - "node.role==manager"

  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    stop_grace_period: 1m30s
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints:
          - "node.role==manager"

networks:
  frontend:
  backend:

volumes:
  db-data:

```
şeklinde olabilir. Şimdi yukarıda geçen terimleri biraz daha açıklayalım:

- Version: Compose dosyası versiyonu. Bazı ayarlar bu versiyona bağlı olarak çalışmaktadır.

- Services: Birlikte başlatılacak konteynerler için listeleme referansı görevi görür. `<service_name>:` Herhangi bir isim taşıyabilir. İmaj vb. detayları zaten aşağıda.

- Build:	Sadece bir dizin olarak bahsedilebilir veyahutta aşağıdaki detaylarla başlatılabilir.

- Context: Build işleminin gerçekleşeceği dizin. `./dizin/yolu/vb/`

- Dockerfile: Alternatif dockerfile bilgisi bulunur.

- Args:	Sadece build anında var olan ve dikkate alınan 	argümanlar oluşturulması için kullanılır. `<args_name>=<args_value>` (boolean değerler dahi alabilir)

- Cache_from: Docker engine için cache değerleri.

- Labels: Ortaya çıkan imaja metadata eklemeye yarar. Dockerfile içerisindeki formata yakındır. 

- Network: Konteyneri belirli bir networke dahil etmek için kullanılabilir.

- Shm_size: Bu build esnasında /dev/shm üzerinde yer alan shared memory oranını belirler. `2gb'/1000000` gibi değerler alabilir.

- Target: Dockerfile içerisinde belirtilen STAGE ayarlarıyla build alır. `<stage_name>` Örneğin `prod`

- Cap_add/drop: Capability add-drop olarak çalışır. Konteynera göre değişkenlik gösterip özgün özellikler taşır.

- Command: Default gelen command'in üstüne yazar.

- Configs: Adından da anlaşılacağı gibi belirli config dosyalarına erişim sağlar. YAML listelemesi ile verilir. Uzun syntax sahibi olan versiyonu detaylı hareket sağlar.

- Container_name: Custom konteyner ismi belirlemenizi sağlar.

- Depends_on: Kendisinden öncebaşlatılması gereken konteynerler olması halinde kullanılır ve bir queue oluşturur.

- Deploy: Deploy spesifik ayar belirlemeye yarar.

- Replicas: Aynı anda çalışan konteyner sayısı.

- Image: Konteynerin başlatılacağı imajın belirlenmesi. Kullanımı `image: <imaj_adı>` Örneğin; `image: ubuntu:18.04`

- Logging: Log yapısı için konfigürasyon başlangıcı.

- Driver: syslog/none/json-file değerleri alabilir ve bir loging driver belirtir.
				
				options:
					syslog-address: "tcp://192.168.0.42:123"
					max-size: "200k"
					max-file: "10"
				
- Network_mode: bridge/host/none/"service:[service_name]" şeklinde değerler alabilir.
			
- Pid: "host" değerini alması halinde pid adres uzayını host makineden kullanarak kendisine 'fiziksel' bir pid edinir.
			
- Ports: Kullanılacak portların expose sıralamasına göre yazılması için kullanılabilecek listeleme ile kullanılabilen bir listedir. `-p` parametresi sonrası verilebilen `3000:6600` şeklindeki değerleri burada sıralı liste olarak alır ve kullanır.

- Restart: `"no"` / `always` / `on-failure` / `unless-stopped` şeklinde	değerler alır. Konteynerin tekrar başlatılma durumunu niteler.

- Networks:Konteynerin katılacağı ağların listesidir.

- Volumes: Kullanılacak disk alanının belirtilmesi işine yarar. En güzel öğrenimi örnek üzerindendir.

				volumes:
					- type: volume
						source: mydata
						target: /data
						volume:
							nocopy: true
						- type: bind
						source: ./static
						target: /opt/app/static


    Buradaki kullanım sonrasında konunun anlaşılmış olmasını umuyorum.

- Networks: Top-level kısımda yer alan network anahtarı yaratılacak networkleri belirlemenizi sağlar. 

    https://docs.docker.com/compose/compose-file/#network-configuration-reference 
			Referansı bırakmamın sebebi benim anlatışımın 
			bu konu için yeterli olmayacağı gerçeği.
- Volumes: `<vol_name>:`
- Driver: Default olan değeri local'dir. Kullanılamayacak durumdaki bir driverın verilmesi halinde docker-compose hata verecektir.
- Driver_opts: Key-value şeklinde belirtilen options listesi.
				
				Type: "nfs"
				O: "addr=10.40.0.199,nolock,soft,rw"
				Device: ":/docker/example"
			
- External: Eğer `true` değer verilirse belirtilen Volume ayarlarına sahip bir volume'un halihazırda var olduğunu docker-compose esnasında yaratılmasının gerekli olmadığını belirtir.
			
- Name: Bu volume için custom bir isim beliriememize yarar.


Bu docker-compose versiyon 3 için düzenlenmiştir.



Yukarıda - karakterleriyle ayrılan kısımdaki docker-compose dosyasının ne yaptığını 
okuyarak sesli olarak birine anlatmaya çalışın. Faydası olacağına eminim.
