Nginx günümüzde web server olarak sıklıkla kullandığımız bir araç. İlk başlarda C10k sorununa bir çözüm olarak geliştirilen nginx artık load balancer ve reverse proxy olarak da kullanılmakta.

Bazı temel konseptlerin üstünden beraber geçelim.

<b>Web Serving:</b> Nginx statik web sayfaları ile rahatlıkla kullanılabilir. Bağlantı sayısının fazla olması için tasarlandığı düşünüldüğünde hızlı ve kolay bir çözüm olarak düşünülmesi kaçınılmaz hale geliyor.

<b>Reverse Proxy:</b> Reverse proxy kavramı ile mikroservis mimarisi ile çalıştıysanız karşılaşmış olma ihtimaliniz çok yüksek. Tek bir kanaldan gelen HTTP veya TCP isteklerini load balancing metoduna, network gereksinimlerine veya güvenlik sınırlamalarına bağlı olarak yönlendirmenizi mümkün kılıyor.

<b>Load Balancing:</b> Nginx'i reverse proxy modunda kullanırken birden fazla backend server vererek ve load balancing metodolojinize karar vererek rahatlıkla bir load balancing stratejisi oluşturabilirsiniz.

<b>HTTP Server:</b> HTTP/S protokollerini destekleyen Nginx SSL/TLS encryption, URL rewriting, redirection ve authentication için de kullanılabilmekte.

<b>Monitörleme:</b> Nginx'in monitörleme ve loglama için de bir çok fonksiyonalitesi bulunmakta. Bunların bir örneğini aşağıda göreceğiz.

<b>Community:</b> Geniş bir destekleyici topluluğa sahip olan Nginx online kaynakların bolluğu, forumlar veya stack overflow|exchange gibi platformlarda bulabileceğiniz bir çok cevapla sorularınıza hızlı yanıt vermenizi de sağlıyor.

Peki bunları nasıl pratiğe dökebiliriz?

Başlayalım.

Nginx'i denemek için lokal bir servis olarak kurabilir veya docker konteyneri ile servisi ayaklandırabilir, böylece denemelere hemen başlayabilirsiniz. 

Nginx servisini bir çok platformda kolaylıkla paket yöneticileri aracılığıyla kurabilir, GNU/Linux dağıtımlarında ise genellikle <pre>/etc/nginx</pre> dizini altındaki nginx.conf dosyasını hemen editlemeye başlayabilirsiniz.

Aşağıda ilk kurulum sonrası gelen nginx.conf dosyasını parçalanmış şekilde görebilirsiniz.
Dosyanın orijinaline de [buradan](https://github.com/nginx/nginx/blob/master/conf/nginx.conf) ulaşabilirsiniz.

<pre>
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;
</pre>

Nginx'in bağlantıları genel context'te nasıl yöneteceğini belirten kısım burası. Nginx connection'ları yönetirken event-based bir bakış açısı kullanır.
<pre>

events {
    worker_connections  1024;
}
</pre>

Gelecek HTTP/S bağlantılarının yönetiminde kullanılacak temel ayarlar ise main scope'da (dosyanın outer scope'u) http bloğunda tanımlanır. Domain bazlı özelleştirilmiş konfigürasyonların include ayarları, desteklenen SSL protokolleri ve log opsiyonları da genel hatlarıyla burada belirtilecektir. 

    http {
        include       mime.types;
        default_type  application/octet-stream;
        #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
        #                  '$status $body_bytes_sent "$http_referer" '
        #                  '"$http_user_agent" "$http_x_forwarded_for"';
        #access_log  logs/access.log  main;
        sendfile        on;
        #tcp_nopush     on;
        #keepalive_timeout  0;
        keepalive_timeout  65;
        #gzip  on;
        server {
            listen       80;
            server_name  localhost;
            #charset koi8-r;
            #access_log  logs/host.access.log  main;
            location / {
                root   html;
                index  index.html index.htm;
            }
            #error_page  404              /404.html;
            # redirect server error pages to the static page /50x.html
            #
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   html;
            }
            # proxy the PHP scripts to Apache listening on 127.0.0.1:80
            #
            #location ~ \.php$ {
            #    proxy_pass   http://127.0.0.1;
            #}
            # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
            #
            #location ~ \.php$ {
            #    root           html;
            #    fastcgi_pass   127.0.0.1:9000;
            #    fastcgi_index  index.php;
            #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
            #    include        fastcgi_params;
            #}
            # deny access to .htaccess files, if Apache's document root
            # concurs with nginx's one
            #
            #location ~ /\.ht {
            #    deny  all;
            #}
        }
        # another virtual host using mix of IP-, name-, and port-based configuration
        #
        #server {
        #    listen       8000;
        #    listen       somename:8080;
        #    server_name  somename  alias  another.alias;
        #    location / {
        #        root   html;
        #        index  index.html index.htm;
        #    }
        #}
        # HTTPS server
        #
        #server {
        #    listen       443 ssl;
        #    server_name  localhost;
        #    ssl_certificate      cert.pem;
        #    ssl_certificate_key  cert.key;
        #    ssl_session_cache    shared:SSL:1m;
        #    ssl_session_timeout  5m;
        #    ssl_ciphers  HIGH:!aNULL:!MD5;
        #    ssl_prefer_server_ciphers  on;
        #    location / {
        #        root   html;
        #        index  index.html index.htm;
        #    }
        #}

    }

