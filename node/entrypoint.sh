#!/usr/bin/env sh
bash
yarn global add create-react-app
create-react-app .
chown node:node -R .
yarn install
yarn start