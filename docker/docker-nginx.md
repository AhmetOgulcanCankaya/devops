`docker run -it --rm  --net="host" -d -p --name web nginx-i`

nginx.conf üzerindeki localhost tanımını host makinede yapması için --net="host" eklenebilir.
80:80 bağını ortadan kaldırıyor.

Başlattığında signature çıkıyor ama `docker ps | -a` çıktısında göremiyorsan `-d` (deamon) parametresini kaldır.

`-d` parametresi kalktığında /var veya /etc üzerinden çalıştırılan bir program gibi davranacaktır.

Hata logunu bastırabilir. En olmadı lokaldeki nginx üzerinden deneme yap. 