Server tanımlarına biraz daha detaylı değinebileceğimize inanıyorum. 


    server {
        #aktif olarak port 80'in dinlenmesi
        listen       80;

        #konfigürasyon dosyası içerisinde hangi server bloğunu seçeceğimizi anlatabilmek
        #  için server_name direktifi ile ilerliyoruz.
        server_name  example.com;

        access_log  logs/host.access.log  main;

        #sunacağımız statik web içeriğinin sunucu üzerindeki path'i
        root /data/www

        location / {
            #Burada belirtilen / server_name direktifinin sonuna eklenecektir.
            
            #ilk karşımıza çıkan index sayfamızı burada belirtebiliriz.
            index  index.html index.htm;
        }

        location /backend/ {
            #Logical olarak backend isteği olarak nitelendirebileceğimiz istekleri 9090 #  portunda bekleyen backend'imize yönlendirebiliriz
            proxy_pass http://localhost:9090;

        }
        
        # Biraz regex kullanımı ile directory tanımlarımızı değiştirmemiz ve server 
        #  üzerindeki kaynak adreslerimizi çoklu olarak değiştirmemiz mümkün.
        location ~ \.(gif|jpg|png)$ {
            root /data/images;
        }

        error_page  404              /404.html;

        # Server error sayfalarını statik /50x.html sayfasına yönlendirebiliriz
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # PHP betiklerini FastCGI server'a gönderebiliriz 
        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
            include        fastcgi_params;
        }
        # deny access to .conf files
        location ~ /\.conf {
            deny  all;
        }
    }

