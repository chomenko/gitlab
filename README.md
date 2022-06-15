# Example Gitlab with traefic & docker registry

start:
````shell
make up
````
- open [https://git.localhost](https://git.localhost/) and wait started gitlab
- change password for `root` user
- open [https://git.localhost/admin/runners]( https://git.localhost/admin/runners)
- register initial gitlab runner `make addRunerTls` with `docker:19.03.1`
