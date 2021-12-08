Deploy Insutructions on Container

cd into project (/home/ubuntu/slamr-api-gateway), (make sure you are root)
```sh
npm install
npm run build
./src/systemd/deploy-test.sh
```