Yukarıdaki tanımlara aşina olanlar için günlük web server ve content access tanımları çocuk oyuncağı haline gelecektir. Çünkü [Beginner's Guide'ı](https://nginx.org/en/docs/beginners_guide.html) tamamladınız.

Gelelim detaylara;
####HTTP Load balancing
Nginx'in load balancing için sıklıkla upstream tanımlaması kullanılır

HTTP context'i içinde aşağıdaki tanımlama muhtemelen en sade haliyle durumu size özetleyecektir.

    http {
        upstream myapp1 {
            [method] ;
            server srv1.example.com;
            server srv2.example.com max_fails=1 fail_timeout=10s;
            server srv3.example.com;
        }

        server {
            listen 80;

            location / {
                proxy_pass http://myapp1;
            }
        }
    }
Load balancing method'u belirtilmediğinde ön tanımlı olarak [round-robin algoritması](https://en.wikipedia.org/wiki/Round-robin_scheduling) kullanılacaktır. least_conn, ip_hash, hash veya weighted gibi seçeneklerimiz de mevcut. 

<b>least_conn</b> aktif bağlantı sayısına bağlı yük dağıtımı sağlarken,
<b>ip_hash</b> bağlantı kurulan ip adreslerinin ilk 3 oktetine bağlı olarak server eşlemesi yapar ve internal olarak ayrılmış network yüklerini dağıtmak için mantıklı bir seçim olabilir. Örneğin 1.2.3.0/24 bloğunun tamamını tek bir server'a yönlendirmeye çalışır.
<b>hash</b> direktifiyle ise ip_adresi + user agent kombinasyonlarına bağlı olarak key-value(upstream server) pair'leri oluşturabilirsiniz. IP bazlı stickiness için yeterli olduğunu düşündüğüm bir yapı kurmaya yarar ancak client bazlı stickiness için [sticky cookie](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/)'ye bakmanızı öneririm.
<b>weighted</b> direktifi adından anlaşılabileceği üzere serverlara ağırlık tanımlamamız sonucunda ağırlıklarına bağlı olarak dağıtım yapar. Yukarıdaki örnekte her 5 bağlantının 3 tanesi srv1'e gidecektir.
<b>Helthcheck</b> de load balancing için önemli bir konu. Bir server'ın ayakta ve sağlıklı olup olmadığının kontrolünü de srv2 için verilen max_fails ve fail_timeout direktifleri ile sağlıyoruz. Örnekte ilk failed connection'da 10s boyunca inactive işaretlenen srv2, tekrar aktif olduğunda hizmete dönecektir. 

####TCP/UDP Load Balancing
HTTP load balancing'e benzer çalışan TCP/UDP load balancing işlemleri için aşağıda belirttiğim config dosyasını inceleyebilirsiniz. Burada http bloğu yerine bir stream bloğu kullanıldığına da dikkatinizi çekmek istiyorum. İki farklı upstream grubu ile hem yük dengeleme, hem high availability için çalışmış oluyoruz.

    stream {
        upstream stream_backend {
            least_conn;
            server backend1.example.com:12345 weight=5;
            server backend2.example.com:12345 max_fails=2 fail_timeout=30s;
            server backend3.example.com:12345 max_conns=3;
        }
        
        upstream dns_servers {
            least_conn;
            server 192.168.136.130:53;
            server 192.168.136.131:53;
            server 192.168.136.132:53;
        }
        
        server {
            listen        12345;
            proxy_pass    stream_backend;
            proxy_timeout 3s;
            proxy_connect_timeout 1s;
        }
        
        server {
            listen     53 udp;
            proxy_pass dns_servers;
        }
        
        server {
            listen     12346;
            proxy_pass backend4.example.com:12346;
        }
    }
Sıklıkla karşımıza çıkan proxy_pass direktifine ve daha fazlasına ait dökümanlara [buradan](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html) erişebilirsiniz.

####Loglama
Nginx'in connection tanımlarına bağlı olan bir loglama yapısı var. Hatta ilk kurulumla birlikte gelen config dosyasında main context içerisinde log_format için de bir girdi bulunmakta.

    log_format main '$remote_addr - $remote_user [$time_local] $status '
        '"$request" $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for"';
Örnek olarak aşağıdaki gibi bir log basacaktır:

    47.29.201.179 - - [28/Feb/2019:13:17:10 +0000] 200 "GET /?p=1 HTTP/2.0" 5316 "https://domain1.com/?p=1" "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36" ""


Tabi ki özelleştirilmiş loglama sistemleri kurmak da mümkün. Aşağıda error ve access loglarını syslog'a nasıl gönderebildiğimizi de görebilirsiniz.

    error_log  syslog:server=unix:/var/log/nginx.sock debug;
    access_log syslog:server=[2001:db8::1]:1234,facility=local7,tag=nginx,severity=info;

Load balancing için özelleştirilmiş log formatları kurabilir ve bu sayede network veya connection bazlı hatalarımızın çözümünde zaman kazanabiliriz.

    log_format upstream_time '$remote_addr - $remote_user [$time_local] '
                             '"$request" $status $body_bytes_sent '
                             '"$http_referer" "$http_user_agent"'
                             'rt=$request_time uct="$upstream_connect_time" uht="$upstream_header_time" urt="$upstream_response_time"';

Upstream modulünün detaylarına, kullanabileceğiniz diğer parametrelere ve daha fazlasına [buradan](https://nginx.org/en/docs/http/ngx_http_upstream_module.html) ulaşabilirsiniz.
